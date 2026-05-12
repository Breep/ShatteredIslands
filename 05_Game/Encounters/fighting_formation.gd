class_name FightingFormation
extends Resource

var entity_specs: Array[FightingEntitySpec]

func mirrored() -> FightingFormation:
	var copy: FightingFormation = duplicate(true)
	for entity_spec: EntitySpec in copy.entity_specs:
		entity_spec.free_position.x *= -1
		entity_spec.rotation_y *= -1
	return copy


func force_team(team_number: int) -> FightingFormation:
	var copy: FightingFormation = duplicate(true)
	for entity_spec: EntitySpec in copy.entity_specs:
		entity_spec.team = team_number
	return copy
