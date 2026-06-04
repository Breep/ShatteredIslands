class_name AlterationsComponent
extends EntityComponent

## Unified module for every Alteration on an entity.
## Alterations are held in a `Alteration.Type → Alteration` dictionary;
## process_tick is delegated to each instance. Hot-path consumers
## (damage pipeline) read `shield_alteration`, `block_alteration`,
## `thorn_alteration` directly — everything else goes through the generic API.

const TICKS_PER_SECOND: int = Alteration.TICKS_PER_SECOND

## Single aggregate signal. `payload` depends on the alteration type:
## - StackAlteration: new stack count (float)
## - TimedAlteration: new time_left (float); is_infinite readable on the instance
## For finer-grained events (shield_broken, expired), subscribe to the
## Alteration instance directly via `get_alteration(type)`.
signal alteration_changed(type: Alteration.Type, payload: Variant)

# Stack-count change signals (UI-facing; re-emitted from the underlying alteration)
signal ignite_stacks_changed(new_stacks: float)
signal poison_stacks_changed(new_stacks: float)
signal necrosis_stacks_changed(new_stacks: float)
signal shield_stacks_changed(new_stacks: float)
signal regen_stacks_changed(new_stacks: float)
signal block_stacks_changed(new_stacks: float)
signal defense_stacks_changed(new_stacks: float)
signal thorn_stacks_changed(new_stacks: float)

# Timed on/off signals (UI-facing; fire only on transitions, with duration + infinite)
signal stunned_changed(is_active: bool, duration: float, infinite: bool)
signal taunted_changed(is_active: bool, duration: float, infinite: bool)
signal silenced_changed(is_active: bool, duration: float, infinite: bool)
signal invulnerable_changed(is_active: bool, duration: float, infinite: bool)
signal untargetable_changed(is_active: bool, duration: float, infinite: bool)

var _alterations: Dictionary[Alteration.Type, Alteration] = {}
var _alterations_list: Array[Alteration] = []

var _is_active: bool = false

# Hot-path references (avoid dict lookup on every hit)
var shield_alteration: ShieldAlteration
var block_alteration: BlockAlteration
var thorn_alteration: ThornAlteration

