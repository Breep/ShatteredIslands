class_name Cleave
extends Spell

enum Modifier {
	HPMAX,
	AD
}

@onready var _hit_zone: Area3D = %HitZone

var _owner: Entity

var _target_hpmax_percent: float
var _self_ad_percent: float

func init(source: Entity, modifiers: Dictionary) -> void:
	_target_hpmax_percent = modifiers.get(Modifier.HPMAX)
	_self_ad_percent = modifiers.get(Modifier.AD)
	_owner = source


func _ready() -> void:
	global_position = _owner.global_position
	global_rotation = _owner.global_rotation
	await get_tree().physics_frame
	if not is_inside_tree(): return

	for body in _hit_zone.get_overlapping_bodies():
		if not body is Entity: continue
		var entity: Entity = body
		if entity.team == _owner.team: continue

		var damage: float = _self_ad_percent * _owner.stats.attack_damage / 100.0
		damage += _target_hpmax_percent * entity.stats.health_max / 100.0
		_owner.damage.direct(entity, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"Cleave")

	AudioManager.play_3d("slash_01", _owner.position)
	await get_tree().create_timer(1.0).timeout
	queue_free()
