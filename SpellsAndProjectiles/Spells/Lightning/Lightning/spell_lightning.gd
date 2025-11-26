class_name SpellLightning
extends Node3D

const LIFETIME: float = 1.0

var _source: Entity
var _target: Entity
var _damage: float

func init(source: Entity, target: Entity, damage: float) -> void:
	_source = source
	_target = target
	_damage = damage


func _ready() -> void:
	if _target == null or _target.is_queued_for_deletion():
		push_warning("SpellThunder: No valid target")
		queue_free()
		return
	
	global_position = _target.global_position
	
	if _source != null:
		_source.direct_attack(_target, _damage / 2.0, Utils.DamageType.PHYSICAL, "Lightning")
		_source.direct_attack(_target, _damage / 2.0, Utils.DamageType.MAGICAL, "Lightning")
	else:
		_target.take_damage(_damage / 2.0, Utils.DamageType.PHYSICAL)
		_target.take_damage(_damage / 2.0, Utils.DamageType.MAGICAL)
	
	var tween := create_tween()
	tween.tween_interval(LIFETIME)
	tween.finished.connect(queue_free)