func _enter_tree() -> void:
	if _owner == null: return
	if _owner.alterations != null and _owner.alterations != self:
		Verbose.trace("Override: AlterationsComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.alterations.queue_free()
	_owner.alterations = self
	_build_alterations()


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.alterations != self:
		return

#region ============================== Lifecycle ==============================


func _build_alterations() -> void:
	for alteration: Alteration in create_all_alterations():
		_register(alteration)

	shield_alteration = _alterations[Alteration.Type.SHIELD]
	block_alteration = _alterations[Alteration.Type.BLOCK]
	thorn_alteration = _alterations[Alteration.Type.THORN]

	_wire_ui_signals()


## Fresh instances of every alteration, in registration order. Shared with the
## AlterationIcon proto so it can enumerate all alterations without duplicating
## the list.
static func create_all_alterations() -> Array[Alteration]:
	var list: Array[Alteration] = []
	# Stack alterations
	list.append(PoisonAlteration.new())
	list.append(IgniteAlteration.new())
	list.append(ShieldAlteration.new())
	list.append(RegenAlteration.new())
	list.append(NecrosisAlteration.new())
	list.append(DefenseAlteration.new())
	list.append(BlockAlteration.new())
	list.append(ThornAlteration.new())
	list.append(StrengthAlteration.new())
	list.append(WeaknessAlteration.new())
	list.append(VulnerabilityAlteration.new())
	# Timed alterations
	list.append(StunAlteration.new())
	list.append(TauntAlteration.new())
	list.append(SilenceAlteration.new())
	list.append(InvulnerableAlteration.new())
	list.append(UntargetableAlteration.new())
	return list


func _register(alteration: Alteration) -> void:
	alteration.bind(_owner)
	_alterations[alteration.type] = alteration
	_alterations_list.append(alteration)

	if alteration is StackAlteration:
		(alteration as StackAlteration).stacks_changed.connect(_on_stack_changed.bind(alteration.type))
	elif alteration is TimedAlteration:
		(alteration as TimedAlteration).time_changed.connect(_on_time_changed.bind(alteration.type))
	elif alteration is StateAlteration:
		(alteration as StateAlteration).state_changed.connect(_on_state_changed.bind(alteration.type))


## Wire per-type UI-facing signals (re-emit from the concrete alteration instance).
func _wire_ui_signals() -> void:
	(_alterations[Alteration.Type.IGNITE] as StackAlteration).stacks_changed.connect(func(v: float) -> void: ignite_stacks_changed.emit(v))
	(_alterations[Alteration.Type.POISON] as StackAlteration).stacks_changed.connect(func(v: float) -> void: poison_stacks_changed.emit(v))
	(_alterations[Alteration.Type.NECROSIS] as StackAlteration).stacks_changed.connect(func(v: float) -> void: necrosis_stacks_changed.emit(v))
	(_alterations[Alteration.Type.SHIELD] as StackAlteration).stacks_changed.connect(func(v: float) -> void: shield_stacks_changed.emit(v))
	(_alterations[Alteration.Type.REGEN] as StackAlteration).stacks_changed.connect(func(v: float) -> void: regen_stacks_changed.emit(v))
	(_alterations[Alteration.Type.BLOCK] as StackAlteration).stacks_changed.connect(func(v: float) -> void: block_stacks_changed.emit(v))
	(_alterations[Alteration.Type.DEFENSE] as StackAlteration).stacks_changed.connect(func(v: float) -> void: defense_stacks_changed.emit(v))
	(_alterations[Alteration.Type.THORN] as StackAlteration).stacks_changed.connect(func(v: float) -> void: thorn_stacks_changed.emit(v))

	var stun: TimedAlteration = _alterations[Alteration.Type.STUN] as TimedAlteration
	stun.activated.connect(func(d: float, inf: bool) -> void: stunned_changed.emit(true, d, inf))
	stun.deactivated.connect(func() -> void: stunned_changed.emit(false, 0.0, false))

	var silence: TimedAlteration = _alterations[Alteration.Type.SILENCE] as TimedAlteration
	silence.activated.connect(func(d: float, inf: bool) -> void: silenced_changed.emit(true, d, inf))
	silence.deactivated.connect(func() -> void: silenced_changed.emit(false, 0.0, false))

	# State alterations — UI emits (is_active, 0, infinite=true) on each transition
	var taunt: StateAlteration = _alterations[Alteration.Type.TAUNT] as StateAlteration
	taunt.state_changed.connect(func(active: bool) -> void: taunted_changed.emit(active, 0.0, true))

	var invuln: StateAlteration = _alterations[Alteration.Type.INVULNERABLE] as StateAlteration
	invuln.state_changed.connect(func(active: bool) -> void: invulnerable_changed.emit(active, 0.0, true))

	var untarg: StateAlteration = _alterations[Alteration.Type.UNTARGETABLE] as StateAlteration
	untarg.state_changed.connect(func(active: bool) -> void: untargetable_changed.emit(active, 0.0, true))


func start() -> void:
	if _owner == null: return
	_is_active = true


func stop() -> void:
	if _owner == null: return
	_is_active = false


## Called every physics tick by Entity.process_tick() (deterministic, 1/60s).
func process_tick() -> void:
	if not _is_active or _owner == null: return
	for alteration in _alterations_list:
		alteration.process_tick()
#endregion


#region ============================== Generic API ==============================
## Get the alteration instance for a type.
func get_alteration(alteration_type: Alteration.Type) -> Alteration:
	return _alterations.get(alteration_type)


## Stat alteration pairs that cancel each other: applying one first removes the
## opposing stacks, and only the surplus accrues. Keeps a single side of each
## pair active at a time, so the displayed icon follows the net automatically.
const NET_COUNTERPART: Dictionary[Alteration.Type, Alteration.Type] = {
	Alteration.Type.STRENGTH: Alteration.Type.WEAKNESS,
	Alteration.Type.WEAKNESS: Alteration.Type.STRENGTH,
	Alteration.Type.DEFENSE: Alteration.Type.VULNERABILITY,
	Alteration.Type.VULNERABILITY: Alteration.Type.DEFENSE,
}


## Add stacks to a StackAlteration. `mod` may carry DURATION (Regen). Strength/
## Weakness and Defense/Vulnerability net against their counterpart first.
func add_stack(alteration_type: Alteration.Type, amount: float, source: Entity = null, action_id: StringName = &"", mod: Dictionary = {}) -> float:
	var alteration: StackAlteration = _alterations.get(alteration_type) as StackAlteration
	if alteration == null:
		Verbose.error("add_stack: no StackAlteration for type [" + str(alteration_type) + "]", Verbose.Category.ENTITY_MODULE)
		return 0.0

	if amount > 0 and NET_COUNTERPART.has(alteration_type):
		amount = _cancel_counterpart(alteration_type, amount)
		if amount <= 0:
			return alteration.stacks

	return alteration.add_stack(amount, source, action_id, mod)


## Remove up to `amount` stacks from the opposing alteration; returns the surplus
## still to be applied to the requested type.
func _cancel_counterpart(alteration_type: Alteration.Type, amount: float) -> float:
	var counterpart: StackAlteration = _alterations.get(NET_COUNTERPART[alteration_type]) as StackAlteration
	if counterpart == null: return amount
	var cancel: float = min(amount, counterpart.stacks)
	if cancel > 0:
		counterpart.remove_stack(cancel)
	return amount - cancel


## Remove stacks from a StackAlteration. `mod` may carry ACTION_TYPE for typed stacks.
func remove_stack(alteration_type: Alteration.Type, amount: float, mod: Dictionary = {}) -> float:
	var alteration: StackAlteration = _alterations.get(alteration_type) as StackAlteration
	if alteration == null:
		Verbose.error("remove_stack: no StackAlteration for type [" + str(alteration_type) + "]", Verbose.Category.ENTITY_MODULE)
		return 0.0
	return alteration.remove_stack(amount, mod)


func get_stacks(alteration_type: Alteration.Type) -> float:
	var alteration: StackAlteration = _alterations.get(alteration_type) as StackAlteration
	return alteration.stacks if alteration != null else 0.0


# UI-facing stack-count read-only properties (thin wrappers around get_stacks).
var ignite_stacks: float:
	get: return get_stacks(Alteration.Type.IGNITE)
var poison_stacks: float:
	get: return get_stacks(Alteration.Type.POISON)
var necrosis_stacks: float:
	get: return get_stacks(Alteration.Type.NECROSIS)
var shield_stacks: float:
	get: return get_stacks(Alteration.Type.SHIELD)
var regen_stacks: float:
	get: return get_stacks(Alteration.Type.REGEN)
var block_stacks: float:
	get: return get_stacks(Alteration.Type.BLOCK)
var defense_stacks: float:
	get: return get_stacks(Alteration.Type.DEFENSE)
var thorn_stacks: float:
	get: return get_stacks(Alteration.Type.THORN)


## Raw stat backing each combat alteration, used by the per-type lever below.
const TYPED_STAT: Dictionary[Alteration.Type, EntityStats.StatType] = {
	Alteration.Type.STRENGTH: EntityStats.StatType.M_POWER,
	Alteration.Type.WEAKNESS: EntityStats.StatType.M_FRAGILITY,
	Alteration.Type.DEFENSE: EntityStats.StatType.M_RESISTANCE,
	Alteration.Type.VULNERABILITY: EntityStats.StatType.M_EXPOSURE,
}

var _typed_stat_modifiers: Dictionary[String, StatModifier] = {}


## Single-type lever: adjusts the raw stat (M_POWER / M_FRAGILITY / M_RESISTANCE /
## M_EXPOSURE) on ONE action_type, independent of the broad named alteration.
## This is how cards/skills target a single type (e.g. exposure on PHYSICAL, power
## on UTILITY_HEAL). No icon and no netting — it is a plain accumulating modifier.
func add_typed_stack(alteration_type: Alteration.Type, action_type: Utils.ActionType, amount: float) -> float:
	if not TYPED_STAT.has(alteration_type):
		Verbose.error("add_typed_stack: no raw stat for type [" + str(alteration_type) + "]", Verbose.Category.ENTITY_MODULE)
		return 0.0
	return _adjust_typed_stat(TYPED_STAT[alteration_type], action_type, amount)


func remove_typed_stack(alteration_type: Alteration.Type, action_type: Utils.ActionType, amount: float) -> float:
	if not TYPED_STAT.has(alteration_type):
		Verbose.error("remove_typed_stack: no raw stat for type [" + str(alteration_type) + "]", Verbose.Category.ENTITY_MODULE)
		return 0.0
	return _adjust_typed_stat(TYPED_STAT[alteration_type], action_type, -amount)


func _adjust_typed_stat(stat_type: EntityStats.StatType, action_type: Utils.ActionType, delta: float) -> float:
	if _owner == null or _owner.stat_modifiers_registry == null: return 0.0

	var key: String = str(stat_type) + ":" + str(action_type)
	var mod: StatModifier = _typed_stat_modifiers.get(key)
	var new_value: float = (mod.value if mod != null else 0.0) + delta
	new_value = max(0.0, new_value)

	if new_value <= 0:
		if mod != null:
			_owner.stat_modifiers_registry.unregister_modifier(mod)
			_typed_stat_modifiers.erase(key)
		return 0.0

	if mod == null:
		mod = StatModifier.new()
		mod.id = StringName("TypedStatLever:" + key)
		mod.stat_type = stat_type
		mod.action_type = action_type
		mod.calc_type = StatModifier.CalcType.ADD
		mod.tags = []
		_typed_stat_modifiers[key] = mod
	mod.value = new_value
	_owner.stat_modifiers_registry.register_modifier(mod)
	return new_value


## Apply a TimedAlteration. `duration == -1` → infinite.
func apply_timed(alteration_type: Alteration.Type, duration: float) -> void:
	var alteration: TimedAlteration = _alterations.get(alteration_type) as TimedAlteration
	if alteration == null:
		Verbose.error("apply_timed: no TimedAlteration for type [" + str(alteration_type) + "]", Verbose.Category.ENTITY_MODULE)
		return
	alteration.apply(duration)


func cancel_timed(alteration_type: Alteration.Type) -> void:
	var alteration: TimedAlteration = _alterations.get(alteration_type) as TimedAlteration
	if alteration != null:
		alteration.cancel()


func has_timed(alteration_type: Alteration.Type) -> bool:
	var alteration: TimedAlteration = _alterations.get(alteration_type) as TimedAlteration
	return alteration != null and alteration.is_active


func get_remaining_time(alteration_type: Alteration.Type) -> float:
	var alteration: TimedAlteration = _alterations.get(alteration_type) as TimedAlteration
	return alteration.time_left if alteration != null else 0.0


## Apply a StateAlteration (on/off, no duration).
func apply_state(alteration_type: Alteration.Type) -> void:
	var alteration: StateAlteration = _alterations.get(alteration_type) as StateAlteration
	if alteration == null:
		Verbose.error("apply_state: no StateAlteration for type [" + str(alteration_type) + "]", Verbose.Category.ENTITY_MODULE)
		return
	alteration.apply()


func cancel_state(alteration_type: Alteration.Type) -> void:
	var alteration: StateAlteration = _alterations.get(alteration_type) as StateAlteration
	if alteration != null:
		alteration.cancel()


func has_state(alteration_type: Alteration.Type) -> bool:
	var alteration: StateAlteration = _alterations.get(alteration_type) as StateAlteration
	return alteration != null and alteration.is_active


## Generic status dispatcher — routes to apply_timed or apply_state based on type.
## Used by take_status() so the sender API accepts both flavors.
func apply_status(alteration_type: Alteration.Type, duration: float) -> void:
	if Alteration.is_state_type(alteration_type):
		apply_state(alteration_type)
	else:
		apply_timed(alteration_type, duration)


func has_status(alteration_type: Alteration.Type) -> bool:
	if Alteration.is_state_type(alteration_type):
		return has_state(alteration_type)
	return has_timed(alteration_type)
#endregion


#region ============================== Outgoing actions ==============================
## Apply stacks to a target through the action pipeline (power/fragility, crit, action modifiers).
func inflict_condition_stacks(target: Entity, value: float, stack_type: Alteration.Type, action_id: StringName, duration: float = 5.0) -> float:
	if is_instance_valid(target) == null: return 0

	var base_value: float = value * _get_power_fragility_multiplier(Alteration.to_action(stack_type))
	var crit_data: Dictionary = _get_crit_multiplier(Alteration.to_action(stack_type))
	value = base_value * crit_data["multiplier"]

	var modifiers_data: Dictionary = _consume_before_action_modifiers(Utils.ActionCategory.STACK, {
		ActionModifier.VarType.STACK_VALUE: value,
		ActionModifier.VarType.STACK_TYPE: stack_type,
		ActionModifier.VarType.TARGET: target,
		ActionModifier.VarType.DURATION: duration
	})

	value = modifiers_data[ActionModifier.VarType.STACK_VALUE]
	duration = modifiers_data[ActionModifier.VarType.DURATION]

	var stacks_inflicted: float = target.alterations.take_condition_stacks(value, stack_type, crit_data["is_critical"], action_id, _owner, duration)

	_consume_after_action_modifiers(Utils.ActionCategory.STACK, {
		ActionModifier.VarType.STACK_VALUE: stacks_inflicted,
		ActionModifier.VarType.STACK_TYPE: stack_type,
		ActionModifier.VarType.TARGET: target,
		ActionModifier.VarType.DURATION: duration
	})

	_owner.critical_action_done.emit(target, Alteration.to_action(stack_type), base_value, stacks_inflicted)
	_owner.action_done.emit(target, Alteration.to_action(stack_type), action_id, stacks_inflicted, crit_data["is_critical"])
	return stacks_inflicted


## Apply a TimedAlteration / StateAlteration to a target through the action pipeline.
func inflict_status(target: Entity, status_type: Alteration.Type, duration: float, action_id: StringName) -> float:
	if not is_instance_valid(target): return 0
	var value: float = duration * _get_power_fragility_multiplier(Alteration.to_action(status_type))
	var actual_duration: float = target.alterations.take_status(status_type, value, action_id, _owner)
	var action_type: Utils.ActionType = Utils.status_to_action(status_type)
	_owner.action_done.emit(target, action_type, action_id, actual_duration, false)
	return duration


## Remove debuff stacks from a target (server-only).
func cleanse(target: Entity, value: float, action_id: StringName) -> float:
	if not is_instance_valid(target): return 0
	if not multiplayer.is_server(): return 0

	var base_value: float = value * _get_power_fragility_multiplier(Utils.ActionType.UTILITY_CLEANSE)
	var crit_data: Dictionary = _get_crit_multiplier(Utils.ActionType.UTILITY_CLEANSE)
	value = base_value * crit_data["multiplier"]
	var stack_cleansed: float = target.alterations.take_cleanse(value, crit_data["is_critical"], action_id, _owner)

	if crit_data["is_critical"]:
		_owner.critical_action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, base_value, stack_cleansed)
	_owner.action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, action_id, stack_cleansed, crit_data["is_critical"])
	return stack_cleansed


