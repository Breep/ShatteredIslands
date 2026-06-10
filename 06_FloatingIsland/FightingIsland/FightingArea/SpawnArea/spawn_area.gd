class_name SpawnArea
extends Area3D

#region ============================== Constants ==============================
# Convention de groupe partagée avec le repérage de drop zone côté DraggableComponent.
const TEAM_GROUP_PREFIX: String = "AREA_TEAM_"
#endregion

#region ============================== Export ==============================
@export var team: int
@export var _highlight_visual_debug: MeshInstance3D
@export var _highlight_zone: MeshInstance3D
@export var _show_debug: bool = false
#endregion



#region ============================== Node base functions ==============================
func _ready() -> void:
	add_to_group(TEAM_GROUP_PREFIX + str(team))
	_make_zone_shader_unique()
	if _highlight_visual_debug != null:
		_highlight_visual_debug.visible = false
	if _highlight_zone != null:
		_highlight_zone.visible = false
	Events.entity_drag_started.connect(_on_entity_drag_started)
	Events.entity_drag_stopped.connect(_on_entity_drag_stopped)
#endregion

#region ============================== Public functions ==============================
func set_highlighted(highlighted: bool) -> void:
	if _highlight_visual_debug != null and _show_debug:
		_highlight_visual_debug.visible = highlighted
#endregion

#region ============================== Private functions ==============================
# Le ZoneMarker partage sa ShaderMaterial entre toutes les SpawnArea (même
# sub-resource). On la duplique en material_override pour que chaque zone ait
# son propre jeu de paramètres de shader.
func _make_zone_shader_unique() -> void:
	if _highlight_zone == null:
		return
	var base_mat: Material = _highlight_zone.get_active_material(0)
	if base_mat != null:
		_highlight_zone.material_override = base_mat.duplicate(true)


func _show_zone(shown: bool) -> void:
	if _highlight_zone != null:
		_highlight_zone.visible = shown
#endregion

#region ============================== Callbacks ==============================
func _on_entity_drag_started(entity: Entity) -> void:
	if entity != null and entity.team == team:
		_show_zone(true)


func _on_entity_drag_stopped(entity: Entity) -> void:
	if entity != null and entity.team == team:
		_show_zone(false)
#endregion
