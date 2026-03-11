class_name ContagionSpellArea
extends Node3D

var _entity_owner: Entity

# Contagion debuf variables
var _radius: float
var _spread_percent: float

func init(entity_owner: Entity, radius: float, spread_percent: float) -> void:
	_entity_owner = entity_owner
	_radius = radius
	_spread_percent = spread_percent

func _on_scanner_area_body_entered(body: Node3D) -> void:
	if not body is Entity:
		push_error("EntityManager: A body detected has an Entity mask but is not an entity: [", body.get_path(), "]")
		return
	var entity: Entity = body
	entity.died.connect(_on_enemy_died.bind(entity))


func _on_scanner_area_body_exited(_body: Node3D) -> void:
	pass


func _on_enemy_died(victim: Entity) -> void:
	if victim == null or victim.is_queued_for_deletion(): return
	if _entity_owner == null or victim.is_queued_for_deletion():
		queue_free()
		return
	if victim.team == _entity_owner.team: return
	
	var poison_stacks: int = int(float(victim.conditions.poison_stacks) * _spread_percent / 100.0)
	if poison_stacks <= 0: return
	
	var targets: Array[Entity] = victim.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES, _radius)
	for target in targets:
		target.take_condition_stacks(poison_stacks, Utils.StackType.POISON, false, "Contagion")
