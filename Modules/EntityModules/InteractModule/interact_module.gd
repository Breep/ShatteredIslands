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
func take_damage(damage: int, damage_type: Utils.DamageType, is_critical: bool, _source: Entity = null) -> void:
	if multiplayer.is_server(): 
		if _storm_manager != null: damage = _storm_manager.get_increased_critical_damage(damage, is_critical) # Increase ALL critical damage
		if _defense_manager != null: damage = _defense_manager.get_reduced_damage_taken_from_mystical_shoulder(damage) # Reduce % of MAGIC damage
		if _life_manager != null: damage = _life_manager.get_reduced_damage(damage) # Reduce % of ALL damage
		if _fire_manager != null: damage = _fire_manager.get_reduced_damage(damage, damage_type) # Reduce % of MAGIC damage
		if _defense_manager != null: damage = _defense_manager.get_reduced_damage_taken_from_armor(damage, damage_type) # Reduce flat of PHYSIC AND MAGIC damage
	
	_owner.stats.health -= damage
	_owner.signal_damage_taken(damage, damage_type, is_critical)

# ===== Condition stacks
func take_condition_stacks(stacks_number: int, stack_type: Utils.StackType, _source: Character = null) -> void:
	match stack_type:
		Utils.StackType.POISON:
			_owner.stats.poison_stacks += stacks_number

# ===== Heal
func take_heal(heal_amount: int, _source: Character = null) -> void:
	_owner.stats.health += heal_amount
