class_name ManaComponent
extends EntityComponent

@export_group("Configuration")
@export var _timer_wait_time: float = 0.1

@onready var _mana_tick_timer: Timer = %ManaTickTimer

func _enter_tree() -> void:
	if _owner == null: return
	if _owner.mana != null and _owner.mana != self:
		Verbose.trace("Override: DamageComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.damage.queue_free()
	_owner.mana = self


func _ready() -> void:
	_owner.battle_callback_registry.register_periodic(&"mana", 0.1, _on_mana_tick_timer_timeout)


func start() -> void:
	return
	_mana_tick_timer.start()


func stop() -> void:
	return
	_mana_tick_timer.stop()
	_owner.stats.mana = 0


func _on_mana_tick_timer_timeout() -> void:
	if _owner.stats.mana_max <= 0: return
	var inc: float = _owner.stats.mana_regen * _timer_wait_time
	_owner.stats.mana += inc
	
	if _owner.stats.mana >= _owner.stats.mana_max:
		_owner.skill.cast_ultimate()
		_owner.stats.mana -= _owner.stats.mana_max
