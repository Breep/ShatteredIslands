class_name ConditionsModule
extends Module

## Manages temporary conditions (stacks) applied to an entity
## Handles stack instances, periodic ticking via deterministic tick counters

#region ============================== Constants ==============================
const TICKS_PER_SECOND: int = 60
const IGNITE_MAXHP_PERCENT: float = 0.03 # IGNITE DAMAGE

# Tick intervals for periodic effects (in seconds, converted to ticks)
const POISON_TICK_INTERVAL: float = 1.0
const IGNITE_TICK_INTERVAL: float = 1.0
const REGEN_TICK_INTERVAL: float = 1.0
#endregion

#region ============================== Signals ==============================
signal poison_stacks_changed(new_value: float)
signal ignite_stacks_changed(new_value: float)
signal shield_stacks_changed(new_value: float)
signal regen_stacks_changed(new_value: float)
signal necrosis_stacks_changed(new_value: float)
signal shield_stack_broken(amount: float)
#endregion

#region ============================== Private variables ==============================
var _poison_stack: SimpleStack = SimpleStack.new()
var _ignite_stack: IgniteStack = IgniteStack.new()
var _shield_stack: ShieldStack = ShieldStack.new()
var _regen_stack: RegenStack = RegenStack.new()
var _necrosis_stack: SimpleStack = SimpleStack.new()

# Tick-based timing (deterministic)
var _poison_interval_ticks: int = int(POISON_TICK_INTERVAL * TICKS_PER_SECOND)
var _ignite_interval_ticks: int = int(IGNITE_TICK_INTERVAL * TICKS_PER_SECOND)
var _regen_interval_ticks: int = int(REGEN_TICK_INTERVAL * TICKS_PER_SECOND)

var _poison_ticks_remaining: int = 0
var _ignite_ticks_remaining: int = 0
var _regen_ticks_remaining: int = 0

var _is_active: bool = false
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
func init(entity_owner: Entity) -> ConditionsModule:
	super.init(entity_owner)
	
	# Connect to stack signals for re-emission
	_poison_stack.stacks_changed.connect(_on_poison_stacks_changed)
	_ignite_stack.stacks_changed.connect(_on_ignite_stacks_changed)
	_shield_stack.stacks_changed.connect(_on_shield_stacks_changed)
	_regen_stack.stacks_changed.connect(_on_regen_stacks_changed)
	_necrosis_stack.stacks_changed.connect(_on_necrosis_stacks_changed)
	_shield_stack.shield_stack_broken.connect(_on_shield_stack_broken)
	
	return self


func start() -> void:
	if _owner == null: return
	_is_active = true
	_poison_ticks_remaining = _poison_interval_ticks
	_ignite_ticks_remaining = _ignite_interval_ticks
	_regen_ticks_remaining = _regen_interval_ticks


func stop() -> void:
	if _owner == null: return
	_is_active = false


## Called every physics tick by Entity.process_tick() (deterministic, fixed 1/60s step).
func process_tick() -> void:
	if not _is_active:
		return
	if _owner == null:
		return
	
	# Poison tick
	_poison_ticks_remaining -= 1
	if _poison_ticks_remaining <= 0:
		_poison_ticks_remaining = _poison_interval_ticks
		if _poison_stack.total_stacks > 0:
			_owner.take_damage(_poison_stack.total_stacks, Utils.ActionType.DAMAGE_POISON, false, "Poison Periodic")
	
	# Ignite tick
	_ignite_ticks_remaining -= 1
	if _ignite_ticks_remaining <= 0:
		_ignite_ticks_remaining = _ignite_interval_ticks
		if _ignite_stack.total_stacks > 0:
			var percent: float = IGNITE_MAXHP_PERCENT * _ignite_stack.total_stacks
			_owner.take_damage_percent(percent, Utils.PercentModifier.MAX_HP, Utils.ActionType.DAMAGE_MAGICAL, false, "Ignite Periodic")
		_ignite_stack.tick()
	
	# Regen tick
	_regen_ticks_remaining -= 1
	if _regen_ticks_remaining <= 0:
		_regen_ticks_remaining = _regen_interval_ticks
		_regen_stack.tick()
		if _regen_stack.total_stacks > 0:
			_owner.heal(_owner, _regen_stack.total_stacks, "Regen")


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


## Get the shield stack instance for configuration (e.g., setting efficiencies)
func get_shield_stack() -> ShieldStack:
	return _shield_stack


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
func get_shield_reduced_damage(damage: float, damage_type: Utils.ActionType) -> float:
	if _shield_stack:
		return _shield_stack.get_reduced_damage_taken(damage, damage_type, _owner.battle_id)
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


func _on_shield_stack_broken(amount: float) -> void:
	shield_stack_broken.emit(amount)
#endregion
