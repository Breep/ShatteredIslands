class_name HealthBar3DComponent
extends HealthBarComponent

## World-anchored health bar: tracks a 3D Marker and reprojects the panel onto
## the screen every frame so it follows the entity in the fighting area.
## Base for the per-entity Small/Large bars; the screen-pinned Boss bar extends
## HealthBarComponent directly instead.

#region ============================== Export ==============================
@export_group("External Nodes")
@export var _spawn: Marker3D
#endregion

#region ============================== Onready ==============================
@onready var _main_control: Control = %MainControl
#endregion


#region ============================== Node base functions ==============================
func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	var tracked := _get_tracked_spawn()
	if camera != null and tracked != null:
		_main_control.position = camera.unproject_position(tracked.global_position) - Vector2(_main_control.size.x / 2, 0)
#endregion


#region ============================== Virtual hooks ==============================
## Marker tracked in _process to project the panel on screen.
## Heroes override to toggle between fight/tavern markers via apply_display_mode.
func _get_tracked_spawn() -> Marker3D:
	return _spawn
#endregion
