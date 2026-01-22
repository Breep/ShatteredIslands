class_name StackHandlerModule
extends Node

# ============================== Private variables ==============================

var _entity_owner: Entity

var IGNITE_MAXHP_PERCENT: float = 0.05
var IGNITE_DECAY: float = 20.0

# ============================== Local nodes ==============================

@onready var _poison_tick_timer: Timer = %PoisonTickTimer
@onready var _ignite_tick_timer: Timer = %IgniteTickTimer
@onready var _regen_tick_timer: Timer = %RegenTickTimer

# ============================== Public functions ==============================

func init(entity: Entity) -> StackHandlerModule:
	_entity_owner = entity
	return self

func start() -> void:
	if _entity_owner == null: return
	if not multiplayer.is_server(): return
	_poison_tick_timer.start()
	_ignite_tick_timer.start()
	_regen_tick_timer.start()

func stop() -> void:
	if _entity_owner == null: return
	if not multiplayer.is_server(): return
	_poison_tick_timer.stop()
	_ignite_tick_timer.stop()
	_regen_tick_timer.stop()

# ============================== Callbacks functions ==============================

func _on_poison_tick_timer_timeout() -> void:
	if _entity_owner == null: return
	if not multiplayer.is_server(): return
	if _entity_owner.stats.poison_stacks > 0:
		_entity_owner.take_damage(_entity_owner.stats.poison_stacks, Utils.DamageType.POISON, false, "Poison Periodic")


func _on_ignite_tick_timer_timeout() -> void:
	if _entity_owner == null: return
	if _entity_owner.stats.ignite_stacks > 0:
		var percent: float = IGNITE_MAXHP_PERCENT * _entity_owner.stats.ignite_stacks
		_entity_owner.take_damage_percent(percent, Utils.PercentModifier.MAX_HP, Utils.DamageType.MAGICAL, false, "Ignite Periodic")
	
	var decay: int = (_entity_owner.stats.ignite_stacks * IGNITE_DECAY / 100.0) as int
	decay = clampi(decay, 1, decay)
	_entity_owner.stats.ignite_stacks -= decay


func _on_regen_tick_timer_timeout() -> void:
	# Tick Buffer (Expires old stacks)
	_entity_owner.stats.tick_regen()
	
	# Apply Healing
	var regen_stacks: float = _entity_owner.stats.regen_stacks
	if regen_stacks > 0:
		_entity_owner.heal(_entity_owner, regen_stacks, "Regen")
