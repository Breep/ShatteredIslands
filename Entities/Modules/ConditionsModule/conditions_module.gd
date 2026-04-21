class_name AlterationsModule
extends Module

## Unified module for every Alteration on an entity — both stackable
## (Poison, Ignite, Shield, Regen, Necrosis, Defense, Block, Thorn, Strength,
## Weakness, Vulnerability) and timed (Stun, Silence, Taunt, Invulnerable,
## Untargetable).
##
## Phase 3b rework: absorbs the former ConditionsModule + StatusModule into a
## single concrete Module. Timer nodes for timed alterations_module are created
## dynamically in init() (the .tscn keeps a bare script node).

#region ============================== Constants ==============================
const TICKS_PER_SECOND: int = 60
const IGNITE_MAXHP_PERCENT: float = 0.03 # IGNITE DAMAGE

# Tick intervals for periodic effects (in seconds, converted to ticks)
const POISON_TICK_INTERVAL: float = 1.0
const IGNITE_TICK_INTERVAL: float = 1.0
const REGEN_TICK_INTERVAL: float = 1.0

# Timed alteration side-effects
const TAUNT_DEFENCE_BONUS: float = 30.0
#endregion

#region ============================== Signals ==============================
# Stackable alterations_module
signal poison_stacks_changed(new_value: float)
signal ignite_stacks_changed(new_value: float)
signal shield_stacks_changed(new_value: float)
signal regen_stacks_changed(new_value: float)
signal necrosis_stacks_changed(new_value: float)
signal shield_stack_broken(amount: float)
signal defense_stacks_changed(new_value: float)
signal block_stacks_changed(new_value: float)
signal thorn_stacks_changed(new_value: float)

# Timed alterations_module (formerly StatusModule)
signal stunned_changed(is_active: bool, duration: float, infinite: bool)
signal taunted_changed(is_active: bool, duration: float, infinite: bool)
signal silenced_changed(is_active: bool, duration: float, infinite: bool)
signal invulnerable_changed(is_active: bool, duration: float, infinite: bool)
signal untargetable_changed(is_active: bool, duration: float, infinite: bool)
#endregion

#region ============================== Private variables ==============================
# ---- Stackable alterations_module ----
var _poison_stack: SimpleStack = SimpleStack.new()
var _ignite_stack: IgniteStack = IgniteStack.new()
var _shield_stack: ShieldStack = ShieldStack.new()
var _regen_stack: RegenStack = RegenStack.new()
var _necrosis_stack: SimpleStack = SimpleStack.new()

# Phase 7: Necrosis drives RESISTANCE[UTILITY_HEAL] (heal reduction).
# StatModifier ADD maintained in sync with _necrosis_stack.total_stacks.
var _necrosis_heal_resistance_mod: StatModifier

# Rework alterations_module (Phase 4): Defense/Block/Thorn are alterations_module, not
# EntityStats entries.
var _defense_alteration: DefenseAlteration = DefenseAlteration.new()
var _block_alteration: BlockAlteration = BlockAlteration.new()
var _thorn_alteration: ThornAlteration = ThornAlteration.new()

# Phase 5 rework: Strength/Weakness/Vulnerability stackable alterations_module
# (typed per ActionType).
var _strength_alteration: StrengthAlteration = StrengthAlteration.new()
var _weakness_alteration: WeaknessAlteration = WeaknessAlteration.new()
var _vulnerability_alteration: VulnerabilityAlteration = VulnerabilityAlteration.new()

# Tick-based timing (deterministic)
var _poison_interval_ticks: int = int(POISON_TICK_INTERVAL * TICKS_PER_SECOND)
var _ignite_interval_ticks: int = int(IGNITE_TICK_INTERVAL * TICKS_PER_SECOND)
var _regen_interval_ticks: int = int(REGEN_TICK_INTERVAL * TICKS_PER_SECOND)

var _poison_ticks_remaining: int = 0
var _ignite_ticks_remaining: int = 0
var _regen_ticks_remaining: int = 0

var _is_active: bool = false

