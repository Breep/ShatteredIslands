class_name InteractModule
extends Module

@export var _storm_manager: StormManager
@export var _defense_manager: DefenseManager
@export var _life_manager: LifeManager
@export var _fire_manager: FireManager

# ============================== Node base functions ==============================

func _ready() -> void:
	if _storm_manager == null: printerr("InteractModule: Not linked to a StormManager [", get_path(), "]")
	if _defense_manager == null: printerr("InteractModule: Not linked to a DefenseManager [", get_path(), "]")
	if _life_manager == null: printerr("InteractModule: Not linked to a LifeManager [", get_path(), "]")
	if _fire_manager == null: printerr("InteractModule: Not linked to a FireManager [", get_path(), "]")

# ============================== Public function ==============================

# ===== Damage
func take_damage(damage: int, damage_type: Utils.DamageType, is_critical: bool, source: Entity = null, attack_type: Utils.AttackType = Utils.AttackType.UNDEF) -> int:
	var damage_before_armor: int = 0
	if multiplayer.is_server(): 
		if _storm_manager != null: damage = _storm_manager.get_increased_critical_damage(damage, is_critical) # Increase ALL critical damage
		if _defense_manager != null: damage = _defense_manager.get_reduced_damage_taken_from_mystical_shoulder(damage) # Reduce % of MAGIC damage
		if _life_manager != null: damage = _life_manager.get_reduced_damage(damage) # Reduce % of ALL damage
		if _fire_manager != null: damage = _fire_manager.get_reduced_damage(damage, damage_type) # Reduce % of MAGIC damage
		damage_before_armor = damage
		if _defense_manager != null: damage = _defense_manager.get_reduced_damage_taken_from_armor(damage, damage_type) # Reduce flat of PHYSIC AND MAGIC damage
		if damage_before_armor - damage > 0:
			_owner.signal_damage_taken(damage_before_armor - damage, damage_type, is_critical, true)
	
	_owner.stats.health -= damage
	if damage > 0 or (damage_before_armor == 0 and damage == 0):
		_owner.signal_damage_taken(damage, damage_type, is_critical, false)
	if source != null and attack_type != Utils.AttackType.UNDEF:
		source.notify_damage_done(damage, attack_type)
	return damage


func take_damage_percent(damage_percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool, source: Entity = null) -> void:
	if not multiplayer.is_server(): return
	var hp: int
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = _owner.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = _owner.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = _owner.stats.health_max - _owner.stats.health
	var damage = hp * damage_percent  / 100.0
	take_damage(damage, damage_type, is_critical, source)

# ===== Condition stacks

func take_condition_stacks(stacks_number: int, stack_type: Utils.StackType, _source: Character = null) -> void:
	_owner.signal_stack_taken(stack_type, stacks_number)
	match stack_type:
		Utils.StackType.POISON:
			_owner.stats.poison_stacks += stacks_number
		Utils.StackType.IGNITE:
			_owner.stats.ignite_stacks += stacks_number
		Utils.StackType.ARMOR:
			_owner.stats.armor_stacks += stacks_number

# ===== Heal

func take_heal(heal_amount: int, _source: Character = null) -> void:
	_owner.stats.health += heal_amount
	_owner.signal_heal_taken(heal_amount)
