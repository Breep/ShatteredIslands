class_name ConditionsModule
extends Node

## Manages temporary conditions (stacks) applied to an entity
## Handles stack instances, periodic ticking, and damage/healing logic

#region ============================== Constants ==============================
const IGNITE_MAXHP_PERCENT: float = 0.05
#endregion

#region ============================== Signals ==============================
signal poison_stacks_changed(new_value: float)
signal ignite_stacks_changed(new_value: float)
signal shield_stacks_changed(new_value: float)
signal regen_stacks_changed(new_value: float)
signal necrosis_stacks_changed(new_value: float)
#endregion

#region ============================== Private variables ==============================
var _owner: Entity

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

#region ============================== Public properties ==============================
# Read-only stack accessors
var poison_stacks: float:
	get: return _poison_stack.total_stacks

var ignite_stacks: float:
	get: return _ignite_stack.total_stacks

var shield_stacks: float:
	get: return _shield_stack.total_stacks

var regen_stacks: float:
	get: return _regen_stack.total_stacks

var necrosis_stacks: float:
	get: return _necrosis_stack.total_stacks
#endregion

#region ============================== Public functions ==============================
func init(owner: Entity) -> ConditionsModule:
	_owner = owner
	
	# Connect to stack signals for re-emission
	_poison_stack.stacks_changed.connect(_on_poison_stacks_changed)
	_ignite_stack.stacks_changed.connect(_on_ignite_stacks_changed)
	_shield_stack.stacks_changed.connect(_on_shield_stacks_changed)
	_regen_stack.stacks_changed.connect(_on_regen_stacks_changed)
	_necrosis_stack.stacks_changed.connect(_on_necrosis_stacks_changed)
	
	return self


func start() -> void:
	if _owner == null: return
	if not multiplayer.is_server(): return
	_poison_tick_timer.start()
	_ignite_tick_timer.start()
	_regen_tick_timer.start()


func stop() -> void:
	if _owner == null: return
	if not multiplayer.is_server(): return
	_poison_tick_timer.stop()
	_ignite_tick_timer.stop()
	_regen_tick_timer.stop()


## Get a stack instance by type
func _get_stack(type: Stack.Type) -> Stack:
	match type:
		Stack.Type.POISON: return _poison_stack
		Stack.Type.IGNITE: return _ignite_stack
		Stack.Type.SHIELD: return _shield_stack
		Stack.Type.REGEN: return _regen_stack
		Stack.Type.NECROSIS: return _necrosis_stack
		_:
			Verbose.error("Unknown stack type [" + str(type) + "]", Verbose.Category.ENTITY_MODULE)
			return null


## Add stacks to an entity
func add_stack(stack_type: Stack.Type, value: float, source: Entity, action_id: StringName, mod: Dictionary = {}) -> void:
	var stack = _get_stack(stack_type)
	if stack:
		stack.add_stack(value, source, action_id, mod)


## Remove stacks from an entity
func remove_stack(stack_type: Stack.Type, value: float) -> void:
	var stack = _get_stack(stack_type)
	if stack:
		stack.remove_stack(value)


## Special helper for shield damage reduction
func get_shield_reduced_damage(damage: float, damage_type: Utils.DamageType) -> float:
	if _shield_stack:
		return _shield_stack.get_reduced_damage_taken(damage, damage_type)
	return damage


## Get total number of all stacks
func get_total_stacks() -> float:
	return poison_stacks + ignite_stacks + shield_stacks + regen_stacks + necrosis_stacks


## Get total number of debuff stacks
func get_debuff_stacks() -> float:
	return poison_stacks + ignite_stacks + necrosis_stacks


## Get total number of buff stacks
func get_buff_stacks() -> float:
	return shield_stacks + regen_stacks
#endregion

#region ============================== Timer Callbacks ==============================
func _on_poison_tick_timer_timeout() -> void:
	if _owner == null: return
	if not multiplayer.is_server(): return
	if _poison_stack.total_stacks > 0:
		_owner.take_damage(_poison_stack.total_stacks, Utils.DamageType.POISON, false, "Poison Periodic")


func _on_ignite_tick_timer_timeout() -> void:
	if _owner == null: return
	if not multiplayer.is_server(): return
	
	# Apply damage
	if _ignite_stack.total_stacks > 0:
		var percent: float = IGNITE_MAXHP_PERCENT * _ignite_stack.total_stacks
		_owner.take_damage_percent(percent, Utils.PercentModifier.MAX_HP, Utils.DamageType.MAGICAL, false, "Ignite Periodic")
	
	# Decay stacks
	_ignite_stack.tick()


func _on_regen_tick_timer_timeout() -> void:
	if _owner == null: return
	if not multiplayer.is_server(): return
	
	# Tick Buffer (Expires old stacks)
	_regen_stack.tick()
	
	# Apply Healing
	if _regen_stack.total_stacks > 0:
		_owner.heal(_owner, _regen_stack.total_stacks, "Regen")
#endregion

#region ============================== Signal Re-emission Callbacks ==============================
func _on_poison_stacks_changed(new_value: float) -> void:
	poison_stacks_changed.emit(new_value)


func _on_ignite_stacks_changed(new_value: float) -> void:
	ignite_stacks_changed.emit(new_value)


func _on_shield_stacks_changed(new_value: float) -> void:
	shield_stacks_changed.emit(new_value)


func _on_regen_stacks_changed(new_value: float) -> void:
	regen_stacks_changed.emit(new_value)


func _on_necrosis_stacks_changed(new_value: float) -> void:
	necrosis_stacks_changed.emit(new_value)
#endregion
