class_name SpawnArea
extends Area3D

#region ============================== Constants ==============================
# Convention de groupe partagée avec le repérage de drop zone côté DraggableComponent.
const TEAM_GROUP_PREFIX: String = "AREA_TEAM_"
#endregion

#region ============================== Export ==============================
@export var team: int
@export var _highlight_visual: MeshInstance3D
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	add_to_group(TEAM_GROUP_PREFIX + str(team))
	if _highlight_visual != null:
		_highlight_visual.visible = false
#endregion

#region ============================== Public functions ==============================
func set_highlighted(highlighted: bool) -> void:
	if _highlight_visual != null:
		_highlight_visual.visible = highlighted
#endregion
