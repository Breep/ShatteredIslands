# Importeur de stats multi-entités (éditeur). Lit le JSON exporté depuis la Google
# Sheet (1 enregistrement = 1 entité à 1 niveau) et, pour chaque entité, régénère
# ses EntityStats.tres par niveau puis réinjecte le dictionnaire stats dans son
# EntityDesc. Générique : héros, mobs, bâtiments... tout ce qui a un EntityDesc.
#
# Ciblage : par défaut auto-résolu depuis entity_id (on cherche le dossier du même
# nom sous Pool/, on y trouve le *Desc, on en déduit le dossier Stats et le préfixe).
# Les colonnes meta desc_path / stats_dir / stats_prefix du JSON, si renseignées,
# priment sur l'auto-résolution (échappatoire pour les cas non conventionnels).
# Lancer via "File > Run" (Maj+Ctrl+X) avec ce script ouvert dans l'éditeur.
@tool
extends EditorScript

#region ============================== Constants ==============================
const JSON_PATH := "res://02_Entities/_Shared/ImportJson/stats.json"
const POOL_ROOT := "res://02_Entities/Pool"
const SCRIPT_CLASS_TOKEN := 'script_class="'

# Colonnes meta : pilotent le ciblage, jamais écrites dans EntityStats.
const META_KEYS: PackedStringArray = ["entity_id", "level", "desc_path", "stats_dir", "stats_prefix"]

# Clés legacy tolérées sans warning (en cours de retrait côté Sheet).
# crit_resistances.* est remplacé par la Mono crit_resistance (collapse).
const IGNORED_KEYS: PackedStringArray = ["crit_resistances"]

# Clé JSON Mono -> StatType. Tout est routé via EntityStats.update_stat().
const MONO_STATS: Dictionary = {
	"health_max": EntityStats.StatType.HEALTH_MAX,
	"mana_max": EntityStats.StatType.MANA_MAX,
	"mana_regen": EntityStats.StatType.MANA_REGEN,
	"attack_damage": EntityStats.StatType.AD,
	"attack_speed": EntityStats.StatType.AS,
	"attack_power": EntityStats.StatType.AP,
	"attack_range": EntityStats.StatType.AR,
	"movement_speed": EntityStats.StatType.MS,
	"scale": EntityStats.StatType.SCALE,
	"crit_chance": EntityStats.StatType.CRIT_CHANCE,
	"crit_mult": EntityStats.StatType.CRIT_MULT,
	"dodge": EntityStats.StatType.DODGE,
	"lifesteal": EntityStats.StatType.LIFESTEAL,
	"crit_resistance": EntityStats.StatType.CRIT_RESISTANCE,
}

# Groupe JSON Multi (objet ActionType -> valeur) -> StatType.
# Rappel des renommages côté sheet : strength -> m_powers, weakness -> m_fragilities,
# vulnerabilities -> m_exposures.
const MULTI_STATS: Dictionary = {
	"m_crit_chances": EntityStats.StatType.M_CRIT_CHANCE,
	"m_crit_mults": EntityStats.StatType.M_CRIT_MULT,
	"m_dodges": EntityStats.StatType.M_DODGE,
	"m_lifesteals": EntityStats.StatType.M_LIFESTEAL,
	"m_powers": EntityStats.StatType.M_POWER,
	"m_fragilities": EntityStats.StatType.M_FRAGILITY,
	"m_resistances": EntityStats.StatType.M_RESISTANCE,
	"m_exposures": EntityStats.StatType.M_EXPOSURE,
}
#endregion


#region ============================== Public functions ==============================
func _run() -> void:
	var rows: Array = _load_json()
	if rows.is_empty():
		return

	var by_entity: Dictionary = {}
	for row: Variant in rows:
		if typeof(row) != TYPE_DICTIONARY:
			push_warning("[ImportStats] Enregistrement non-objet ignoré.")
			continue
		var id: String = str(row.get("entity_id", "")).strip_edges()
		if id.is_empty():
			push_warning("[ImportStats] Ligne sans entity_id ignorée.")
			continue
		if not by_entity.has(id):
			by_entity[id] = []
		by_entity[id].append(row)

	var ok_count := 0
	for entity_id: String in by_entity:
		if _process_entity(entity_id, by_entity[entity_id]):
			ok_count += 1

	EditorInterface.get_resource_filesystem().scan()
	print("[ImportStats] Terminé : %d/%d entités importées." % [ok_count, by_entity.size()])
#endregion


