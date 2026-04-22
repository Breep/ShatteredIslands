class_name HeroSimpleInfoPanel2D
extends SimpleInfoPanel2D

## Hero-specific info panel: adds a mana bar, the player name label, and a
## tavern-vs-fight marker switch driven by apply_display_mode().

#region ============================== Export ==============================
@export_group("External Nodes/Hero")
@export var _info_panel_spawn_tavern: Marker3D
#endregion

@onready var _mana_bar: ColorRect = %ManaBar
@onready var _player_name_label: RichTextLabel = %PlayerNameLabel

var _current_spawn: Marker3D


#region ============================== Node base functions ==============================
func _ready() -> void:
	super._ready()

	if _mana_bar and _mana_bar.material:
		_mana_bar.material = _mana_bar.material.duplicate()

	var hero: Hero = _owner_entity as Hero
	if hero == null:
		return

	var stats := hero.stats
	_update_mana_bar(stats.mana, stats.mana_max)
	stats.mana_changed.connect(_on_mana_changed)
	stats.mana_max_changed.connect(_on_mana_max_changed)

	if hero.player != null:
		_player_name_label.text = hero.player.player_name
	else:
		_player_name_label.text = hero.entity_name
#endregion


#region ============================== Public API ==============================
func apply_display_mode(display_mode: Hero.DisplayMode) -> void:
	match display_mode:
		Hero.DisplayMode.BUYING_PHASE:
			_current_spawn = _info_panel_spawn_tavern
			_mana_bar.hide()
		Hero.DisplayMode.FIGHTING_PHASE:
			_current_spawn = _info_panel_spawn
#endregion


#region ============================== Virtual hooks ==============================
func _get_tracked_spawn() -> Marker3D:
	return _current_spawn
#endregion


#region ============================== Private API ==============================
func _update_mana_bar(mana: float, mana_max: float) -> void:
	if not _mana_bar or not _mana_bar.material:
		return
	var ratio: float = 0.0
	if mana_max > 0:
		ratio = clamp(mana / mana_max, 0.0, 1.0)
	_mana_bar.material.set_shader_parameter("HealthAmount", ratio)
#endregion


#region ============================== Callbacks ==============================
func _on_mana_changed(new_mana: float) -> void:
	_update_mana_bar(new_mana, (_owner_entity as Hero).stats.mana_max)


func _on_mana_max_changed(new_mana_max: float) -> void:
	_update_mana_bar((_owner_entity as Hero).stats.mana, new_mana_max)
#endregion
