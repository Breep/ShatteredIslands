class_name FightingArea
extends Node3D

# ============================== Signals ==============================

signal map_clicked(position: Vector3)

# ============================== Private variables ==============================

var _characters: Array[Character] # Array of all characters in the fight scene

# ============================== Local nodes ==============================

@onready var _camera = %Camera3D

@onready var _spawn_manager: SpawnManager = %SpawnManager
@onready var _fighting_manager: FightingManager = %FightingManager
@onready var _map: Node3D

@onready var _ui_countdown: UICountdown = %Countdown

func _ready() -> void:
	if _spawn_manager == null:
		printerr("FightingArea: No SpawnManager")
		return
	
	if _fighting_manager == null:
		printerr("FightingArea: No FightingManager")
		return
	
	if _camera == null:
		printerr("FightingArea: Need a camera")
		return
	
	if not _spawn_manager.start(GameManager.players):
		printerr("FightingArea: Can't start SpawnManager")
		return
	
	_characters = _get_characters()
	if _characters.is_empty():
		printerr("FightingArea: There is no character on scene, there is probably something wrong with the SpawnManager")
		return
	
	_fighting_manager.connect("state_changed", _on_fighting_manager_state_changed)
	_fighting_manager.start()


# Get all characters present on scene
func _get_characters() -> Array[Character]:
	var ret: Array[Character]
	for node in get_tree().get_nodes_in_group("CHARACTER"):
		ret.append(node as Character)
	return ret


func _set_characters_state(state: FightingManager.FightingState) -> void:
	for character in _characters:
		character.set_state(state)


func _on_fighting_manager_state_changed(state: FightingManager.FightingState) -> void:
	_set_characters_state(state)
	if state == FightingManager.FightingState.STARTING:
		_ui_countdown.start(5, "FIGHT") # TODO remonter l'info de la durée du countdown depuis le fightmanager



# TODO Ranger les fonctions du dessous dans un truc plus propre (je sais pas encore quoi)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		select_object(event.position)

func select_object(screen_position):
	if not _camera: return
	# Convert screen position to a ray in 3D
	var ray_origin = _camera.project_ray_origin(screen_position)
	var ray_dir = _camera.project_ray_normal(screen_position)
	
	# Define the ray end position (extend it far enough)
	var ray_end = ray_origin + ray_dir * 1000  # 1000 units ahead
	
	# Perform the raycast
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	if result:
		var selected_object = result.collider
		map_clicked.emit(result.position) # TODO check group, improve raycast to go through characters and others spells
