class_name PickableModule
extends Node

# ============================== Public variable ==============================

const PICKABLE_META: String = "pickable_module"
var pickable_locked: bool = false # True if the object can't be picked up

# ============================== Export ==============================

@export var _owner: Node3D
@export var _pickable_collider: PickableCollider
@export var _spawn_area_checker: SpawnAreaChecker

# ============================== DEBUG ==============================

@export var _debug: bool = false
var _debug_raycast: MeshInstance3D  # Show the raycast used for the default "can_be_dropped" check
var _debug_impact: MeshInstance3D # Show impact of the raycast in the default "can_be_dropped" check

# ============================== Private variables ==============================

var _is_picked_up: bool = false
var _is_constrained: bool = false
var _is_on_owner_spawn_area: bool = false
var _is_on_other_spawn_area: bool = false

const SPAWN_AREA_MASK: int = 4

# ============================== Node base functions ==============================

func _ready() -> void:
	if _owner == null:
		printerr("ClickableModule: No owner set [", get_path(), "]")
		return
	
	_connect_to_owner()
	if _debug:
		_build_debug_meshs()
	
	if _pickable_collider != null:
		_pickable_collider.overlapped.connect(_on_pickable_collider_overlapped)
		_pickable_collider.freed.connect(_on_pickable_collider_freed)
	
	if _spawn_area_checker != null:
		_spawn_area_checker.team = _owner.team # TODO Maybe find a safer way to do this shit ?
		_spawn_area_checker.owner_team_spawn_area_overlapped.connect(_on_spawn_area_checker_owner_team_spawn_area_overlapped)
		_spawn_area_checker.owner_team_spawn_area_freed.connect(_on_spawn_area_checker_owner_team_spawn_area_freed)
		_spawn_area_checker.other_team_spawn_area_overlapped.connect(_on_spawn_area_checker_other_team_spawn_area_overlapped)
		_spawn_area_checker.other_team_spawn_area_freed.connect(_on_spawn_area_checker_other_team_spawn_area_freed)
	else:
		_is_on_owner_spawn_area = true
	
	Events.game_state_changed.connect(_on_events_game_state_changed)

# ============================== Public functions ==============================

func pick() -> bool:
	
	if _is_picked_up or _is_locked(): return false
	_is_picked_up = true
	return _pick()


func drop() -> bool:
	if not _is_picked_up or _is_locked(): return false
	if _drop():
		print("[DEBUG] Dropped: ", _owner.name)
		_is_picked_up = false
		return true
	else:
		print("[DEBUG] Can't be dropped: ", _owner.name)
		return false

# ============================== Private functions ==============================

func _connect_to_owner() -> void:
	_owner.set_meta(PICKABLE_META, self)


func _pick() -> bool:
	print("[DEBUG] Picked up: ", _owner.name)
	if _owner.has_method("_on_clickable_module_picked"):
		_owner.call("_on_clickable_module_picked")
	return true


func _drop() -> bool:
	print("[DEBUG] Trying to drop: ", _owner.name)
	if _owner.has_method("_on_clickable_module_dropped"): # TODO wtf c'est un peu nimps ici faut changer ça
		_owner.call("_on_clickable_module_dropped")
	return _can_be_dropped()


func _can_be_dropped() -> bool:
	if _owner.has_method("_on_clickable_module_override_can_be_dropped"):
		return _owner.call("_on_clickable_module_override_can_be_dropped")
	return _default_can_be_dropped()


func _is_locked() -> bool:
	if multiplayer.is_server(): return false
	print("Multiplayer authority: ", _owner.get_multiplayer_authority())
	print("Local player id      : ", PlayerManager.get_local_player().id)
	if _owner.get_multiplayer_authority() != PlayerManager.get_local_player().id: return true
	return pickable_locked

# ============================== DEFAULT "can be dropped" check ==============================

func _default_can_be_dropped() -> bool:
	var can_be_dropped: bool = true
	if _is_constrained: can_be_dropped = false
	if not _is_on_owner_spawn_area: can_be_dropped = false
	if _is_on_other_spawn_area: can_be_dropped = false
	return can_be_dropped

# ============================== DEBUG ==============================

func _build_debug_meshs() -> void:
	_build_impact_mesh()
	_build_raycast_mesh()


func _build_impact_mesh() -> void:
	_debug_impact = MeshInstance3D.new()
	
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 0.1
	sphere_mesh.height = 0.2
	sphere_mesh.radial_segments = 16
	sphere_mesh.rings = 8
	
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.4, 0.7) # Pink
	
	sphere_mesh.material = material
	_debug_impact.mesh = sphere_mesh
	_debug_impact.name = "PickableModule_DebugImpact" + str(get_instance_id())


func _build_raycast_mesh() -> void:
	_debug_raycast = MeshInstance3D.new()
	_debug_raycast.mesh = ImmediateMesh.new()
	_debug_raycast.name = "PickableModule_DebugRaycast" + str(get_instance_id())


func _update_debug_raycast(origin: Vector3, end: Vector3, hit: Dictionary) -> void:
	if not _debug: return
	
	if not _debug_impact.is_inside_tree():
		get_tree().root.add_child(_debug_impact)
	if not _debug_raycast.is_inside_tree():
		get_tree().root.add_child(_debug_raycast)
	
	var mesh: ImmediateMesh = _debug_raycast.mesh
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(origin)
	mesh.surface_add_vertex(end)
	mesh.surface_end()
	
	if not hit.is_empty():
		_debug_impact.global_position=hit.position

# ============================== Callback ==============================

func _on_pickable_collider_freed() -> void:
	_is_constrained = false


func _on_pickable_collider_overlapped() -> void:
	_is_constrained = true


func _on_spawn_area_checker_owner_team_spawn_area_overlapped() -> void:
	_is_on_owner_spawn_area = true


func _on_spawn_area_checker_owner_team_spawn_area_freed() -> void:
	_is_on_owner_spawn_area = false


func _on_spawn_area_checker_other_team_spawn_area_overlapped() -> void:
	_is_on_other_spawn_area = true


func _on_spawn_area_checker_other_team_spawn_area_freed() -> void:
	_is_on_other_spawn_area = false


func _on_events_game_state_changed(game_state: Game.GameState) -> void:
	if _spawn_area_checker == null: return
	if game_state == Game.GameState.FIGHTING:
		pickable_locked = false
		_spawn_area_checker.team = _owner.team
	elif game_state == Game.GameState.BUYING:
		pickable_locked = true




 
