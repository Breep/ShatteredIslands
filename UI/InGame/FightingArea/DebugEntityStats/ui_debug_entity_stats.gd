class_name UIDebugEntityStats
extends Control

@export var _entity_name_label: Label

# === Simple stats (single label each) ===
@export_group("Simple Stats")
@export var _health_label: Label
@export var _health_max_label: Label
@export var _mana_label: Label
@export var _mana_max_label: Label
@export var _mana_regen_label: Label
@export var _ad_label: Label
@export var _as_label: Label
@export var _attack_range_label: Label
@export var _ap_label: Label
@export var _defence_label: Label
@export var _block_label: Label
@export var _thorn_label: Label

# === Per-ActionType stats (Dictionary[Utils.ActionType, Label]) ===
@export_group("Per-ActionType Stats")
@export var _critical_chance_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.DAMAGE_PURE: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_SHIELD: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null,
	Utils.ActionType.STATUS_STUN: null,
	Utils.ActionType.STATUS_TAUNT: null,
	Utils.ActionType.STATUS_SILENCE: null,
	Utils.ActionType.STATUS_INVULNERABLE: null,
	Utils.ActionType.STATUS_UNTARGETABLE: null
}

@export var _critical_multiplier_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.DAMAGE_PURE: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_SHIELD: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null,
	Utils.ActionType.STATUS_STUN: null,
	Utils.ActionType.STATUS_TAUNT: null,
	Utils.ActionType.STATUS_SILENCE: null,
	Utils.ActionType.STATUS_INVULNERABLE: null,
	Utils.ActionType.STATUS_UNTARGETABLE: null
}

@export var _dodge_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.DAMAGE_PURE: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_SHIELD: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null,
	Utils.ActionType.STATUS_STUN: null,
	Utils.ActionType.STATUS_TAUNT: null,
	Utils.ActionType.STATUS_SILENCE: null,
	Utils.ActionType.STATUS_INVULNERABLE: null,
	Utils.ActionType.STATUS_UNTARGETABLE: null
}

@export var _resistance_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.DAMAGE_PURE: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_SHIELD: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null,
	Utils.ActionType.STATUS_STUN: null,
	Utils.ActionType.STATUS_TAUNT: null,
	Utils.ActionType.STATUS_SILENCE: null,
	Utils.ActionType.STATUS_INVULNERABLE: null,
	Utils.ActionType.STATUS_UNTARGETABLE: null
}

@export var _vulnerability_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.DAMAGE_PURE: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_SHIELD: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null,
	Utils.ActionType.STATUS_STUN: null,
	Utils.ActionType.STATUS_TAUNT: null,
	Utils.ActionType.STATUS_SILENCE: null,
	Utils.ActionType.STATUS_INVULNERABLE: null,
	Utils.ActionType.STATUS_UNTARGETABLE: null
}

@export var _strength_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.DAMAGE_PURE: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_SHIELD: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null,
	Utils.ActionType.STATUS_STUN: null,
	Utils.ActionType.STATUS_TAUNT: null,
	Utils.ActionType.STATUS_SILENCE: null,
	Utils.ActionType.STATUS_INVULNERABLE: null,
	Utils.ActionType.STATUS_UNTARGETABLE: null
}

@export var _weakness_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.DAMAGE_PURE: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_SHIELD: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null,
	Utils.ActionType.STATUS_STUN: null,
	Utils.ActionType.STATUS_TAUNT: null,
	Utils.ActionType.STATUS_SILENCE: null,
	Utils.ActionType.STATUS_INVULNERABLE: null,
	Utils.ActionType.STATUS_UNTARGETABLE: null
}

@export var _crit_resistance_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.DAMAGE_PURE: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_SHIELD: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null,
	Utils.ActionType.STATUS_STUN: null,
	Utils.ActionType.STATUS_TAUNT: null,
	Utils.ActionType.STATUS_SILENCE: null,
	Utils.ActionType.STATUS_INVULNERABLE: null,
	Utils.ActionType.STATUS_UNTARGETABLE: null
}

@export var _life_steal_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.DAMAGE_PURE: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_SHIELD: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null,
	Utils.ActionType.STATUS_STUN: null,
	Utils.ActionType.STATUS_TAUNT: null,
	Utils.ActionType.STATUS_SILENCE: null,
	Utils.ActionType.STATUS_INVULNERABLE: null,
	Utils.ActionType.STATUS_UNTARGETABLE: null
}

# === Private ===
var _owner_entity: Entity

# ============================== Public ==============================

func connect_entity(owner_entity: Entity) -> void:
	if _owner_entity != null:
		_disconnect_from_signals()
	_owner_entity = owner_entity
	_connect_to_signals()
	_update_layout()

# ============================== Private ==============================

