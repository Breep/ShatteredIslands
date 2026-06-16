extends Node

# Classement persistant des runs, stocké en JSON dans user://. Une entrée par run
# terminée (pseudo, héros, rencontres vaincues, temps). Sert les entrées triées
# par rencontres vaincues (décroissant) puis temps (croissant). Pure persistance,
# aucune logique de jeu — alimenté par l'écran de résultat via add_entry().

#region ============================== Constants ==============================
const _SAVE_PATH: String = "user://leaderboard.json"

const KEY_NAME: String = "name"
const KEY_HERO: String = "hero"
const KEY_ENCOUNTERS: String = "encounters_won"
const KEY_TIME: String = "time_seconds"
#endregion


#region ============================== Private variables ==============================
var _entries: Array[Dictionary] = []
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	_load()
#endregion


#region ============================== Public functions ==============================
func add_entry(player_name: String, hero_name: String, encounters_won: int, time_seconds: int) -> void:
	_entries.append({
		KEY_NAME: player_name,
		KEY_HERO: hero_name,
		KEY_ENCOUNTERS: encounters_won,
		KEY_TIME: time_seconds,
	})
	_sort_entries()
	_save()


## Entrées triées (rencontres vaincues décroissant, puis temps croissant). Copie
## défensive : le consommateur ne peut pas muter le stockage interne.
func get_entries() -> Array[Dictionary]:
	return _entries.duplicate(true)


func clear() -> void:
	_entries.clear()
	_save()
#endregion


#region ============================== Private functions ==============================
func _sort_entries() -> void:
	_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var won_a: int = a.get(KEY_ENCOUNTERS, 0)
		var won_b: int = b.get(KEY_ENCOUNTERS, 0)
		if won_a != won_b:
			return won_a > won_b
		return a.get(KEY_TIME, 0) < b.get(KEY_TIME, 0)
	)


func _load() -> void:
	_entries.clear()
	if not FileAccess.file_exists(_SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(_SAVE_PATH, FileAccess.READ)
	if file == null:
		Verbose.error("Leaderboard: échec ouverture " + _SAVE_PATH + " (err=" + str(FileAccess.get_open_error()) + ")", Verbose.Category.SAVE)
		return
	var raw: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(raw)
	if not parsed is Array:
		Verbose.warn("Leaderboard: sauvegarde corrompue, ignorée", Verbose.Category.SAVE)
		return
	for item: Variant in parsed:
		if item is Dictionary:
			_entries.append(_normalize(item))
	_sort_entries()


# Reconstruit une entrée propre et typée depuis le JSON brut (qui ne garde pas le
# typage et peut être édité à la main), pour éviter de propager des champs douteux.
func _normalize(item: Dictionary) -> Dictionary:
	return {
		KEY_NAME: str(item.get(KEY_NAME, "")),
		KEY_HERO: str(item.get(KEY_HERO, "")),
		KEY_ENCOUNTERS: int(item.get(KEY_ENCOUNTERS, 0)),
		KEY_TIME: int(item.get(KEY_TIME, 0)),
	}


func _save() -> void:
	var file: FileAccess = FileAccess.open(_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		Verbose.error("Leaderboard: échec écriture " + _SAVE_PATH + " (err=" + str(FileAccess.get_open_error()) + ")", Verbose.Category.SAVE)
		return
	file.store_string(JSON.stringify(_entries, "\t"))
	file.close()
#endregion
