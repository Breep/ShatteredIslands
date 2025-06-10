class_name SceneSwitcher
extends Node

# ============================== Signals ==============================

#signal camera_changed(camera_type: CameraType)

# ============================== public variables ==============================

@export var buying_island: BuyingIsland
var fighting_islands: Array[FightingIsland]

# ============================== Base node functions ==============================

func _ready() -> void:
	Events.fighting_island_spawned.connect(_on_events_fighting_island_spawned)


func _input(event):
	if event is InputEventKey and event.is_pressed():
		if Input.is_action_pressed("scene_switch_0"): _set_island_active_only(buying_island)
		if Input.is_action_pressed("scene_switch_1"): _set_island_active_only(fighting_islands[0])
		if Input.is_action_pressed("scene_switch_2"): _set_island_active_only(fighting_islands[1])
		if Input.is_action_pressed("scene_switch_3"): _set_island_active_only(fighting_islands[2])
		if Input.is_action_pressed("scene_switch_4"): _set_island_active_only(fighting_islands[3])
		if Input.is_action_pressed("scene_switch_5"): _set_island_active_only(fighting_islands[4])
		if Input.is_action_pressed("scene_switch_6"): _set_island_active_only(fighting_islands[5])
		if Input.is_action_pressed("scene_switch_7"): _set_island_active_only(fighting_islands[6])
		if Input.is_action_pressed("scene_switch_8"): _set_island_active_only(fighting_islands[7])
		if Input.is_action_pressed("change_camera_free_fly"): printerr("Removed for now")

# ============================== Private functions ==============================

func _set_island_active_only(floating_island: FloatingIsland) -> void:
	floating_island.set_active()
	if floating_island != buying_island: buying_island.set_inactive()
	for fighting_island in fighting_islands:
		if floating_island != fighting_island: fighting_island.set_inactive()

# ============================== Callbacks ==============================

func _on_events_fighting_island_spawned(fighting_island_ref: FightingIsland, player_id: int) -> void:
	fighting_islands.append(fighting_island_ref)
