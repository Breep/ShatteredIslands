extends Node

# Persistant user settings (cross-session). Backed by a ConfigFile in user://.
# Currently exposes the tutorial enable toggle; future toggles (audio, language...) live here.

#region ============================== Constants ==============================
const _SETTINGS_PATH: String = "user://settings.cfg"

const _SECTION_TUTORIAL: String = "tutorial"
const _KEY_TUTORIAL_ENABLED: String = "enabled"
#endregion


#region ============================== Private variables ==============================
var _config: ConfigFile

## Session-only flag (not persisted): tracks whether the intro cinematic has
## already been shown during this run. Resets on restart so the cinematic plays
## again on every fresh launch — by design while we iterate on it.
var _intro_cinematic_seen: bool = false
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	_config = ConfigFile.new()
	var err: Error = _config.load(_SETTINGS_PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		Verbose.warn("Failed to load settings: " + error_string(err), Verbose.Category.DEFAULT)
#endregion


#region ============================== Public functions ==============================
func is_tutorial_enabled() -> bool:
	return _config.get_value(_SECTION_TUTORIAL, _KEY_TUTORIAL_ENABLED, true)


func set_tutorial_enabled(value: bool) -> void:
	_config.set_value(_SECTION_TUTORIAL, _KEY_TUTORIAL_ENABLED, value)
	_save()


func has_seen_intro_cinematic() -> bool:
	return _intro_cinematic_seen


func mark_intro_cinematic_seen() -> void:
	_intro_cinematic_seen = true
#endregion


#region ============================== Private functions ==============================
func _save() -> void:
	var err: Error = _config.save(_SETTINGS_PATH)
	if err != OK:
		Verbose.error("Failed to save settings: " + error_string(err), Verbose.Category.DEFAULT)
#endregion
