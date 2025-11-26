class_name Meteor
extends Node3D

var _on_hit_callbacks: Array

var _entities_inside: Array[Entity] # Array of all character inside the area

var _owner: Entity # Owner of this healing fire area
var _target: Entity
var _damage_percent: float
var _radius: float

const DEPLOY_TIME: float = 2.0 # Time for the metor to fall on the ground (in s)

enum VarType { # Variable types of the callbacks dictionary
	ENTITIES_INSIDE
}

@onready var _deploy_timer: Timer = %DeployTimer

func init(target: Entity, damage_percent: float, radius: float, on_hit_callbacks:Array = [], source: Entity = null) -> void:
	_owner = source
	_target = target
	_damage_percent = damage_percent
	_radius = radius
	_on_hit_callbacks = on_hit_callbacks


func _ready() -> void:
	if _target == null:
		printerr("Meteor: No target assigned to [", get_path(), "]")
		queue_free()
		return
	
	_deploy_timer.wait_time = DEPLOY_TIME
	_deploy_timer.start()
	global_position = _target.global_position
	

func _on_impact_effect_area_body_entered(body: Node3D) -> void:
	if body is Character:
		_entities_inside.append(body)


func _on_impact_effect_area_body_exited(body: Node3D) -> void:
	if body is Character:
		_entities_inside.erase(body)


func _on_deploy_timer_timeout() -> void:
	if _owner == null or _owner.is_queued_for_deletion(): return
	if not multiplayer.is_server(): return
	
	# Deal damage
	for entity in _entities_inside:
		if entity == null or entity.is_queued_for_deletion(): pass
		elif entity.team != _owner.team:
			if _owner != null:
				_owner.direct_attack_percent(entity, _damage_percent, Utils.DamageType.MAGICAL, Utils.PercentModifier.MAX_HP, "Meteor")
			else:
				entity.take_damage_percent(_damage_percent, Utils.PercentModifier.MAX_HP, Utils.DamageType.MAGICAL)
	
	# Do optional stuffs
	for callback in _on_hit_callbacks:
		if callback.is_valid():
			callback.call({
				VarType.ENTITIES_INSIDE: _entities_inside,
			})
	queue_free()
