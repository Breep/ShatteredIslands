class_name SE_WildHunt
extends SkillEffect

# Talent Bronze "Traque Sauvage" : les loups (acolytes) de Latika gagnent
# +_wolf_hp_percent % PV max et +_wolf_ms_bonus m/s de vitesse. Posé sur le
# acolyte_modifiers_registry de Latika → cloné dans les registries de chaque loup
# à son spawn (cf. Pool/CLAUDE.md §8).

@export var _wolf_hp_percent: float = 25.0
@export var _wolf_ms_bonus: float = 1.5


func apply(ctx: SkillContext) -> void:
	var latika: Entity = ctx.entity
	if latika == null:
		Verbose.error("SE_WildHunt: null owner", Verbose.Category.ENTITY_MODULE)
		return

	var hp_mod := StatModifier.new()
	hp_mod.id = &"WildHuntHp"
	hp_mod.stat_type = EntityStats.StatType.HEALTH_MAX
	hp_mod.calc_type = StatModifier.CalcType.MULT
	hp_mod.value = _wolf_hp_percent / 100.0
	latika.acolyte_modifiers_registry.stat_modifiers_registry.register_modifier(hp_mod)

	var ms_mod := StatModifier.new()
	ms_mod.id = &"WildHuntMs"
	ms_mod.stat_type = EntityStats.StatType.MS
	ms_mod.value = _wolf_ms_bonus
	latika.acolyte_modifiers_registry.stat_modifiers_registry.register_modifier(ms_mod)


func get_description() -> String:
	return "Les loups de Latika gagnent +" + _value(_wolf_hp_percent) + "% de PV max et +" \
		+ _value(_wolf_ms_bonus) + " de vitesse de déplacement."
