# Tool éditeur : génère N fichiers EntityStats.tres (un par niveau) selon des
# règles de croissance par stat, plus optionnellement un EntityDesc.tres qui
# référence le tout. Workflow :
#   1. Créer une Resource EntityStatsBuilder dans le FileSystem
#   2. Remplir output_dir, stats_file_prefix, level_count, les StatGrowthRule
#   3. Cliquer le bouton "Generate" dans l'inspecteur
@tool
class_name EntityStatsBuilder
extends Resource

#region ============================== Export — Output ==============================
## Dossier où écrire les .tres générés.
@export_dir var output_dir: String

## Préfixe des fichiers stats (ex: "latika" → latika_lvl_01.tres).
@export var stats_file_prefix: String = "stats"

## Nombre de niveaux à générer (lvl 1 inclus).
@export_range(1, 100) var level_count: int = 20
#endregion


#region ============================== Export — EntityDesc ==============================
@export_group("EntityDesc")
## Si vrai, génère aussi un EntityDesc.tres qui référence les stats.
@export var generate_desc: bool = true
## Nom du fichier desc (sans extension), placé dans output_dir.
@export var desc_file_name: String = "entity_desc"
## Champ name de l'EntityDesc.
@export var entity_name: String = ""
## Champ description (multiline) de l'EntityDesc.
@export_multiline var entity_description: String = ""
#endregion


#region ============================== Export — Growth Rules Mono ==============================
@export_group("Growth Rules — Mono")
@export var health_max: StatGrowthRule
@export var mana_max: StatGrowthRule
@export var mana_regen: StatGrowthRule
@export var attack_damage: StatGrowthRule
@export var attack_speed: StatGrowthRule
@export var attack_range: StatGrowthRule
@export var attack_power: StatGrowthRule
@export var movement_speed: StatGrowthRule
@export var scale: StatGrowthRule
@export var crit_chance: StatGrowthRule
@export var crit_mult: StatGrowthRule
@export var dodge: StatGrowthRule
@export var lifesteal: StatGrowthRule
@export var crit_resistance: StatGrowthRule
#endregion


#region ============================== Export — Growth Rules Resistances ==============================
@export_group("Growth Rules — Resistances")
@export var armor: StatGrowthRule
@export var magic_resistance: StatGrowthRule
@export var poison_resistance: StatGrowthRule
#endregion


#region ============================== Export — Constants ==============================
@export_group("Constants")
@export var auto_attack_type: EntityStats.AutoAttackType = EntityStats.AutoAttackType.RANGED
#endregion


#region ============================== Generate button ==============================
@export_tool_button("Generate") var _generate_button = generate
#endregion


#region ============================== Public API ==============================
func generate() -> void:
	if output_dir.is_empty():
		push_error("[EntityStatsBuilder] output_dir is empty")
		return
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(output_dir)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

	var saved_paths: Dictionary[int, String] = {}

	for lvl in range(1, level_count + 1):
		var stats: EntityStats = EntityStats.new()
		_apply_rule_to(stats, "health_max", lvl, health_max)
		_apply_rule_to(stats, "mana_max", lvl, mana_max)
		_apply_rule_to(stats, "mana_regen", lvl, mana_regen)
		_apply_rule_to(stats, "attack_damage", lvl, attack_damage)
		_apply_rule_to(stats, "attack_speed", lvl, attack_speed)
		_apply_rule_to(stats, "attack_range", lvl, attack_range)
		_apply_rule_to(stats, "attack_power", lvl, attack_power)
		_apply_rule_to(stats, "movement_speed", lvl, movement_speed)
		_apply_rule_to(stats, "scale", lvl, scale)
		_apply_rule_to(stats, "crit_chance", lvl, crit_chance)
		_apply_rule_to(stats, "crit_mult", lvl, crit_mult)
		_apply_rule_to(stats, "dodge", lvl, dodge)
		_apply_rule_to(stats, "lifesteal", lvl, lifesteal)
		_apply_rule_to(stats, "crit_resistance", lvl, crit_resistance)
		_apply_rule_to(stats, "armor", lvl, armor)
		_apply_rule_to(stats, "magic_resistance", lvl, magic_resistance)
		_apply_rule_to(stats, "poison_resistance", lvl, poison_resistance)

		stats.auto_attack_type = auto_attack_type

		var file_name: String = "%s_lvl_%02d.tres" % [stats_file_prefix, lvl]
		var path: String = output_dir.path_join(file_name)
		var err: int = ResourceSaver.save(stats, path)
		if err != OK:
			push_error("[EntityStatsBuilder] Failed to save %s (err=%d)" % [path, err])
			return
		saved_paths[lvl] = path

	print("[EntityStatsBuilder] Generated %d stats files in %s" % [level_count, output_dir])

	if generate_desc:
		var desc: EntityDesc = EntityDesc.new()
		desc.name = entity_name
		desc.description = entity_description
		for lvl in saved_paths:
			desc.stats[lvl] = ResourceLoader.load(saved_paths[lvl], "", ResourceLoader.CACHE_MODE_REPLACE)
		var desc_path: String = output_dir.path_join(desc_file_name + ".tres")
		var err: int = ResourceSaver.save(desc, desc_path)
		if err != OK:
			push_error("[EntityStatsBuilder] Failed to save desc %s (err=%d)" % [desc_path, err])
			return
		print("[EntityStatsBuilder] Generated desc at %s" % desc_path)

	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()
#endregion


#region ============================== Private API ==============================
func _apply_rule_to(stats: EntityStats, property: StringName, lvl: int, rule: StatGrowthRule) -> void:
	if rule == null: return
	stats.set(property, rule.compute(lvl))
#endregion