# ---- Timed alterations_module (formerly StatusModule) ----
var _taunt_defence_active: bool = false
var _timers: Dictionary[Status.Type, Timer] = {}
var _infinite_status: Dictionary[Status.Type, bool] = {
	Status.Type.STUN: false,
	Status.Type.TAUNT: false,
	Status.Type.SILENCE: false,
	Status.Type.INVULNERABLE: false,
	Status.Type.UNTARGETABLE: false
}
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

var defense_stacks: float:
	get: return _defense_alteration.total_stacks

var block_stacks: float:
	get: return _block_alteration.total_stacks

var thorn_stacks: float:
	get: return _thorn_alteration.total_stacks
#endregion

#region ============================== Public functions ==============================
func init(entity_owner: Entity) -> AlterationsModule:
	super.init(entity_owner)

	# Stack signals re-emission
	_poison_stack.stacks_changed.connect(_on_poison_stacks_changed)
	_ignite_stack.stacks_changed.connect(_on_ignite_stacks_changed)
	_shield_stack.stacks_changed.connect(_on_shield_stacks_changed)
	_regen_stack.stacks_changed.connect(_on_regen_stacks_changed)
	_necrosis_stack.stacks_changed.connect(_on_necrosis_stacks_changed)
	_shield_stack.shield_stack_broken.connect(_on_shield_stack_broken)

	# Phase 4 alterations_module
	_defense_alteration.bind(entity_owner)
	_defense_alteration.stacks_changed.connect(_on_defense_stacks_changed)
	_block_alteration.stacks_changed.connect(_on_block_stacks_changed)
	_thorn_alteration.stacks_changed.connect(_on_thorn_stacks_changed)

	# Phase 5 alterations_module
	_strength_alteration.bind(entity_owner)
	_weakness_alteration.bind(entity_owner)
	_vulnerability_alteration.bind(entity_owner)

	# Timed alterations_module infrastructure (formerly StatusModule)
	_create_status_timers()
	taunted_changed.connect(_on_taunt_defence_update)

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


## Alterations accessors (Phase 4 rework)
func get_block_alteration() -> BlockAlteration:
	return _block_alteration


func get_thorn_alteration() -> ThornAlteration:
	return _thorn_alteration


func get_defense_alteration() -> DefenseAlteration:
	return _defense_alteration


func add_defense_stacks(amount: float) -> float:
	return _defense_alteration.add_stack(amount)


func remove_defense_stacks(amount: float) -> float:
	return _defense_alteration.remove_stack(amount)


func add_block_stacks(amount: float) -> float:
	return _block_alteration.add_stack(amount)


func remove_block_stacks(amount: float) -> float:
	return _block_alteration.remove_stack(amount)


func add_thorn_stacks(amount: float) -> float:
	return _thorn_alteration.add_stack(amount)


func remove_thorn_stacks(amount: float) -> float:
	return _thorn_alteration.remove_stack(amount)


func add_strength_stacks(action_type: Utils.ActionType, amount: float) -> float:
	return _strength_alteration.add_stack(action_type, amount)


func remove_strength_stacks(action_type: Utils.ActionType, amount: float) -> float:
	return _strength_alteration.remove_stack(action_type, amount)


func add_weakness_stacks(action_type: Utils.ActionType, amount: float) -> float:
	return _weakness_alteration.add_stack(action_type, amount)


func remove_weakness_stacks(action_type: Utils.ActionType, amount: float) -> float:
	return _weakness_alteration.remove_stack(action_type, amount)


func add_vulnerability_stacks(action_type: Utils.ActionType, amount: float) -> float:
	return _vulnerability_alteration.add_stack(action_type, amount)


func remove_vulnerability_stacks(action_type: Utils.ActionType, amount: float) -> float:
	return _vulnerability_alteration.remove_stack(action_type, amount)


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


# ---- Timed alterations_module (formerly StatusModule) ----

func has_status(status_type: Status.Type) -> bool:
	return _infinite_status[status_type] or _timers[status_type].time_left > 0


func get_remaining_time(status_type: Status.Type) -> float:
	return _timers[status_type].time_left