func _safe_connect(sig: Signal, cb: Callable) -> void:
	if not sig.is_connected(cb):
		sig.connect(cb)


func _safe_disconnect(sig: Signal, cb: Callable) -> void:
	if sig.is_connected(cb):
		sig.disconnect(cb)


func _connect_to_signals() -> void:
	var s: EntityStats = _owner_entity.stats
	# Simple stats
	_safe_connect(s.health_changed, _on_health_changed)
	_safe_connect(s.health_max_changed, _on_health_max_changed)
	_safe_connect(s.mana_changed, _on_mana_changed)
	_safe_connect(s.mana_max_changed, _on_mana_max_changed)
	_safe_connect(s.mana_regen_changed, _on_mana_regen_changed)
	_safe_connect(s.attack_damage_changed, _on_ad_changed)
	_safe_connect(s.attack_speed_changed, _on_as_changed)
	_safe_connect(s.attack_range_changed, _on_attack_range_changed)
	_safe_connect(s.attack_power_changed, _on_ap_changed)
	# Phase 4 rework: Defence/Block/Thorn are now alterations, not EntityStats.
	var c: ConditionsModule = _owner_entity.conditions
	if c != null:
		_safe_connect(c.defense_stacks_changed, _on_defence_changed)
		_safe_connect(c.block_stacks_changed, _on_block_changed)
		_safe_connect(c.thorn_stacks_changed, _on_thorn_changed)
	# Per-ActionType stats
	_safe_connect(s.critical_chance_changed, _on_crit_chance_changed)
	_safe_connect(s.critical_multiplier_changed, _on_crit_mult_changed)
	_safe_connect(s.dodge_changed, _on_dodge_changed)
	_safe_connect(s.resistance_changed, _on_resist_changed)
	_safe_connect(s.exposure_changed, _on_vuln_changed)
	_safe_connect(s.power_changed, _on_strength_changed)
	_safe_connect(s.fragility_changed, _on_weakness_changed)
	_safe_connect(s.crit_resistance_changed, _on_crit_resist_changed)
	_safe_connect(s.life_steal_changed, _on_life_steal_changed)


func _disconnect_from_signals() -> void:
	var s: EntityStats = _owner_entity.stats
	# Simple stats
	_safe_disconnect(s.health_changed, _on_health_changed)
	_safe_disconnect(s.health_max_changed, _on_health_max_changed)
	_safe_disconnect(s.mana_changed, _on_mana_changed)
	_safe_disconnect(s.mana_max_changed, _on_mana_max_changed)
	_safe_disconnect(s.mana_regen_changed, _on_mana_regen_changed)
	_safe_disconnect(s.attack_damage_changed, _on_ad_changed)
	_safe_disconnect(s.attack_speed_changed, _on_as_changed)
	_safe_disconnect(s.attack_range_changed, _on_attack_range_changed)
	_safe_disconnect(s.attack_power_changed, _on_ap_changed)
	# Phase 4 rework: Defence/Block/Thorn are now alterations, not EntityStats.
	var c: ConditionsModule = _owner_entity.conditions
	if c != null:
		_safe_disconnect(c.defense_stacks_changed, _on_defence_changed)
		_safe_disconnect(c.block_stacks_changed, _on_block_changed)
		_safe_disconnect(c.thorn_stacks_changed, _on_thorn_changed)
	# Per-ActionType stats
	_safe_disconnect(s.critical_chance_changed, _on_crit_chance_changed)
	_safe_disconnect(s.critical_multiplier_changed, _on_crit_mult_changed)
	_safe_disconnect(s.dodge_changed, _on_dodge_changed)
	_safe_disconnect(s.resistance_changed, _on_resist_changed)
	_safe_disconnect(s.exposure_changed, _on_vuln_changed)
	_safe_disconnect(s.power_changed, _on_strength_changed)
	_safe_disconnect(s.fragility_changed, _on_weakness_changed)
	_safe_disconnect(s.crit_resistance_changed, _on_crit_resist_changed)
	_safe_disconnect(s.life_steal_changed, _on_life_steal_changed)


func _set_label(label: Label, value: float, decimals: int = 0) -> void:
	if label != null:
		label.text = str(value).pad_decimals(decimals)


func _set_action_labels(labels: Dictionary, action_type: Utils.ActionType, value: float) -> void:
	if labels.has(action_type) and labels[action_type] != null:
		labels[action_type].text = str(value).pad_decimals(0)


