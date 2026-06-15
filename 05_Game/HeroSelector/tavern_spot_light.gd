class_name TavernSpotLight
extends SpotLight3D

# A stage spotlight that owns its own on/off behavior: it captures its authored
# energy as the "lit" value, starts off, and snaps on/off with an energy tween
# plus an accompanying sound effect.

# ============================== Configuration ==============================

## Duration of the on/off energy tween (kept short to stay punchy).
@export var _snap_duration: float = 0.12
## SFX played on turn_on (empty = silent).
@export var _turn_on_sfx: String = "spotlight"

# ============================== Private vars ==============================

var _lit_energy: float
var _tween: Tween

# ============================== Node base functions ==============================

func _ready() -> void:
	_lit_energy = light_energy
	light_energy = 0.0


# ============================== Public functions ==============================

func turn_on() -> void:
	if not _turn_on_sfx.is_empty():
		AudioManager.play_3d(_turn_on_sfx, global_position)
	_tween_to(_lit_energy)


func turn_off() -> void:
	_tween_to(0.0)


# ============================== Private functions ==============================

func _tween_to(target_energy: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "light_energy", target_energy, _snap_duration)
