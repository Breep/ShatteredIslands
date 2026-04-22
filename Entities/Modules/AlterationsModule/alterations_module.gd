class_name AlterationsModule
extends Module

## Unified module for every Alteration on an entity.
## Alterations are held in a `Alteration.Type → Alteration` dictionary;
## process_tick is delegated to each instance. Hot-path consumers
## (damage pipeline) read `shield_alteration`, `block_alteration`,
## `thorn_alteration` directly — everything else goes through the generic API.

const TICKS_PER_SECOND: int = Alteration.TICKS_PER_SECOND

## Single aggregate signal. `payload` depends on the alteration type:
## - StackAlteration: new stack count (float)
## - TimedAlteration: new time_left (float); is_infinite readable on the instance
## For finer-grained events (shield_broken, typed_stacks_changed, expired),
## subscribe to the Alteration instance directly via `get_alteration(type)`.
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


#region ============================== Lifecycle ==============================
func init(entity_owner: Entity) -> AlterationsModule:
	super.init(entity_owner)
	_build_alterations()
	return self


func _build_alterations() -> void:
	# Stack alterations
	_register(PoisonAlteration.new())
	_register(IgniteAlteration.new())
	_register(ShieldAlteration.new())
	_register(RegenAlteration.new())
	_register(NecrosisAlteration.new())
	_register(DefenseAlteration.new())
	_register(BlockAlteration.new())
	_register(ThornAlteration.new())
	_register(StrengthAlteration.new())
	_register(WeaknessAlteration.new())
	_register(VulnerabilityAlteration.new())

	# Timed alterations
	_register(StunAlteration.new())
	_register(TauntAlteration.new())
	_register(SilenceAlteration.new())
	_register(InvulnerableAlteration.new())
	_register(UntargetableAlteration.new())

	shield_alteration = _alterations[Alteration.Type.SHIELD]
	block_alteration = _alterations[Alteration.Type.BLOCK]
	thorn_alteration = _alterations[Alteration.Type.THORN]

	_wire_ui_signals()


func _register(alteration: Alteration) -> void:
	alteration.bind(_owner)
	_alterations[alteration.type] = alteration
	_alterations_list.append(alteration)

	if alteration is StackAlteration:
		(alteration as StackAlteration).stacks_changed.connect(_on_stack_changed.bind(alteration.type))
	elif alteration is TimedAlteration:
		(alteration as TimedAlteration).time_changed.connect(_on_time_changed.bind(alteration.type))


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

	var taunt: TimedAlteration = _alterations[Alteration.Type.TAUNT] as TimedAlteration
	taunt.activated.connect(func(d: float, inf: bool) -> void: taunted_changed.emit(true, d, inf))
	taunt.deactivated.connect(func() -> void: taunted_changed.emit(false, 0.0, false))

	var silence: TimedAlteration = _alterations[Alteration.Type.SILENCE] as TimedAlteration
	silence.activated.connect(func(d: float, inf: bool) -> void: silenced_changed.emit(true, d, inf))
	silence.deactivated.connect(func() -> void: silenced_changed.emit(false, 0.0, false))

	var invuln: TimedAlteration = _alterations[Alteration.Type.INVULNERABLE] as TimedAlteration
	invuln.activated.connect(func(d: float, inf: bool) -> void: invulnerable_changed.emit(true, d, inf))
	invuln.deactivated.connect(func() -> void: invulnerable_changed.emit(false, 0.0, false))

	var untarg: TimedAlteration = _alterations[Alteration.Type.UNTARGETABLE] as TimedAlteration
	untarg.activated.connect(func(d: float, inf: bool) -> void: untargetable_changed.emit(true, d, inf))
	untarg.deactivated.connect(func() -> void: untargetable_changed.emit(false, 0.0, false))


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


## Add stacks to a StackAlteration. `mod` may carry DURATION (Regen) or
## ACTION_TYPE (typed stacks: Strength/Weakness/Vulnerability).
func add_stack(alteration_type: Alteration.Type, amount: float, source: Entity = null, action_id: StringName = &"", mod: Dictionary = {}) -> float:
	var alteration: StackAlteration = _alterations.get(alteration_type) as StackAlteration
	if alteration == null:
		Verbose.error("add_stack: no StackAlteration for type [" + str(alteration_type) + "]", Verbose.Category.ENTITY_MODULE)
		return 0.0
	return alteration.add_stack(amount, source, action_id, mod)


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


## Convenience for typed stacks (Strength/Weakness/Vulnerability).
func add_typed_stack(alteration_type: Alteration.Type, action_type: Utils.ActionType, amount: float) -> float:
	return add_stack(alteration_type, amount, null, &"", {Alteration.ModifierType.ACTION_TYPE: action_type})


func remove_typed_stack(alteration_type: Alteration.Type, action_type: Utils.ActionType, amount: float) -> float:
	return remove_stack(alteration_type, amount, {Alteration.ModifierType.ACTION_TYPE: action_type})


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
#endregion