func _update_layout() -> void:
	var s: EntityStats = _owner_entity.stats
	if _entity_name_label != null:
		_entity_name_label.text = _owner_entity.name

	# Simple stats
	_set_label(_health_label, s.get_stat(EntityStats.StatType.HEALTH))
	_set_label(_health_max_label, s.get_stat(EntityStats.StatType.HEALTH_MAX))
	_set_label(_mana_label, s.get_stat(EntityStats.StatType.MANA))
	_set_label(_mana_max_label, s.get_stat(EntityStats.StatType.MANA_MAX))
	_set_label(_mana_regen_label, s.get_stat(EntityStats.StatType.MANA_REGEN), 2)
	_set_label(_ad_label, s.get_stat(EntityStats.StatType.AD))
	_set_label(_as_label, s.get_stat(EntityStats.StatType.AS), 2)
	_set_label(_attack_range_label, s.get_stat(EntityStats.StatType.ATTACK_RANGE))
	_set_label(_ap_label, s.get_stat(EntityStats.StatType.AP))
	var c: ConditionsModule = _owner_entity.conditions
	_set_label(_defence_label, c.defense_stacks if c != null else 0.0)
	_set_label(_block_label, c.block_stacks if c != null else 0.0)
	_set_label(_thorn_label, c.thorn_stacks if c != null else 0.0)

	# Per-ActionType stats
	for action_type: Utils.ActionType in Utils.get_all_actions():
		_set_action_labels(_critical_chance_labels, action_type, s.get_stat(EntityStats.StatType.CRIT_CHANCE, action_type))
		_set_action_labels(_critical_multiplier_labels, action_type, s.get_stat(EntityStats.StatType.CRIT_MULT, action_type))
		_set_action_labels(_dodge_labels, action_type, s.get_stat(EntityStats.StatType.DODGE, action_type))
		_set_action_labels(_resistance_labels, action_type, s.get_stat(EntityStats.StatType.RESISTANCE, action_type))
		_set_action_labels(_vulnerability_labels, action_type, s.get_stat(EntityStats.StatType.EXPOSURE, action_type))
		_set_action_labels(_strength_labels, action_type, s.get_stat(EntityStats.StatType.POWER, action_type))
		_set_action_labels(_weakness_labels, action_type, s.get_stat(EntityStats.StatType.FRAGILITY, action_type))
		_set_action_labels(_crit_resistance_labels, action_type, s.get_stat(EntityStats.StatType.CRIT_RESISTANCE, action_type))
		_set_action_labels(_life_steal_labels, action_type, s.get_stat(EntityStats.StatType.LIFESTEAL, action_type))

# ============================== Callbacks ==============================

# --- Simple stats ---
func _on_health_changed(value: float) -> void:
	_set_label(_health_label, value)

func _on_health_max_changed(value: float) -> void:
	_set_label(_health_max_label, value)

func _on_mana_changed(value: float) -> void:
	_set_label(_mana_label, value)

func _on_mana_max_changed(value: float) -> void:
	_set_label(_mana_max_label, value)

func _on_mana_regen_changed(value: float) -> void:
	_set_label(_mana_regen_label, value)

func _on_ad_changed(value: float) -> void:
	_set_label(_ad_label, value)

func _on_as_changed(value: float) -> void:
	_set_label(_as_label, value)

func _on_attack_range_changed(value: float) -> void:
	_set_label(_attack_range_label, value)

func _on_ap_changed(value: float) -> void:
	_set_label(_ap_label, value)

func _on_defence_changed(value: float) -> void:
	_set_label(_defence_label, value)

func _on_block_changed(value: float) -> void:
	_set_label(_block_label, value)

func _on_thorn_changed(value: float) -> void:
	_set_label(_thorn_label, value)

# --- Per-ActionType stats ---
func _on_crit_chance_changed(value: float, action_type: Utils.ActionType) -> void:
	_set_action_labels(_critical_chance_labels, action_type, value)

func _on_crit_mult_changed(value: float, action_type: Utils.ActionType) -> void:
	_set_action_labels(_critical_multiplier_labels, action_type, value)

func _on_dodge_changed(value: float, action_type: Utils.ActionType) -> void:
	_set_action_labels(_dodge_labels, action_type, value)

func _on_resist_changed(value: float, action_type: Utils.ActionType) -> void:
	_set_action_labels(_resistance_labels, action_type, value)

func _on_vuln_changed(value: float, action_type: Utils.ActionType) -> void:
	_set_action_labels(_vulnerability_labels, action_type, value)

func _on_strength_changed(value: float, action_type: Utils.ActionType) -> void:
	_set_action_labels(_strength_labels, action_type, value)

func _on_weakness_changed(value: float, action_type: Utils.ActionType) -> void:
	_set_action_labels(_weakness_labels, action_type, value)

func _on_crit_resist_changed(value: float, action_type: Utils.ActionType) -> void:
	_set_action_labels(_crit_resistance_labels, action_type, value)

func _on_life_steal_changed(value: float, action_type: Utils.ActionType) -> void:
	_set_action_labels(_life_steal_labels, action_type, value)
