class_name Meteor
extends Spell

enum Modifier {
	DAMAGE_PERCENT,
	RADIUS,
	ON_HIT_CALLBACKS,
	ON_CAST_CALLBACKS,
	DAMAGE_FLAT
}

var _on_hit_callbacks: Array

var _owner: Entity # Owner of this healing fire area
var _target: Entity
var _spawn_position: Vector3
var _use_position: bool = false # falls on _spawn_position instead of a target entity
var _damage_percent: float
var _damage_flat: float
var _radius: float

const DEPLOY_TIME: float = 1.3 # Time for the metor to fall on the ground (in s)

enum VarType { # Variable types of the callbacks dictionary
	ENTITIES_INSIDE,
	DAMAGE_PERCENT,
	POSITION
}

@onready var _deploy_timer: Timer = %DeployTimer
@onready var _impact_area: Area3D = %ImpactEffectArea

@onready var _meteor_visual: Node3D = %MeteorVisual

func init(target: Entity, damage_flat: float, damage_percent: float, radius: float, on_hit_callbacks: Array = [], source: Entity = null) -> void:
	_owner = source
	_target = target
	_damage_flat = damage_flat
	_damage_percent = damage_percent
	_radius = radius
	_on_hit_callbacks = on_hit_callbacks


## Variant that falls on a fixed world position instead of a target entity.
func init_at_position(position: Vector3, damage_flat: float, damage_percent: float, radius: float, on_hit_callbacks: Array = [], source: Entity = null) -> void:
	_owner = source
	_spawn_position = position
	_use_position = true
	_damage_flat = damage_flat
	_damage_percent = damage_percent
	_radius = radius
	_on_hit_callbacks = on_hit_callbacks


func _ready() -> void:
	if not _use_position and _target == null:
		printerr("Meteor: No target/position assigned to [", get_path(), "]")
		queue_free()
		return

	_deploy_timer.wait_time = DEPLOY_TIME
	_deploy_timer.start()
	global_position = _spawn_position if _use_position else _target.global_position
	_meteor_visual.spells_node = spells_node
	AudioManager.play_3d("meteor", global_position, 0.95)


func _on_deploy_timer_timeout() -> void:
	if _owner == null or _owner.is_queued_for_deletion(): return
	if not multiplayer.is_server(): return

	var _entities_inside: Array[Entity]
	for body in _impact_area.get_overlapping_bodies():
		if body is Entity:
			_entities_inside.append(body)
	AudioManager.play_3d("meteor_impact", global_position, 0.95)
	# Deal damage
	for entity in _entities_inside:
		if entity == null or entity.is_queued_for_deletion(): pass
		elif entity.team != _owner.team:
			var meteor_damage: float = _damage_flat #TODO: Add a direct_damage that can have flat and % ?
			meteor_damage += (entity.stats.health_max * _damage_percent) / 100
			if _owner != null:
				_owner.damage.direct(entity, meteor_damage, Utils.ActionType.DAMAGE_MAGICAL, "Meteor")
			else:
				entity.damage.take(meteor_damage, Utils.ActionType.DAMAGE_MAGICAL, false, "Meteor")
	
	# Do optional stuffs
	for callback in _on_hit_callbacks:
		if callback.is_valid():
			callback.call({
				VarType.ENTITIES_INSIDE: _entities_inside,
				VarType.DAMAGE_PERCENT: _damage_percent,
				VarType.POSITION: global_position
			})
	queue_free()
