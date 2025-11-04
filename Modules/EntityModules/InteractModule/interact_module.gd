class_name InteractModule
extends Module

@export var _storm_manager: StormManager
@export var _defense_manager: DefenseManager
@export var _life_manager: LifeManager
@export var _fire_manager: FireManager
@export var _poison_manager: PoisonManager

# ============================== Node base functions ==============================

func _ready() -> void:
	if _storm_manager == null: printerr("InteractModule: Not linked to a StormManager [", get_path(), "]")
	if _defense_manager == null: printerr("InteractModule: Not linked to a DefenseManager [", get_path(), "]")
	if _life_manager == null: printerr("InteractModule: Not linked to a LifeManager [", get_path(), "]")
	if _fire_manager == null: printerr("InteractModule: Not linked to a FireManager [", get_path(), "]")

# ============================== Public function ==============================

# ===== Damage
func take_damage(damage: int, damage_type: Utils.DamageType, is_critical: bool, source: Entity = null, attack_type: Utils.AttackType = Utils.AttackType.UNDEF) -> int:
	if _owner.stats.health <= 0 or _owner.is_dead: return 0
	var damage_before_armor: int = 0
	if multiplayer.is_server():
		var phy_res: float = _owner.stats.all_resistance + _owner.stats.physical_resistance
		var mag_res: float = _owner.stats.all_resistance + _owner.stats.magical_resistance
		var poi_res: float = _owner.stats.all_resistance + _owner.stats.poison_resistance
		match damage_type:
			Utils.DamageType.PHYSICAL: damage = int((1.0 - phy_res / 100.0) * float(damage))
			Utils.DamageType.MAGICAL: damage = int((1.0 - mag_res / 100.0) * float(damage))
			Utils.DamageType.POISON: damage = int((1.0 - poi_res / 100.0) * float(damage))
		
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
		Utils.StackType.REGEN:
			_owner.stats.regen_stacks += stacks_number

# ===== Heal

func take_heal(heal_amount: int, _source: Character = null) -> void:
	if _owner.stats.health <= 0 or _owner.is_dead: return
	_owner.stats.health += heal_amount
	_owner.signal_heal_taken(heal_amount)