## Remove buff stacks from a target (server-only).
func dispell(target: Entity, value: float, action_id: StringName) -> float:
	if not is_instance_valid(target): return 0
	if not multiplayer.is_server(): return 0

	var base_value: float = value * _get_power_fragility_multiplier(Utils.ActionType.UTILITY_DISPELL)
	var crit_data: Dictionary = _get_crit_multiplier(Utils.ActionType.UTILITY_DISPELL)
	value = base_value * crit_data["multiplier"]
	var stack_removed: float = target.alterations.take_dispell(value, crit_data["is_critical"], action_id, _owner)

	if crit_data["is_critical"]:
		_owner.critical_action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, base_value, stack_removed)
	_owner.action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, action_id, stack_removed, crit_data["is_critical"])
	return stack_removed
#endregion


#region ============================== Incoming actions ==============================
const _CLEANSE_PACK_SIZE: int = 2
const _DISPELL_PACK_SIZE: int = 2


## Receive condition stacks from a source. Applies dodge / resistance / invulnerability / death gates.
func take_condition_stacks(stacks_number: float, stack_type: Alteration.Type, is_critical: bool, action_id: StringName, source: Entity = null, duration: float = 5.0) -> float:
	if _owner.is_dead(): return 0
	if has_state(Alteration.Type.INVULNERABLE) and Alteration.is_negative(stack_type): return 0
	if multiplayer.is_server():
		stacks_number *= _get_resistance_exposure_multiplier(Alteration.to_action(stack_type))
		if _is_dodged(Alteration.to_action(stack_type), source):
			_owner.action_dodged.emit(source, Alteration.to_action(stack_type), stacks_number, is_critical)
			return 0

	var mod: Dictionary = {}
	if stack_type == Alteration.Type.REGEN:
		mod[Alteration.ModifierType.DURATION] = int(duration)

	add_stack(stack_type, stacks_number, source, action_id, mod)
	_owner.stack_taken.emit(stack_type, stacks_number, is_critical)
	_owner.action_received.emit(source, Alteration.to_action(stack_type), action_id, stacks_number, is_critical)
	Verbose.trace("Stack received [" + str(stacks_number) + "]", Verbose.Category.ACTION_RECEIVER_MODULE)
	return stacks_number


