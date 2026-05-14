class_name FightingFormation
extends Formation

@export var entity_specs: Array[FightingEntitySpec]
@export var spawn_point_specs: Array[SpawnPointSpec]

func mirrored() -> FightingFormation:
	var copy: FightingFormation = duplicate(true)
	for entity_spec: FightingEntitySpec in copy.entity_specs:
		entity_spec.free_position.x *= -1
		entity_spec.rotation_y *= -1
	for spawn_spec: SpawnPointSpec in copy.spawn_point_specs:
		spawn_spec.free_position.x *= -1
		spawn_spec.rotation_y *= -1
	return copy


func force_team(team_number: int) -> FightingFormation:
	var copy: FightingFormation = duplicate(true)
	for entity_spec: FightingEntitySpec in copy.entity_specs:
		entity_spec.team = team_number
	return copy
