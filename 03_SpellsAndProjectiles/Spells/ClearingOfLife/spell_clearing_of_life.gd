class_name ClearingOfLife
extends Spell

enum Modifier {
	PERIOD,
	AP_RATIO,
	AD_RATIO,
	CLEANSE_VALUE,
	DURATION,
	RADIUS,
}

#@onready var _hit_zone: Area3D = %HitZone

var _owner: Entity

var _period: float
var _ap_ratio: float
var _ad_ratio: float
var _cleanse_value: float
var _duration: float
var _radius: float

func init(source: Entity, modifiers: Dictionary) -> void:
	_period = modifiers.get(Modifier.PERIOD)
	_ap_ratio = modifiers.get(Modifier.AP_RATIO)
	_ad_ratio = modifiers.get(Modifier.AD_RATIO)
	_cleanse_value = modifiers.get(Modifier.CLEANSE_VALUE)
	_duration = modifiers.get(Modifier.DURATION)
	_radius = modifiers.get(Modifier.RADIUS)
	_owner = source


func _ready() -> void:
	
	_owner.battle_callback_registry.register_periodic(&"Clearing Of Life", _period, func() -> void:
		if _owner == null or not is_instance_valid(_owner): return
		var amount: float = _owner.stats.attack_damage * _ad_ratio/100 + _owner.stats.attack_power * _ap_ratio/100
		var allies: Array[Entity] = _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES, _radius)
		for entity in allies:
			if entity == null or not is_instance_valid(entity): return
			_owner.heal.direct(entity, amount, &"Clearing Of Life")
			_owner.alterations.cleanse(entity, _cleanse_value, &"Clearing Of Life")
			, true
	)
	_owner.battle_callback_registry.register_oneshot(_duration,func() -> void:
		_owner.battle_callback_registry.unregister(&"Clearing Of Life")
		queue_free()
		)
		
	#AudioManager.play_3d("slash_01", _owner.position)

func _process(delta: float) -> void:
	if _owner == null or not is_instance_valid(_owner): return
	global_position = _owner.global_position
	global_rotation = _owner.global_rotation
