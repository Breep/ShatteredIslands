class_name InteractModule
extends Module

#signal heal_received(heal_amount: int)
signal damage_taken(damage: int, damage_type: Utils.DamageType, is_critical: bool)

@export var _storm_manager: StormManager
@export var _defense_manager: DefenseManager
@export var _life_manager: LifeManager
@export var _fire_manager: FireManager
@export var _poison_manager: PoisonManager

# ============================== Node base functions ==============================

func _ready() -> void:
	Events.damage_done.connect(_on_events_attack_done)
	Events.heal_done.connect(_on_events_heal_done)
	Events.condition_stacks_done.connect(_on_events_condition_stacks_done)

# ============================== Damage ==============================

# [Server only]
func _take_damage(source: Character, damage: int, damage_type: Utils.DamageType, is_critical: bool) -> void:
	if not multiplayer.is_server(): return
	if _storm_manager != null:
		damage = _storm_manager.get_increased_critical_damage(damage, is_critical) # Increase ALL critical damage
	
	if _defense_manager != null:
		damage = _defense_manager.get_reduced_damage_taken_from_mystical_shoulder(damage) # Reduce % of MAGIC damage
	
	if _life_manager != null:
		damage = _life_manager.get_reduced_damage(damage) # Reduce % of ALL damage
	
	if _fire_manager != null:
		damage = _fire_manager.get_reduced_damage(damage, damage_type) # Reduce % of MAGIC damage
	
	if _defense_manager != null:
		damage = _defense_manager.get_reduced_damage_taken_from_armor(_owner, damage, damage_type) # Reduce flat of PHYSIC AND MAGIC damage
	
	_owner.stats.health -= damage

# ============================== Condition stacks ==============================

# [Server only]
func _take_condition_stacks(source: Character, stacks_number: int, stack_type: Utils.StackType) -> void:
	if not multiplayer.is_server(): return
	match stack_type:
		Utils.StackType.POISON:
			_poison_manager.add_to_poison_effects(source, stacks_number)
		Utils.StackType.VULNERABILITY:
			_owner.stats.storm.vulnerability_stacks += stacks_number

# ============================== Heal ==============================

# [Server only]
func _take_heal(source: Character, heal_amount: int) -> void:
	if not multiplayer.is_server(): return
	_owner.stats.health += heal_amount

# ============================== Callback ==============================

func _on_events_attack_done(source, target, damage, damage_type, is_critical) -> void:
	if target != _owner: return
	_take_damage(source, damage, damage_type, is_critical)


func _on_events_heal_done(source, target, heal_amount) -> void:
	if target != _owner: return
	_take_heal(source, heal_amount)


func _on_events_condition_stacks_done(source, target, stacks_number, stack_type) -> void:
	if target != _owner: return
	_take_condition_stacks(source, stacks_number, stack_type)
