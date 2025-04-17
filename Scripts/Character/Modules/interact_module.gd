class_name InteractModule
extends Module

signal heal_received(heal_amount: int)
signal damage_taken(damage: int, damage_type: Utils.DamageType, is_critical: bool)
signal stacks_taken()

# ============================== Node base functions ==============================

func _ready() -> void:
	Events.damage_done.connect(_on_events_attack_done)
	Events.heal_done.connect(_on_events_heal_done)
	Events.condition_stacks_done.connect(_on_events_condition_stacks_done)

# ============================== Damage ==============================

# [All]
@rpc("authority", "call_local")
func _net_take_damage(peer_id: int, damage: int, damage_type: Utils.DamageType, is_critical: bool) -> void:
	_source.stats.health = clamp(_source.stats.health - damage, 0, _source.stats.health_max)
	damage_taken.emit(damage, damage_type, is_critical)


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
		damage = _defense_manager.get_reduced_damage_taken_from_armor(source, damage, damage_type) # Reduce flat of PHYSIC AND MAGIC damage
	
	if is_critical:
		Events.critical_damage_done.emit(source, _source, damage)
	
	if source != null:
		_net_take_damage.rpc(source.player.id, damage, damage_type, is_critical)
	else:
		_net_take_damage.rpc(0, damage, damage_type, is_critical)

# ============================== Condition stacks ==============================

# [All]
@rpc("authority", "call_local")
func _net_take_condition_stacks(stacks_number: int, stack_type: Utils.StackType, source_id: int = -1) -> void:
	stacks_taken.emit()


# [Server only]
func _take_condition_stacks(source: Character, stacks_number: int, stack_type: Utils.StackType) -> void:
	if not multiplayer.is_server(): return
	match stack_type:
		Utils.StackType.POISON:
			_poison_manager.add_to_poison_effects(source, stacks_number)
		Utils.StackType.VULNERABILITY:
			_source.stats.storm.vulnerability_stacks += stacks_number
	
	if source != null:
		_net_take_condition_stacks.rpc(stacks_number, stack_type, source.player.id)

# ============================== Heal ==============================

# [All]
@rpc("authority", "call_local")
func _net_take_heal(source_id: int, heal_amount: int) -> void:
	_source.stats.health = clamp(_source.stats.health + heal_amount, 0, _source.stats.health_max)
	heal_received.emit(heal_amount)


# [Server only]
func _take_heal(source: Character, heal_amount: int) -> void:
	if not multiplayer.is_server(): return
	_defense_manager.notify_heal_received(heal_amount)
	_net_take_heal.rpc(source.player.id, heal_amount)

# ============================== Callback ==============================

func _on_events_attack_done(source, target, damage, damage_type, is_critical) -> void:
	if target != _source: return
	_take_damage(source, damage, damage_type, is_critical)


func _on_events_heal_done(source, target, heal_amount) -> void:
	if target != _source: return
	_take_heal(source, heal_amount)


func _on_events_condition_stacks_done(source, target, stacks_number, stack_type) -> void:
	if target != _source: return
	_take_condition_stacks(source, stacks_number, stack_type)
