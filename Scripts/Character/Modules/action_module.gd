class_name ActionModule
extends Module

# ============================== Attack ==============================

# [All]
@rpc("authority", "call_local")
func _attack(target_peer_id: int, damage: int, damage_type: Utils.DamageType, is_critical: bool) -> void:
	pass
	# Placer signal pour animation ici ? GameManager.players[target_peer_id].character pour savoir la target


# Lanch an attack on the target
# If no projectile are defined, then the attack will affect immediately the target
#     It means that it will trigger immediatly Events.attack_done signal
# Otherwise a projectile will be spawned at the projectile_spawn location, the projectile
#     will carry all information needed (damage, conditions stacks)
#     The projectile will trigger itself Events.attack_done signal when it reach the target
func attack(target: Character, damage: int, damage_type: Utils.DamageType) -> void:
	if not multiplayer.is_server(): return
	var multiplier = _get_damage_multipliers()
	if damage_type == Utils.DamageType.PHYSICAL:
		damage *= multiplier["physical"]
	elif damage_type == Utils.DamageType.MAGIC:
		damage *= multiplier["magical"]
	
	Events.attack_done.emit(_source, target, damage, damage_type, multiplier["is_critical"])
	#_attack.rpc(target.player.id, damage, damage_type, is_critical)


func projectile_attack(target: Character, projectile_scene: PackedScene, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	if not multiplayer.is_server(): return
	var multiplier = _get_damage_multipliers()
	projectile_stats.is_critic = multiplier["is_critical"]
	projectile_stats.physical_damage_flat *= multiplier["physical"]
	projectile_stats.physical_damage_percent *= multiplier["physical"]
	projectile_stats.magical_damage_flat *= multiplier["magical"]
	projectile_stats.magical_damage_percent *= multiplier["magical"]
	_spawn_projectile(target, projectile_scene, projectile_spawn, projectile_stats)
	#_spawn_projectile.rpc(target, projectile_scene, projectile_spawn, projectile_stats)


func _get_damage_multipliers() -> Dictionary:
	var is_critical: bool
	var physical_multiplier: float = 1.0
	var magical_multiplier: float = 1.0
	
	#if damage_type == Utils.DamageType.PHYSICAL:
	var crit_chance = _source.stats.physical_critical_chance
	if _storm_manager != null:
		crit_chance = _storm_manager.get_critical_chance()
	
	if Utils.is_randomize_modifier_active(crit_chance):
		is_critical = true
		var crit_multiplier = _source.stats.physical_critical_multiplier
		if _storm_manager != null:
			crit_multiplier = _storm_manager.get_critical_multiplier(Utils.DamageType.PHYSICAL)
		physical_multiplier *= crit_multiplier
	
	if _life_manager != null:
		physical_multiplier = _life_manager.get_increased_damage_taken_from_lost_hp(physical_multiplier, Utils.DamageType.PHYSICAL) # Increase % of PHYSICAL damage
	
	if _fire_manager != null:
		magical_multiplier = _fire_manager.get_increased_damage(magical_multiplier, Utils.DamageType.MAGIC) # Increase % of MAGICAL damage
	
	if _defense_manager != null:
		physical_multiplier = _defense_manager.get_reduced_damage_dealed_from_protector(physical_multiplier) # Reduce % of ALL damage
		magical_multiplier = _defense_manager.get_reduced_damage_dealed_from_protector(magical_multiplier) # Reduce % of ALL damage
	
	if _heal_manager != null:
		physical_multiplier = _heal_manager.get_reduced_damage_dealed_from_pacify(physical_multiplier) # Reduce % of ALL damage
		magical_multiplier = _heal_manager.get_reduced_damage_dealed_from_pacify(magical_multiplier) # Reduce % of ALL damage
	
	return { "physical": physical_multiplier, "magical": magical_multiplier, "is_critical": is_critical }


@rpc("authority", "call_local")
func _spawn_projectile(target: Character, projectile_scene: PackedScene, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
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
	pass


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
	pass


# [Server only]
func inflict_condition_stacks(target: Character, stacks_number: int, stack_type: Utils.StackType, poison_duration: int = 0) -> void:
	if not multiplayer.is_server(): return
	Events.condition_stacks_done.emit(_source, target, stacks_number, stack_type, poison_duration)
