class_name StackHandlerModule
extends Node

## Centralized stack management module
## Manages all stack types and their periodic updates

#region ============================== Constants ==============================
const IGNITE_MAXHP_PERCENT: float = 0.05
#endregion

#region ============================== Private variables ==============================
var _entity_owner: Entity

# Stack instances
var _poison_stack: SimpleStack = SimpleStack.new()
var _ignite_stack: IgniteStack = IgniteStack.new()
var _shield_stack: ShieldStack = ShieldStack.new()
var _regen_stack: RegenStack = RegenStack.new()
var _necrosis_stack: SimpleStack = SimpleStack.new()
#endregion

#region ============================== Local nodes ==============================
@onready var _poison_tick_timer: Timer = %PoisonTickTimer
@onready var _ignite_tick_timer: Timer = %IgniteTickTimer
@onready var _regen_tick_timer: Timer = %RegenTickTimer
#endregion

#region ============================== Public functions ==============================
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


## Get a stack instance by type
func get_stack(type: Stack.Type) -> Stack:
	match type:
		Stack.Type.POISON: return _poison_stack
		Stack.Type.IGNITE: return _ignite_stack
		Stack.Type.SHIELD: return _shield_stack
		Stack.Type.REGEN: return _regen_stack
		Stack.Type.NECROSIS: return _necrosis_stack
		_:
			printerr("StackHandlerModule: Unknown stack type [", type, "]")
			return null
#endregion

#region ============================== Callbacks functions ==============================
func _on_poison_tick_timer_timeout() -> void:
	if _entity_owner == null: return
	if not multiplayer.is_server(): return
	if _poison_stack.total_stacks > 0:
		_entity_owner.take_damage(_poison_stack.total_stacks, Utils.DamageType.POISON, false, "Poison Periodic")


func _on_ignite_tick_timer_timeout() -> void:
	if _entity_owner == null: return
	if not multiplayer.is_server(): return
	
	# Apply damage
	if _ignite_stack.total_stacks > 0:
		var percent: float = IGNITE_MAXHP_PERCENT * _ignite_stack.total_stacks
		_entity_owner.take_damage_percent(percent, Utils.PercentModifier.MAX_HP, Utils.DamageType.MAGICAL, false, "Ignite Periodic")
	
	# Decay stacks
	_ignite_stack.tick()


func _on_regen_tick_timer_timeout() -> void:
	if _entity_owner == null: return
	if not multiplayer.is_server(): return
	
	# Tick Buffer (Expires old stacks)
	_regen_stack.tick()
	
	# Apply Healing
	if _regen_stack.total_stacks > 0:
		_entity_owner.heal(_entity_owner, _regen_stack.total_stacks, "Regen")
#endregion

