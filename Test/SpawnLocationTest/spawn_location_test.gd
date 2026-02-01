extends Node3D

## Test script for the spawn location system
## This script demonstrates all spawn location types

@export var arena_zone_manager: ArenaZoneManager
@export var test_entity: Node3D

var test_markers: Array[MeshInstance3D] = []

func _ready() -> void:
	print("=== Spawn Location System Test ===")
	if arena_zone_manager == null:
		printerr("ArenaZoneManager not assigned!")
		return
	
	# Wait a frame for initialization
	await get_tree().process_frame
	_run_tests()


func _run_tests() -> void:
	print("\n--- Test 1: Exact Position ---")
	_test_exact_position()
	
	print("\n--- Test 2: Arena Center ---")
	_test_arena_center()
	
	print("\n--- Test 3: Team Zone (Team 0) ---")
	_test_team_zone(0)
	
	print("\n--- Test 4: Team Zone (Team 1) ---")
	_test_team_zone(1)
	
	print("\n--- Test 5: Entity Relative ---")
	_test_entity_relative()
	
	print("\n--- Test 6: Random Arena ---")
	_test_random_arena()
	
	print("\n--- Test 7: Randomization Radius ---")
	_test_randomization()
	
	print("\n=== All Tests Complete ===")


func _test_exact_position() -> void:
	var config := SpawnLocationConfig.create_exact(Vector3(5, 0, 5))
	var pos := config.resolve(arena_zone_manager, 0)
	print("Exact position (5, 0, 5): ", pos)
	_create_marker(pos, Color.RED)


func _test_arena_center() -> void:
	var config := SpawnLocationConfig.create_arena_center()
	var pos := config.resolve(arena_zone_manager, 0)
	print("Arena center: ", pos)
	_create_marker(pos, Color.YELLOW)


func _test_team_zone(team: int) -> void:
	var config := SpawnLocationConfig.create_team_zone(team)
	var pos := config.resolve(arena_zone_manager, 0)
	print("Team ", team, " zone: ", pos)
	var color := Color.BLUE if team == 0 else Color.GREEN
	_create_marker(pos, color)


func _test_entity_relative() -> void:
	if test_entity == null:
		print("No test entity assigned, skipping")
		return
	
	var config := SpawnLocationConfig.create_entity_relative(test_entity)
	var pos := config.resolve(arena_zone_manager, 0)
	print("Entity relative (", test_entity.name, "): ", pos)
	_create_marker(pos, Color.MAGENTA)


func _test_random_arena() -> void:
	var config := SpawnLocationConfig.create_random_arena()
	var pos := config.resolve(arena_zone_manager, 0)
	print("Random arena: ", pos)
	_create_marker(pos, Color.CYAN)


func _test_randomization() -> void:
	var config := SpawnLocationConfig.create_exact(Vector3(0, 0, 0), 3.0)
	print("Testing randomization with radius 3.0 around (0,0,0):")
	for i in 5:
		var pos := config.resolve(arena_zone_manager, 0)
		print("  Sample ", i + 1, ": ", pos)
		_create_marker(pos, Color.ORANGE)


func _create_marker(position: Vector3, color: Color) -> void:
	var marker := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.3
	sphere.height = 0.6
	marker.mesh = sphere
	
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2.0
	marker.set_surface_override_material(0, material)
	
	marker.position = position
	add_child(marker)
	test_markers.append(marker)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			print("\n=== Rerunning Tests ===")
			_clear_markers()
			_run_tests()
		elif event.keycode == KEY_C:
			print("\n=== Clearing Markers ===")
			_clear_markers()


func _clear_markers() -> void:
	for marker in test_markers:
		marker.queue_free()
	test_markers.clear()