#region ============================== Private functions ==============================
func _load_json() -> Array:
	if not FileAccess.file_exists(JSON_PATH):
		push_error("[ImportStats] JSON introuvable : " + JSON_PATH)
		return []
	var file := FileAccess.open(JSON_PATH, FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_ARRAY:
		push_error("[ImportStats] JSON invalide : un tableau d'objets est attendu.")
		return []
	return data


func _process_entity(entity_id: String, entries: Array) -> bool:
	var targets := _resolve_targets(entity_id, entries)
	if targets.is_empty():
		return false
	var desc_path: String = targets["desc_path"]
	var stats_dir: String = targets["stats_dir"]
	var prefix: String = targets["stats_prefix"]

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(stats_dir))

	# L'import REMPLACE intégralement le dictionnaire stats du desc : il faut donc
	# que le JSON contienne TOUS les niveaux voulus pour cette entité.
	var stats_by_level: Dictionary[int, EntityStats] = {}
	for entry: Dictionary in entries:
		var level := int(entry.get("level", 0))
		if level <= 0:
			push_warning("[ImportStats] %s : niveau invalide, ligne ignorée." % entity_id)
			continue
		var stats := EntityStats.new()
		_apply_entry(stats, entry, entity_id, level)
		var path := stats_dir.path_join("%s_lvl_%02d.tres" % [prefix, level])
		var err := ResourceSaver.save(stats, path)
		if err != OK:
			push_error("[ImportStats] %s : échec sauvegarde %s (err=%d)" % [entity_id, path, err])
			return false
		stats_by_level[level] = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)

	var desc: EntityDesc = ResourceLoader.load(desc_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	if desc == null:
		push_error("[ImportStats] %s : chargement EntityDesc échoué : %s" % [entity_id, desc_path])
		return false
	desc.stats = stats_by_level
	var derr := ResourceSaver.save(desc, desc_path)
	if derr != OK:
		push_error("[ImportStats] %s : échec sauvegarde desc %s (err=%d)" % [entity_id, desc_path, derr])
		return false

	print("[ImportStats] %s : %d niveaux -> %s" % [entity_id, stats_by_level.size(), desc_path])
	return true


# Détermine desc_path / stats_dir / stats_prefix. Les valeurs explicites du JSON
# priment ; sinon auto-résolution depuis entity_id. Retourne {} en cas d'échec.
func _resolve_targets(entity_id: String, entries: Array) -> Dictionary:
	var meta := _resolve_meta(entries)
	var desc_path: String = meta["desc_path"]
	var stats_dir: String = meta["stats_dir"]
	var prefix: String = meta["stats_prefix"]

	if desc_path.is_empty():
		desc_path = _auto_find_desc(entity_id)
		if desc_path.is_empty():
			return {}
		print("[ImportStats] %s : desc auto-résolu -> %s" % [entity_id, desc_path])

	if not ResourceLoader.exists(desc_path):
		push_error("[ImportStats] %s : EntityDesc introuvable : %s" % [entity_id, desc_path])
		return {}

	if stats_dir.is_empty():
		stats_dir = _derive_stats_dir(desc_path)
	if prefix.is_empty():
		prefix = _derive_prefix(stats_dir, entity_id)

	return {"desc_path": desc_path, "stats_dir": stats_dir, "stats_prefix": prefix}


# Récupère desc_path / stats_dir / stats_prefix explicites : première valeur non
# vide du groupe (ces colonnes ne sont en général remplies que sur la 1re ligne).
func _resolve_meta(entries: Array) -> Dictionary:
	var meta := {"desc_path": "", "stats_dir": "", "stats_prefix": ""}
	for entry: Dictionary in entries:
		for key: String in meta:
			if meta[key].is_empty():
				meta[key] = str(entry.get(key, "")).strip_edges()
	return meta


# Cherche le dossier nommé comme entity_id sous Pool/, puis l'unique *Desc dedans.
func _auto_find_desc(entity_id: String) -> String:
	var folders := _find_pool_folders(entity_id)
	if folders.is_empty():
		push_error("[ImportStats] %s : aucun dossier '%s' sous %s. Renseigne desc_path." % [entity_id, entity_id, POOL_ROOT])
		return ""
	if folders.size() > 1:
		push_error("[ImportStats] %s : plusieurs dossiers '%s' (%s). Renseigne desc_path." % [entity_id, entity_id, ", ".join(folders)])
		return ""

	var descs := _find_desc_resources(folders[0])
	if descs.is_empty():
		push_error("[ImportStats] %s : aucun EntityDesc dans %s. Renseigne desc_path." % [entity_id, folders[0]])
		return ""
	if descs.size() > 1:
		push_error("[ImportStats] %s : plusieurs EntityDesc dans %s (%s). Renseigne desc_path." % [entity_id, folders[0], ", ".join(descs)])
		return ""
	return descs[0]


func _find_pool_folders(target: String) -> Array:
	var matches: Array = []
	_scan_for_dir(POOL_ROOT, target, matches)
	return matches


func _scan_for_dir(path: String, target: String, matches: Array) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			var sub := path.path_join(entry)
			if entry == target:
				matches.append(sub)
			_scan_for_dir(sub, target, matches)
		entry = dir.get_next()
	dir.list_dir_end()


# Les .tres "desc" sont détectés via leur script_class finissant par "Desc"
# (EntityDesc, HeroDesc...) — distinct des stats (EntityStats / HeroStats).
func _find_desc_resources(folder: String) -> Array:
	var result: Array = []
	_collect_descs_in(folder, result)
	_collect_descs_in(folder.path_join("Stats"), result)
	return result


func _collect_descs_in(path: String, result: Array) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if not dir.current_is_dir() and entry.get_extension() == "tres":
			var full := path.path_join(entry)
			if _is_desc_resource(full):
				result.append(full)
		entry = dir.get_next()
	dir.list_dir_end()


func _is_desc_resource(tres_path: String) -> bool:
	var f := FileAccess.open(tres_path, FileAccess.READ)
	if f == null:
		return false
	var first_line := f.get_line()
	var idx := first_line.find(SCRIPT_CLASS_TOKEN)
	if idx == -1:
		return false
	var rest := first_line.substr(idx + SCRIPT_CLASS_TOKEN.length())
	var end := rest.find('"')
	if end == -1:
		return false
	return rest.substr(0, end).ends_with("Desc")


# Dossier des .tres de niveau : le dossier du desc s'il s'appelle "Stats",
# sinon un sous-dossier "Stats" à côté.
func _derive_stats_dir(desc_path: String) -> String:
	var base := desc_path.get_base_dir()
	if base.get_file() == "Stats":
		return base
	return base.path_join("Stats")


# Préfixe déduit d'un fichier "<prefix>_lvl_NN.tres" existant ; sinon snake_case.
# Robuste même quand le préfixe ne suit pas le nom de l'entité.
func _derive_prefix(stats_dir: String, entity_id: String) -> String:
	var dir := DirAccess.open(stats_dir)
	if dir != null:
		dir.list_dir_begin()
		var entry := dir.get_next()
		while entry != "":
			if not dir.current_is_dir() and entry.get_extension() == "tres":
				var base := entry.get_basename()
				var pos := base.rfind("_lvl_")
				if pos > 0:
					dir.list_dir_end()
					return base.substr(0, pos)
			entry = dir.get_next()
		dir.list_dir_end()
	return entity_id.to_snake_case()


func _apply_entry(stats: EntityStats, entry: Dictionary, entity_id: String, level: int) -> void:
	for key: String in entry:
		if key in META_KEYS or key in IGNORED_KEYS:
			continue
		var value: Variant = entry[key]
		if key == "auto_attack_type":
			_apply_auto_attack_type(stats, value)
		elif MONO_STATS.has(key):
			stats.update_stat(MONO_STATS[key], float(value))
		elif MULTI_STATS.has(key):
			_apply_multi(stats, MULTI_STATS[key], value, entity_id, level)
		else:
			push_warning("[ImportStats] %s lvl %d : clé inconnue ignorée : %s" % [entity_id, level, key])


func _apply_multi(stats: EntityStats, stat_type: EntityStats.StatType, value: Variant, entity_id: String, level: int) -> void:
	if typeof(value) != TYPE_DICTIONARY:
		push_warning("[ImportStats] %s lvl %d : groupe Multi attendu en objet, ignoré." % [entity_id, level])
		return
	for action_name: String in value:
		if not action_name in Utils.ActionType:
			push_warning("[ImportStats] %s lvl %d : ActionType inconnu : %s" % [entity_id, level, action_name])
			continue
		stats.update_stat(stat_type, float(value[action_name]), Utils.ActionType[action_name])


func _apply_auto_attack_type(stats: EntityStats, value: Variant) -> void:
	var aa_name := str(value).strip_edges().to_upper()
	if aa_name in EntityStats.AutoAttackType:
		stats.auto_attack_type = EntityStats.AutoAttackType[aa_name]
	else:
		push_warning("[ImportStats] auto_attack_type inconnu : %s" % aa_name)
#endregion
