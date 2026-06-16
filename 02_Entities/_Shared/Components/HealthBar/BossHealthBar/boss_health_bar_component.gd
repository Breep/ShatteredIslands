class_name BossHealthBarComponent
extends HealthBarComponent

## Screen-anchored boss health bar: a large health/shield/block/grid bar pinned to
## the top of the screen with a centered boss-name label and optional phase
## dividers. Reuses the shared HealthBarComponent visuals; it stays fixed via the
## scene's anchors and, unlike the per-entity bars, extends the marker-less base
## directly (no 3D reprojection). Drops the hero-only mana/player-name layer of
## LargeHealthBar.

@onready var _boss_name_label: RichTextLabel = %BossNameLabel

# Remembered so the dividers can be recomputed on every health_max change: the grid
# works in absolute HP, but the caller asks in phases — and health_max may land after
# this _ready (late stat init) or move at runtime (max-HP buffs).
var _phase_count: int = 1


#region ============================== Node base functions ==============================
func _ready() -> void:
	super._ready()
	if _owner != null:
		if _boss_name_label != null:
			_boss_name_label.text = _owner.entity_name
		_owner.stats.health_max_changed.connect(func(_new_max: float) -> void: _apply_phases())
#endregion


#region ============================== Public API ==============================
func set_boss_name(boss_name: String) -> void:
	if _boss_name_label != null:
		_boss_name_label.text = boss_name


## Slice the bar into `phase_count` equal segments using the grid bar's big-step
## divider. The dividers re-derive themselves on every health_max change.
func setup_phases(phase_count: int) -> void:
	_phase_count = phase_count
	_apply_phases()
#endregion


#region ============================== Private API ==============================
func _apply_phases() -> void:
	if _grid_bar == null or _grid_bar.material == null:
		return
	if _phase_count <= 1 or _owner == null or _owner.stats.health_max <= 0.0:
		_grid_bar.material.set_shader_parameter("ShowGrid", false)
		return
	var hp_per_phase: int = int(_owner.stats.health_max / float(_phase_count))
	setup_grid_bar(0, hp_per_phase)
#endregion
