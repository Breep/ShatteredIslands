class_name SpawnAreaChecker
extends Area3D

# Check if the pickable is on a right spawn area
# Can only be used with Pickable with an owner with a team

signal owner_team_spawn_area_overlapped()
signal owner_team_spawn_area_freed()
signal other_team_spawn_area_overlapped()
signal other_team_spawn_area_freed()

var team: int = -1

var _other_team_spawn_area_overlapping_counter: int = 0: # Number of pickable constraint currently overlapping
	get: return _other_team_spawn_area_overlapping_counter
	set(value):
		if value != _other_team_spawn_area_overlapping_counter:
			_other_team_spawn_area_overlapping_counter = value
			if _other_team_spawn_area_overlapping_counter > 0:
				show()
				other_team_spawn_area_overlapped.emit()
			else:
				hide()
				other_team_spawn_area_freed.emit()

var _owner_team_spawn_area_overlapping_counter: int = 0: # Number of pickable constraint currently overlapping
	get: return _owner_team_spawn_area_overlapping_counter
	set(value):
		if value != _owner_team_spawn_area_overlapping_counter:
			_owner_team_spawn_area_overlapping_counter = value
			if _owner_team_spawn_area_overlapping_counter > 0:
				owner_team_spawn_area_overlapped.emit()
			else:
				owner_team_spawn_area_freed.emit()


func _ready() -> void:
	hide()
	_set_inactive()


func _set_active() -> void:
	monitoring = true
	_reset()


func _set_inactive() -> void:
	monitoring = false
	_reset()


func _reset() ->void:
	hide()
	_owner_team_spawn_area_overlapping_counter = 0
	_other_team_spawn_area_overlapping_counter = 0


func _on_area_entered(area: Area3D) -> void:
	if not area is SpawnArea:
		printerr("A non SPawnArea area is using the SpawnArea mask: ", area.get_path())
		return
	var spawn_area: SpawnArea = area
	if spawn_area.team == team:
		_owner_team_spawn_area_overlapping_counter += 1
	else:
		_other_team_spawn_area_overlapping_counter += 1


func _on_area_exited(area: Area3D) -> void:
	if not area is SpawnArea:
		printerr("A non SpawnArea area is using the SpawnArea mask: ", area.get_path())
		return
	var spawn_area: SpawnArea = area
	if spawn_area.team == team:
		_owner_team_spawn_area_overlapping_counter -= 1
	else:
		_other_team_spawn_area_overlapping_counter -= 1


