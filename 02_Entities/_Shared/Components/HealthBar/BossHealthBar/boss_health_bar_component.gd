class_name BossHealthBarComponent
extends HealthBarComponent

## Screen-anchored boss health bar: a large health/shield/block/grid bar pinned to
## the top of the screen with a centered boss-name label and optional phase
## dividers. Reuses the shared HealthBarComponent visuals but, unlike the per-entity
## bars, it is NOT reprojected from a 3D marker — it stays fixed via the scene's
## anchors. Drops the hero-only mana/player-name layer of LargeHealthBar.

@onready var _boss_name_label: RichTextLabel = %BossNameLabel


#region ============================== Node base functions ==============================
func _ready() -> void:
	super._ready()
	if _owner != null and _boss_name_label != null:
		_boss_name_label.text = _owner.entity_name


## Boss bar is pinned to the screen via the scene anchors. Overriding _process to a
## no-op disables the base class' per-frame 3D-marker reprojection.
func _process(_delta: float) -> void:
	pass
#endregion


#region ============================== Public API ==============================
func set_boss_name(boss_name: String) -> void:
	if _boss_name_label != null:
		_boss_name_label.text = boss_name


## Slice the bar into `phase_count` equal segments using the grid bar's big-step
## divider. Recompute after changing the boss' max health.
func setup_phases(phase_count: int) -> void:
	if _grid_bar == null or _grid_bar.material == null:
		return
	if phase_count <= 1 or _owner == null:
		_grid_bar.material.set_shader_parameter("ShowGrid", false)
		return
	var hp_per_phase: int = int(_owner.stats.health_max / float(phase_count))
	setup_grid_bar(0, hp_per_phase)
#endregion
