class_name ActionModule
extends Module

signal heal_done()
signal attack_done()
signal condition_stacks_done()

# ============================== Attack ==============================

# [All]
@rpc("authority", "call_local")
func _attack(target_peer_id: int, damage: int, damage_type: Utils.DamageType, is_critical: bool) -> void:
	attack_done.emit()
	# Placer signal pour animation ici ? GameManager.players[target_peer_id].character pour savoir la target


# Lanch an attack on the target
# If no projectile are defined, then the attack will affect immediately the target
#     It means that it will trigger immediatly Events.attack_done signal
# Otherwise a projectile will be spawned at the projectile_spawn location, the projectile
#     will carry all information needed (damage, conditions stacks)
#     The projectile will trigger itself Events.attack_done signal when it reach the target
func attack(target: Character, damage: int, damage_type: Utils.DamageType, 
			projectile_scene: PackedScene = null, projectile_spawn: Node3D = null, projectile_stats: ProjectileStats = null) -> void:
	var res = _get_updated_damage(damage, damage_type)
	damage = res["damage"]
	var is_critical = res["is_critical"]
	
	if projectile_scene == null:
		Events.attack_done.emit(_source, target, damage, damage_type, is_critical)
	else:
		projectile_stats.is_critic = is_critical
		_spawn_projectile(target, damage, damage_type, projectile_scene, projectile_spawn, projectile_stats)
	
	_attack.rpc(target.player.id, damage, damage_type, is_critical)


func _get_updated_damage(damage: int, damage_type: Utils.DamageType) -> Dictionary:
	var is_critical: bool
	if damage_type == Utils.DamageType.PHYSICAL:
		var crit_chance = _source.stats.physical_critical_chance
		if _storm_manager != null:
			crit_chance = _storm_manager.get_critical_chance()
		
		if Utils.is_randomize_modifier_active(crit_chance):
			is_critical = true
			var crit_multiplier = _source.stats.physical_critical_multiplier
			if _storm_manager != null:
				crit_multiplier = _storm_manager.get_critical_multiplier(Utils.DamageType.PHYSICAL)
			damage *= crit_multiplier
		
		if _life_manager != null:
			damage = _life_manager.get_increased_damage_taken_from_lost_hp(damage, damage_type) # Increase % of PHYSICAL damage
	
	if damage_type == Utils.DamageType.MAGIC && _fire_manager != null:
		damage = _fire_manager.get_increased_damage(damage, damage_type) # Increase % of MAGICAL damage
	
	if _defense_manager != null:
		damage = _defense_manager.get_reduced_damage_dealed_from_protector(damage) # Reduce % of ALL damage
	
	if _heal_manager != null:
		damage = _heal_manager.get_reduced_damage_dealed_from_pacify(damage) # Reduce % of ALL damage
	
	return { "damage": damage, "is_critical": is_critical }


func _spawn_projectile(target: Character, damage: int, damage_type: Utils.DamageType, 
				projectile_scene: PackedScene, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.init(_source, target, projectile_stats)
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = projectile_spawn.global_position + Vector3(randf_range(-0.01, 0.01), randf_range(-0.01, 0.01), randf_range(-0.01, 0.01))


func attack_percent(target: Character, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier) -> void:
	if not multiplayer.is_server(): return
	var hp: int
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - _source.stats.health
	var damage = hp * damage_percent  / 100.0
	attack(target, damage, damage_type)

# ============================== Heal ==============================

@rpc("authority", "call_local")
func _heal(target_peer_id: int, heal_amount: int) -> void:
	print("[", multiplayer.get_unique_id(), "] _heal()")
	heal_done.emit()


# [Server only]
func heal(target: Character, heal_amount: int) -> void:
	if not multiplayer.is_server(): return
	#signal heal_done(source, target, heal_amount)
	Events.heal_done.emit(_source, target, heal_amount)
	#target.take_heal(_source, heal_amount)
	#_heal_manager.notify_heal()
	_heal.rpc(target.player.id, heal_amount)


func heal_percent(target: Character, heal_percent: float, percent_modifier: Utils.PercentModifier) -> void:
	if not multiplayer.is_server(): return
	var hp: int
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - _source.stats.health
	var heal_amount: int = (heal_percent * hp) / 100
	heal(target, heal_amount)

# ============================== Condition stacks ==============================

@rpc("authority", "call_local")
func _inflict_condition_stacks(stacks_number: int, stack_type: Utils.StackType, source_id: int = -1, poison_duration: int = 0) -> void:
	print("[", multiplayer.get_unique_id(), "] _take_condition_stacks()")


# [Server only]
func inflict_condition_stacks(target: Character, stacks_number: int, stack_type: Utils.StackType, poison_duration: int = 0) -> void:
	if not multiplayer.is_server(): return
	Events.condition_stacks_done.emit(_source, target, stacks_number, stack_type, poison_duration)
