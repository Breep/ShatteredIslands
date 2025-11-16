class_name UIDebugEntityStats
extends Control

@export var _health_max_label: Label
@export var _mana_max_label: Label
@export var _ad_label: Label
@export var _as_label: Label
@export var _critical_chance_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_STUN: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_ARMOR: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null
}

@export var _critical_multiplier_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_STUN: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_ARMOR: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null
}

@export var _dodge_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_STUN: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_ARMOR: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null
}

@export var _resistance_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_STUN: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_ARMOR: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null
}

@export var _vulnerability_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_STUN: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_ARMOR: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null
}

@export var _strenght_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_STUN: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_ARMOR: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null
}

@export var _weakness_labels: Dictionary [Utils.ActionType, Label] = {
	Utils.ActionType.DAMAGE_PHYSICAL: null,
	Utils.ActionType.DAMAGE_MAGICAL: null,
	Utils.ActionType.DAMAGE_POISON: null,
	Utils.ActionType.UTILITY_HEAL: null,
	Utils.ActionType.UTILITY_STUN: null,
	Utils.ActionType.UTILITY_CLEANSE: null,
	Utils.ActionType.UTILITY_DISPELL: null,
	Utils.ActionType.STACK_ARMOR: null,
	Utils.ActionType.STACK_IGNITE: null,
	Utils.ActionType.STACK_POISON: null,
	Utils.ActionType.STACK_REGEN: null,
	Utils.ActionType.STACK_NECROSIS: null
}

@export var _entity_name_label: Label

var _owner_entity: Entity

func connect_entity(owner_entity: Entity) -> void:
	if _owner_entity != null:
		_disconnect_from_signals()
	_owner_entity = owner_entity
	_connect_to_signals()
	_update_layout()


func _connect_to_signals() -> void:
	if not _owner_entity.stats.health_max_changed.is_connected(_on_owner_entity_health_max_changed):
		_owner_entity.stats.health_max_changed.connect(_on_owner_entity_health_max_changed)
	if not _owner_entity.stats.mana_max_changed.is_connected(_on_owner_entity_max_mana_changed):
		_owner_entity.stats.mana_max_changed.connect(_on_owner_entity_max_mana_changed)
	if not _owner_entity.stats.attack_damage_changed.is_connected(_on_owner_entity_ad_changed):
		_owner_entity.stats.attack_damage_changed.connect(_on_owner_entity_ad_changed)
	if not _owner_entity.stats.attack_speed_changed.is_connected(_on_owner_entity_as_changed):
		_owner_entity.stats.attack_speed_changed.connect(_on_owner_entity_as_changed)
	if not _owner_entity.stats.critical_chance_changed.is_connected(_on_owner_entity_crit_chance_changed):
		_owner_entity.stats.critical_chance_changed.connect(_on_owner_entity_crit_chance_changed)
	if not _owner_entity.stats.critical_multiplier_changed.is_connected(_on_owner_entity_crit_mult_changed):
		_owner_entity.stats.critical_multiplier_changed.connect(_on_owner_entity_crit_mult_changed)
	if not _owner_entity.stats.dodge_changed.is_connected(_on_owner_entity_dodge_changed):
		_owner_entity.stats.dodge_changed.connect(_on_owner_entity_dodge_changed)
	if not _owner_entity.stats.resistance_changed.is_connected(_on_owner_entity_resist_changed):
		_owner_entity.stats.resistance_changed.connect(_on_owner_entity_resist_changed)
	if not _owner_entity.stats.vulnerability_changed.is_connected(_on_owner_entity_vuln_changed):
		_owner_entity.stats.vulnerability_changed.connect(_on_owner_entity_vuln_changed)
	if not _owner_entity.stats.strenght_changed.is_connected(_on_owner_entity_strenght_changed):
		_owner_entity.stats.strenght_changed.connect(_on_owner_entity_strenght_changed)
	if not _owner_entity.stats.weakness_changed.is_connected(_on_owner_entity_weakness_changed):
		_owner_entity.stats.weakness_changed.connect(_on_owner_entity_weakness_changed)