func add_status(status_type: Status.Type, duration: float) -> void:
	if duration == -1:
		_infinite_status[status_type] = true
		_timers[status_type].stop()
		_emit_status_changed(status_type, true, 0.0, true)
		return

	if _infinite_status[status_type] == true or duration <= _timers[status_type].time_left:
		return

	_timers[status_type].stop()
	_timers[status_type].wait_time = duration
	_timers[status_type].start()
	_emit_status_changed(status_type, true, duration, false)


func remove_status(status_type: Status.Type) -> void:
	_timers[status_type].stop()
	_infinite_status[status_type] = false
	_emit_status_changed(status_type, false, 0.0, false)
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
	_sync_necrosis_heal_resistance(new_value)
	necrosis_stacks_changed.emit(new_value)


## Phase 7: Necrosis pushes a StatModifier ADD on RESISTANCE[UTILITY_HEAL]
## so heal receive `(100+EXPOSURE_HEAL)/(100+RESISTANCE_HEAL)` accounts for it.
func _sync_necrosis_heal_resistance(new_value: float) -> void:
	if _owner == null or _owner.stat_modifiers_registry == null: return
	if new_value <= 0:
		if _necrosis_heal_resistance_mod != null:
			_owner.stat_modifiers_registry.unregister_modifier(_necrosis_heal_resistance_mod)
			_necrosis_heal_resistance_mod = null
		return
	if _necrosis_heal_resistance_mod == null:
		_necrosis_heal_resistance_mod = StatModifier.new()
		_necrosis_heal_resistance_mod.id = &"Necrosis"
		_necrosis_heal_resistance_mod.stat_type = EntityStats.StatType.RESISTANCE
		_necrosis_heal_resistance_mod.action_type = Utils.ActionType.UTILITY_HEAL
		_necrosis_heal_resistance_mod.calc_type = StatModifier.CalcType.ADD
		_necrosis_heal_resistance_mod.tags = []
	_necrosis_heal_resistance_mod.value = new_value
	_owner.stat_modifiers_registry.register_modifier(_necrosis_heal_resistance_mod)


func _on_shield_stack_broken(amount: float) -> void:
	shield_stack_broken.emit(amount)


func _on_defense_stacks_changed(new_value: float) -> void:
	defense_stacks_changed.emit(new_value)


func _on_block_stacks_changed(new_value: float) -> void:
	block_stacks_changed.emit(new_value)


func _on_thorn_stacks_changed(new_value: float) -> void:
	thorn_stacks_changed.emit(new_value)
#endregion

#region ============================== Timed alteration internals ==============================
func _create_status_timers() -> void:
	for status_type in [Status.Type.STUN, Status.Type.TAUNT, Status.Type.SILENCE,
			Status.Type.INVULNERABLE, Status.Type.UNTARGETABLE]:
		var timer := Timer.new()
		timer.one_shot = true
		timer.timeout.connect(_on_status_timer_timeout.bind(status_type))
		add_child(timer)
		_timers[status_type] = timer


func _emit_status_changed(status_type: Status.Type, is_active: bool, duration: float, infinite: bool) -> void:
	match status_type:
		Status.Type.STUN: stunned_changed.emit(is_active, duration, infinite)
		Status.Type.TAUNT: taunted_changed.emit(is_active, duration, infinite)
		Status.Type.SILENCE: silenced_changed.emit(is_active, duration, infinite)
		Status.Type.INVULNERABLE: invulnerable_changed.emit(is_active, duration, infinite)
		Status.Type.UNTARGETABLE: untargetable_changed.emit(is_active, duration, infinite)


func _on_taunt_defence_update(is_active: bool, _duration: float, _infinite: bool) -> void:
	# Phase 4 rework: DEFENCE is now a DefenseAlteration stack applied on self.
	if is_active and not _taunt_defence_active:
		add_defense_stacks(TAUNT_DEFENCE_BONUS)
		_taunt_defence_active = true
	elif not is_active and _taunt_defence_active:
		remove_defense_stacks(TAUNT_DEFENCE_BONUS)
		_taunt_defence_active = false


func _on_status_timer_timeout(status_type: Status.Type) -> void:
	remove_status(status_type)
#endregion