## Receive a status from a source.
func take_status(status_type: Alteration.Type, duration: float, action_id: StringName, source: Entity = null) -> float:
	if _owner.is_dead(): return 0
	if has_state(Alteration.Type.INVULNERABLE) and Alteration.is_negative(status_type): return 0

	apply_status(status_type, duration)

	var action_type: Utils.ActionType = Utils.status_to_action(status_type)
	_owner.action_received.emit(source, action_type, action_id, duration, false)
	return duration


#TODO Réfléchir à améliorer l'algo de cleanse/dispell
## Receive a cleanse (debuff stripper) — removes random debuff stacks in packs.
func take_cleanse(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	var total_to_dispell: float = value

	if multiplayer.is_server():
		total_to_dispell *= _get_resistance_exposure_multiplier(Utils.ActionType.UTILITY_CLEANSE)

	var remaining: int = int(total_to_dispell)
	var removed: int = 0
	while remaining > get_debuff_stacks():
		var candidates: Array[Alteration.Type] = []
		if ignite_stacks >= 1: candidates.append(Alteration.Type.IGNITE)
		if poison_stacks >= 1: candidates.append(Alteration.Type.POISON)
		if necrosis_stacks >= 1: candidates.append(Alteration.Type.NECROSIS)
		if candidates.is_empty():
			break
		var stack_chosen: Alteration.Type = candidates[randi() % candidates.size()]
		var to_remove: int = min(_CLEANSE_PACK_SIZE, remaining)
		match stack_chosen:
			Alteration.Type.IGNITE:
				to_remove = min(to_remove, ignite_stacks)
				remove_stack(Alteration.Type.IGNITE, to_remove)
			Alteration.Type.POISON:
				to_remove = min(to_remove, poison_stacks)
				remove_stack(Alteration.Type.POISON, to_remove)
			Alteration.Type.NECROSIS:
				to_remove = min(to_remove, necrosis_stacks)
				remove_stack(Alteration.Type.NECROSIS, to_remove)
		remaining -= to_remove
		removed += to_remove

	_owner.action_received.emit(source, Utils.ActionType.UTILITY_CLEANSE, action_id, removed, is_critical)
	return removed


## Receive a dispell (buff stripper) — removes random buff stacks in packs.
func take_dispell(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	var total_to_dispell: float = value
	if multiplayer.is_server():
		total_to_dispell *= value * _get_resistance_exposure_multiplier(Utils.ActionType.UTILITY_DISPELL)

	var remaining: int = int(total_to_dispell)
	var removed: int = 0
	while remaining > get_buff_stacks():
		var candidates: Array[Alteration.Type] = []
		if shield_stacks >= 1: candidates.append(Alteration.Type.SHIELD)
		if regen_stacks >= 1: candidates.append(Alteration.Type.REGEN)
		if candidates.is_empty():
			break
		var stack_chosen: Alteration.Type = candidates[randi() % candidates.size()]
		var to_remove: int = min(_DISPELL_PACK_SIZE, remaining)
		match stack_chosen:
			Alteration.Type.SHIELD:
				to_remove = min(to_remove, shield_stacks)
				remove_stack(Alteration.Type.SHIELD, to_remove)
			Alteration.Type.REGEN:
				to_remove = min(to_remove, regen_stacks)
				remove_stack(Alteration.Type.REGEN, to_remove)
		remaining -= to_remove
		removed += to_remove

	_owner.action_received.emit(source, Utils.ActionType.UTILITY_CLEANSE, action_id, removed, is_critical)
	return removed
#endregion


#region ============================== Aggregation helpers ==============================
func get_total_stacks() -> float:
	return get_stacks(Alteration.Type.POISON) \
		+ get_stacks(Alteration.Type.IGNITE) \
		+ get_stacks(Alteration.Type.SHIELD) \
		+ get_stacks(Alteration.Type.REGEN) \
		+ get_stacks(Alteration.Type.NECROSIS)


func get_debuff_stacks() -> float:
	return get_stacks(Alteration.Type.POISON) \
		+ get_stacks(Alteration.Type.IGNITE) \
		+ get_stacks(Alteration.Type.NECROSIS)


func get_buff_stacks() -> float:
	return get_stacks(Alteration.Type.SHIELD) \
		+ get_stacks(Alteration.Type.REGEN)


## Hot-path helper: damage pipeline applies shield absorption.
func get_shield_reduced_damage(damage: float, damage_type: Utils.ActionType) -> float:
	if shield_alteration == null: return damage
	return shield_alteration.get_reduced_damage_taken(damage, damage_type, _owner.battle_id)
#endregion


#region ============================== Signal routing ==============================
func _on_stack_changed(new_stacks: float, alteration_type: Alteration.Type) -> void:
	alteration_changed.emit(alteration_type, new_stacks)


func _on_time_changed(time_left: float, _infinite: bool, alteration_type: Alteration.Type) -> void:
	alteration_changed.emit(alteration_type, time_left)


func _on_state_changed(is_active: bool, alteration_type: Alteration.Type) -> void:
	alteration_changed.emit(alteration_type, is_active)
#endregion