func _disconnect_from_signals() -> void:
	if _owner_entity.stats.health_max_changed.is_connected(_on_owner_entity_health_max_changed):
		_owner_entity.stats.health_max_changed.disconnect(_on_owner_entity_health_max_changed)
	if _owner_entity.stats.mana_max_changed.is_connected(_on_owner_entity_max_mana_changed):
		_owner_entity.stats.mana_max_changed.disconnect(_on_owner_entity_max_mana_changed)
	if _owner_entity.stats.attack_damage_changed.is_connected(_on_owner_entity_ad_changed):
		_owner_entity.stats.attack_damage_changed.disconnect(_on_owner_entity_ad_changed)
	if _owner_entity.stats.attack_speed_changed.is_connected(_on_owner_entity_as_changed):
		_owner_entity.stats.attack_speed_changed.disconnect(_on_owner_entity_as_changed)
	if _owner_entity.stats.critical_chance_changed.is_connected(_on_owner_entity_crit_chance_changed):
		_owner_entity.stats.critical_chance_changed.disconnect(_on_owner_entity_crit_chance_changed)
	if _owner_entity.stats.critical_multiplier_changed.is_connected(_on_owner_entity_crit_mult_changed):
		_owner_entity.stats.critical_multiplier_changed.disconnect(_on_owner_entity_crit_mult_changed)
	if _owner_entity.stats.dodge_changed.is_connected(_on_owner_entity_dodge_changed):
		_owner_entity.stats.dodge_changed.disconnect(_on_owner_entity_dodge_changed)
	if _owner_entity.stats.resistance_changed.is_connected(_on_owner_entity_resist_changed):
		_owner_entity.stats.resistance_changed.disconnect(_on_owner_entity_resist_changed)
	if _owner_entity.stats.vulnerability_changed.is_connected(_on_owner_entity_vuln_changed):
		_owner_entity.stats.vulnerability_changed.disconnect(_on_owner_entity_vuln_changed)
	if _owner_entity.stats.strenght_changed.is_connected(_on_owner_entity_strenght_changed):
		_owner_entity.stats.strenght_changed.disconnect(_on_owner_entity_strenght_changed)
	if _owner_entity.stats.weakness_changed.is_connected(_on_owner_entity_weakness_changed):
		_owner_entity.stats.weakness_changed.disconnect(_on_owner_entity_weakness_changed)


func _update_layout() -> void:
	_health_max_label.text = str(_owner_entity.stats.get_stat(EntityStats.StatType.HEALTH_MAX))
	_mana_max_label.text = str(_owner_entity.stats.get_stat(EntityStats.StatType.MANA_MAX))
	_ad_label.text = str(_owner_entity.stats.get_stat(EntityStats.StatType.AD))
	_as_label.text = str(_owner_entity.stats.get_stat(EntityStats.StatType.AA_SPEED))
	for action_type: Utils.ActionType in Utils.get_all_actions():
		_critical_chance_labels[action_type].text = str(int(_owner_entity.stats.get_stat(EntityStats.StatType.CRIT_CHANCE, action_type)))
		_critical_multiplier_labels[action_type].text = str(int(_owner_entity.stats.get_stat(EntityStats.StatType.CRIT_MULT, action_type)))
		_dodge_labels[action_type].text = str(int(_owner_entity.stats.get_stat(EntityStats.StatType.DODGE, action_type)))
		_resistance_labels[action_type].text = str(int(_owner_entity.stats.get_stat(EntityStats.StatType.RESISTANCE, action_type)))
		_vulnerability_labels[action_type].text = str(int(_owner_entity.stats.get_stat(EntityStats.StatType.VULNERABILITY, action_type)))
		_strenght_labels[action_type].text = str(int(_owner_entity.stats.get_stat(EntityStats.StatType.STRENGHT, action_type)))
		_weakness_labels[action_type].text = str(int(_owner_entity.stats.get_stat(EntityStats.StatType.WEAKNESS, action_type)))
	_entity_name_label.text = _owner_entity.name

# Callbacks

func _on_owner_entity_health_max_changed(new_health_max: int) -> void:
	_health_max_label.text = str(new_health_max)


func _on_owner_entity_max_mana_changed(new_mana_max: int) -> void:
	_mana_max_label.text = str(new_mana_max)


func _on_owner_entity_ad_changed(new_ad: int) -> void:
	_ad_label.text = str(new_ad)


func _on_owner_entity_as_changed(new_as: float) -> void:
	_as_label.text = str(new_as)


func _on_owner_entity_crit_chance_changed(new_critical_chance: float, action_type: Utils.ActionType) -> void:
	_critical_chance_labels[action_type].text = str(int(new_critical_chance))


func _on_owner_entity_crit_mult_changed(new_critical_mult: float, action_type: Utils.ActionType) -> void:
	_critical_multiplier_labels[action_type].text = str(int(new_critical_mult))


func _on_owner_entity_dodge_changed(new_dodge: float, action_type: Utils.ActionType) -> void:
	_dodge_labels[action_type].text = str(int(new_dodge))


func _on_owner_entity_resist_changed(new_resist: float, action_type: Utils.ActionType) -> void:
	_resistance_labels[action_type].text = str(int(new_resist))


func _on_owner_entity_vuln_changed(new_vuln: float, action_type: Utils.ActionType) -> void:
	_vulnerability_labels[action_type].text = str(int(new_vuln))


func _on_owner_entity_strenght_changed(new_strenght: float, action_type: Utils.ActionType) -> void:
	_strenght_labels[action_type].text = str(int(new_strenght))


func _on_owner_entity_weakness_changed(new_weakness: float, action_type: Utils.ActionType) -> void:
	_weakness_labels[action_type].text = str(int(new_weakness))
