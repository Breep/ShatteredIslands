class_name ActionModule
extends Module

var _spawn_manager: SpawnManager

const METEOR_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Meteor/meteor.tscn")
const DARK_STORM_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/DarkStorm/dark_storm.tscn")
const CONTAGION_SPELL_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Poison/Contagion/contagion_spell_area.tscn")
const SHROOM_SPELL_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Poison/Shroom/shroom_spell.tscn")
const DEATH_FOG_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Poison/DeathFog/death_fog.tscn")
const LIGHTNING_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Lightning/Lightning/spell_lightning.tscn")
const CHAIN_LIGHTNING_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/ChainLightning/spell_chain_lightning.tscn")


const SNAKE_BARREL_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Poison/SnakeBarrel/snake_barrel.tscn")
const SNAKE_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Poison/Snake/snake.tscn")
const FIELD_GENERATOR_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Defense/FieldGenerator/field_generator.tscn")

# ============================== Public functions ==============================

func connect_to_spawn_manager(spawn_manager: SpawnManager) -> void:
	Verbose.debug("connect_to_spawn_manager() | " + str(spawn_manager), Verbose.Category.ENTITY_MODULE)
	if spawn_manager == null:
		printerr("ActionModule: Trying to connect to a <null> SpawnManager")
		return
	
	_spawn_manager = spawn_manager

#region ============================== Attack ==============================
# Instantly attack the target - Apply cards damages multiplier if there are some
func direct_attack(target: Entity, damage: float, damage_type: Utils.DamageType, action_id: StringName) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var damage_before_crit: float = damage * _get_strenght_weakness_multiplier(Utils.damage_to_action(damage_type))
	var crit_multiplier = _get_crit_multiplier(Utils.damage_to_action(damage_type))
	damage = damage_before_crit * crit_multiplier["multiplier"]
	var damage_done: float = target.take_damage(damage, damage_type, crit_multiplier["is_critical"], action_id, _owner)
	if crit_multiplier["is_critical"]:
		_owner.signal_critical_action_done(target, Utils.damage_to_action(damage_type), damage_before_crit, damage_done)
	_owner.signal_action_done(target, Utils.damage_to_action(damage_type), action_id, damage_done, crit_multiplier["is_critical"])


# Instantly attack the target - Apply cards damages multiplier if there are some
func direct_attack_percent(target: Entity, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier, action_id: StringName) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var hp: float
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - target.stats.health
	var damage: float = hp * damage_percent / 100.0
	direct_attack(target, damage, damage_type, action_id)


# Create a projectile to attack the target - Apply cards damages multiplier if there are some
func build_projectile_attack(target: Entity, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> AttackCommand:
	if target == null:
		Verbose.warn("build_projectile_attack() -> No target", Verbose.Category.ENTITY_MODULE)
		return
	
	if multiplayer.is_server():
		var physical_multiplier = _get_crit_multiplier(Utils.ActionType.DAMAGE_PHYSICAL)
		projectile_stats.physical_is_critical = physical_multiplier["is_critical"]
		projectile_stats.physical_base_damage = projectile_stats.physical_damage_flat * _get_strenght_weakness_multiplier(Utils.ActionType.DAMAGE_PHYSICAL)
		projectile_stats.physical_damage_flat = projectile_stats.physical_base_damage * physical_multiplier["multiplier"]
		#projectile_stats.physical_damage_percent *= physical_multiplier["multiplier"] * _get_strenght_weakness_multiplier(Utils.ActionType.DAMAGE_PHYSICAL)
		
		var magical_multiplier = _get_crit_multiplier(Utils.ActionType.DAMAGE_MAGICAL)
		projectile_stats.magical_is_critical = magical_multiplier["is_critical"]
		projectile_stats.magical_base_damage = projectile_stats.magical_damage_flat * _get_strenght_weakness_multiplier(Utils.ActionType.DAMAGE_MAGICAL)
		projectile_stats.magical_damage_flat = projectile_stats.magical_base_damage * magical_multiplier["multiplier"]
		#projectile_stats.magical_damage_percent *= magical_multiplier["multiplier"] * _get_strenght_weakness_multiplier(Utils.ActionType.DAMAGE_MAGICAL)
		
		var poison_stacks_multiplier = _get_crit_multiplier(Utils.ActionType.DAMAGE_POISON)
		projectile_stats.poison_stacks_is_critical = poison_stacks_multiplier["is_critical"]
		projectile_stats.poison_stacks *= poison_stacks_multiplier["multiplier"] * _get_strenght_weakness_multiplier(Utils.ActionType.STACK_POISON)
	
	return AttackCommand.new().setup(target, projectile_type, projectile_spawn, projectile_stats)


func projectile_attack(target: Entity, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	_spawn_manager.spawn_projectile(_owner, target, projectile_type, projectile_spawn, projectile_stats)


func _spawn_projectile(target: Entity, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	if target == null: return
	_spawn_manager.spawn_projectile(_owner, target, projectile_type, projectile_spawn, projectile_stats)
#endregion


#region ============================== Heal ==============================
# [Server only]
func heal(target: Entity, heal_amount: float, action_id: StringName) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	
	if _owner.action_modifiers_registry != null:
		var modifiers_dict: Dictionary = {
			ActionModifier.VarType.HEAL_AMOUNT: heal_amount,
			ActionModifier.VarType.TARGET: target
		}
		for modifier: ActionModifier in _owner.action_modifiers_registry.get_all_modifiers(ActionModifier.ActionType.HEAL):
			if modifier.before_action_logic_callback.is_valid():
				modifier.before_action_logic_callback.call(modifiers_dict)
		heal_amount = modifiers_dict[ActionModifier.VarType.HEAL_AMOUNT]
	
	var heal_amount_before_crit: float = heal_amount * _get_strenght_weakness_multiplier(Utils.ActionType.UTILITY_HEAL)
	var crit_multiplier = _get_crit_multiplier(Utils.ActionType.UTILITY_HEAL)
	heal_amount = heal_amount_before_crit * crit_multiplier["multiplier"]
	var heal_taken: float = target.take_heal(heal_amount, crit_multiplier["is_critical"], action_id, _owner)
	
	var overheal_amount: float = heal_amount - heal_taken
	if overheal_amount > 0:
		_owner.signal_action_overhealed(target, overheal_amount)
		
	if crit_multiplier["is_critical"]:
		_owner.signal_critical_action_done(target, Utils.ActionType.UTILITY_HEAL, heal_amount_before_crit, heal_taken)
	_owner.signal_action_done(target, Utils.ActionType.UTILITY_HEAL, action_id, heal_taken, crit_multiplier["is_critical"])


func heal_percent(target: Entity, percent: float, percent_modifier: Utils.PercentModifier, action_id: StringName) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var hp: float
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - target.stats.health
	var heal_amount: float = (percent * hp as float) / 100.0
	heal(target, heal_amount, action_id)
#endregion


#region ============================== Condition stacks ==============================
# [Server only]
func inflict_condition_stacks(target: Entity, stacks_number: float, stack_type: Utils.StackType, action_id: StringName, duration: float = 5.0) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var stacks_number_before_crit: float = stacks_number * _get_strenght_weakness_multiplier(Utils.stack_to_action(stack_type))
	var crit_multiplier = _get_crit_multiplier(Utils.stack_to_action(stack_type))
	stacks_number = stacks_number_before_crit * crit_multiplier["multiplier"]
	if _owner.action_modifiers_registry != null:
		var modifiers_dict: Dictionary = {
			ActionModifier.VarType.STACK_VALUE: stacks_number,
			ActionModifier.VarType.STACK_TYPE: stack_type,
			ActionModifier.VarType.TARGET: target,
			ActionModifier.VarType.DURATION: duration
		}
		for condition_modifier: ActionModifier in _owner.action_modifiers_registry.get_all_modifiers(ActionModifier.ActionType.INFLICT_CONDITION):
			if condition_modifier.before_action_logic_callback.is_valid():
				condition_modifier.before_action_logic_callback.call(modifiers_dict)
		
		# Update values from modifiers
		stacks_number = modifiers_dict[ActionModifier.VarType.STACK_VALUE]
		duration = modifiers_dict[ActionModifier.VarType.DURATION]
	
	
	var stacks_taken: float = target.take_condition_stacks(stacks_number, stack_type, crit_multiplier["is_critical"], action_id, _owner, duration)
	if crit_multiplier["is_critical"]:
		_owner.signal_critical_action_done(target, Utils.stack_to_action(stack_type), stacks_number_before_crit, stacks_taken)
	_owner.signal_action_done(target, Utils.stack_to_action(stack_type), action_id, stacks_taken, crit_multiplier["is_critical"])
	
	if _owner.action_modifiers_registry != null:
		var modifiers_dict: Dictionary = {
			ActionModifier.VarType.STACK_VALUE: stacks_number,
			ActionModifier.VarType.STACK_TYPE: stack_type,
			ActionModifier.VarType.TARGET: target,
			ActionModifier.VarType.DURATION: duration
		}
		for condition_modifier: ActionModifier in _owner.action_modifiers_registry.get_all_modifiers(ActionModifier.ActionType.INFLICT_CONDITION):
			if condition_modifier.after_action_logic_callback.is_valid():
				condition_modifier.after_action_logic_callback.call(modifiers_dict)
#endregion


#region ============================== Cleanse and Dispell ==============================
# Removes debuf
func cleanse(target: Entity, value: float, action_id: StringName) -> void:
	if target == null or target.is_queued_for_deletion(): return
	var value_before_crit: float = value * _get_strenght_weakness_multiplier(Utils.ActionType.UTILITY_CLEANSE)
	var crit_multiplier: Dictionary = _get_crit_multiplier(Utils.ActionType.UTILITY_CLEANSE)
	value = value_before_crit * crit_multiplier["multiplier"]
	var stack_removed: float = target.take_cleanse(value, crit_multiplier["is_critical"], action_id, _owner)
	if crit_multiplier["is_critical"]:
		_owner.signal_critical_action_done(target, Utils.ActionType.UTILITY_CLEANSE, value_before_crit, stack_removed)
	_owner.signal_action_done(target, Utils.ActionType.UTILITY_CLEANSE, action_id, value, crit_multiplier["is_critical"])


#Removes buf
func dispell(target: Entity, value: float, action_id: StringName) -> void:
	if target == null or target.is_queued_for_deletion(): return
	var value_before_crit: float = value * _get_strenght_weakness_multiplier(Utils.ActionType.UTILITY_DISPELL)
	var crit_multiplier: Dictionary = _get_crit_multiplier(Utils.ActionType.UTILITY_DISPELL)
	value = value_before_crit * crit_multiplier["multiplier"]
	var stack_removed: float = target.take_dispell(value, crit_multiplier["is_critical"], action_id, _owner)
	if crit_multiplier["is_critical"]:
		_owner.signal_critical_action_done(target, Utils.ActionType.UTILITY_DISPELL, value_before_crit, stack_removed)
	_owner.signal_action_done(target, Utils.ActionType.UTILITY_DISPELL, action_id, value, crit_multiplier["is_critical"])
#endregion


#region ============================== Spells ==============================
func cast_spell(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary = {}) -> void:
	match spell_type:
		Spell.Type.METEOR: _cast_meteor(target, spell_modifier)
		Spell.Type.DARK_STORM: _cast_dark_storm(target, spell_modifier)
		Spell.Type.CONTAGION: _cast_contagion(spell_modifier)
		Spell.Type.SHROOM: _cast_shroom(target, spell_modifier)
		Spell.Type.DEATH_FOG: _cast_death_fog(spell_modifier)
		Spell.Type.LIGHTNING: _cast_lightning(target, spell_modifier)
		Spell.Type.CHAIN_LIGHTNING: _cast_chain_lightning(target, spell_modifier)
		_: push_error("ActionModule: Unknown spell [", get_path(), "] [", spell_type, "]")


func _cast_meteor(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null:
		Verbose.error("_cast_meteor() -> No target", Verbose.Category.ENTITY_MODULE)
		return
	_owner.signal_spell_casted(target, Spell.Type.METEOR, spell_modifier)
	var meteor: Meteor = METEOR_SCENE.instantiate()
	var damage_percent: float = spell_modifier.get(Spell.MeteorModifier.DAMAGE_PERCENT, 0)
	var radius: float = spell_modifier.get(Spell.MeteorModifier.RADIUS, 1)
	var on_hit_callbacks: Array = spell_modifier.get(Spell.MeteorModifier.ON_HIT_CALLBACKS, [])
	meteor.init(target, damage_percent, radius, on_hit_callbacks, _owner)
	_spawn_manager.spawn_spell(meteor)


func _cast_dark_storm(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null:
		Verbose.error("_cast_dark_storm() -> No target", Verbose.Category.ENTITY_MODULE)
		return
	_owner.signal_spell_casted(target, Spell.Type.DARK_STORM, spell_modifier)
	var dark_storm: DarkStorm = DARK_STORM_SCENE.instantiate()
	var damage: int = spell_modifier[Spell.DarkStormModifier.DAMAGE]
	var period: float = spell_modifier[Spell.DarkStormModifier.PERIOD]
	var lifespan: float = spell_modifier[Spell.DarkStormModifier.LIFESPAN]
	var pain_stack_percent: float = spell_modifier[Spell.DarkStormModifier.PAIN_STACK_PERCENT]
	dark_storm.init(target, damage, period, lifespan, _owner, pain_stack_percent)
	_spawn_manager.spawn_spell(dark_storm)


func _cast_contagion(spell_modifier: Dictionary) -> void:
	_owner.signal_spell_casted(_owner, Spell.Type.CONTAGION, spell_modifier)
	var contagion: ContagionSpellArea = CONTAGION_SPELL_SCENE.instantiate()
	var radius: float = spell_modifier[Spell.ContagionModifier.RADIUS]
	var spread_percent: float = spell_modifier[Spell.ContagionModifier.SPREAD_PERCENT]
	contagion.init(_owner, radius, spread_percent)
	_spawn_manager.spawn_spell(contagion)


func _cast_shroom(target: Entity, spell_modifier: Dictionary) -> void:
	_owner.signal_spell_casted(_owner, Spell.Type.CONTAGION, spell_modifier)
	var shroom: Shroom = SHROOM_SPELL_SCENE.instantiate()
	var radius: float = spell_modifier[Spell.ShroomModifier.RADIUS]
	var life_time: float = spell_modifier[Spell.ShroomModifier.LIFE_TIME]
	var damage: int = spell_modifier[Spell.ShroomModifier.DAMAGE]
	shroom.init(_owner, target, damage, radius, life_time)
	_spawn_manager.spawn_spell(shroom)


func _cast_death_fog(spell_modifier: Dictionary) -> void:
	_owner.signal_spell_casted(_owner, Spell.Type.DEATH_FOG, spell_modifier)
	var death_fog: DeathFog = DEATH_FOG_SCENE.instantiate()
	var grow_speed: float = spell_modifier[Spell.DeathFogModifier.GROW_SPEED]
	var tick_period: float = spell_modifier[Spell.DeathFogModifier.TICK_PERIOD]
	var damage_multiplier: float = spell_modifier[Spell.DeathFogModifier.DAMAGE_MULTIPLIER]
	death_fog.init(_owner, grow_speed, tick_period, damage_multiplier)
	_spawn_manager.spawn_spell(death_fog)


func _cast_lightning(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null:
		Verbose.error("_cast_lightning() -> No target", Verbose.Category.ENTITY_MODULE)
		return
	_owner.signal_spell_casted(target, Spell.Type.LIGHTNING, spell_modifier)
	var lightning: SpellLightning = LIGHTNING_SCENE.instantiate()
	var damage: float = spell_modifier[Spell.LightningModifier.DAMAGE]
	lightning.init(_owner, target, damage)
	_spawn_manager.spawn_spell(lightning)


func _cast_chain_lightning(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null:
		Verbose.error("_cast_chain_lightning() -> No target", Verbose.Category.ENTITY_MODULE)
		return
	_owner.signal_spell_casted(target, Spell.Type.CHAIN_LIGHTNING, spell_modifier)
	var chain_lightning: SpellChainLightning = CHAIN_LIGHTNING_SCENE.instantiate()
	chain_lightning.init(_owner, target, spell_modifier)
	_spawn_manager.spawn_spell(chain_lightning)
	
#endregion


#region  ============================== Summon ==============================
func summon_entity(entity_type: Entity.EntityType, spawn_config: SpawnLocationConfig, entity_modifier: Dictionary) -> void:
	if _spawn_manager == null:
		push_error("ActionModule: Can't summon an entity if no SpawnManager is linked to me [", get_path(), "]")
		return
	
	# Get arena zone manager from owner's fighting area
	var arena_zone_manager: ArenaZoneManager = null
	if _owner is Hero and _owner.fighting_area != null:
		arena_zone_manager = _owner.fighting_area.arena_zone_manager
	
	# Resolve spawn position with owner's team
	var spawn_position := spawn_config.resolve(arena_zone_manager, _owner.team)
	
	match entity_type:
		Entity.EntityType.SNAKE_BARREL: _summon_snake_barrel(spawn_position, entity_modifier)
		Entity.EntityType.SNAKE: _summon_snake(spawn_position, entity_modifier)
		Entity.EntityType.FIELD_GENERATOR: _summon_field_generator(spawn_position, entity_modifier)


func _summon_snake_barrel(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var snake_barrel: SnakeBarrel = SNAKE_BARREL_SCENE.instantiate()
	if multiplayer.is_server():
		var snake_number: int = entity_modifier[Entity.SnakeBarrelModifier.SNAKE_NUMBER]
		var snake_poison_stacks: int = entity_modifier[Entity.SnakeBarrelModifier.SNAKE_POISON_STACKS]
		var max_health: int = entity_modifier[Entity.SnakeBarrelModifier.MAX_HEALTH]
		snake_barrel.init(snake_number, snake_poison_stacks, max_health)
	snake_barrel.team = _owner.team
	_spawn_manager.spawn_entity(snake_barrel, spawn_position)


func _summon_snake(spawn_position: Vector3, _entity_modifier: Dictionary) -> void:
	var snake: Snake = SNAKE_SCENE.instantiate()
	snake.team = _owner.team
	_spawn_manager.spawn_entity(snake, spawn_position)
	print("SUMMON SNAKE")
	
	
func _summon_field_generator(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var field_generator: FieldGenerator = FIELD_GENERATOR_SCENE.instantiate()
	if multiplayer.is_server():
		var max_health: int = entity_modifier.get(Entity.FieldGeneratorModifier.MAX_HEALTH, 1)
		var shield_amount: int = entity_modifier.get(Entity.FieldGeneratorModifier.SHIELD_AMOUNT, 100)
		var shield_interval: float = entity_modifier.get(Entity.FieldGeneratorModifier.SHIELD_INTERVAL, 1.0)
		var initial_shield: int = entity_modifier.get(Entity.FieldGeneratorModifier.INITIAL_SHIELD, 150)
		var target_count: int = entity_modifier.get(Entity.FieldGeneratorModifier.TARGET_COUNT, 2)
		field_generator.init(max_health, shield_amount, shield_interval, initial_shield, target_count)
	
	field_generator.team = _owner.team
	_spawn_manager.spawn_entity(field_generator, spawn_position)
#endregion


#region ===== Private functions
func _get_crit_multiplier(action_type: Utils.ActionType) -> Dictionary:
	var is_critical: bool = false
	var crit_chance: float = _owner.stats.get_stat(EntityStats.StatType.CRIT_CHANCE, action_type)
	var crit_multiplier_percent: float = 0.0
	
	if Utils.is_randomize_modifier_active(crit_chance):
		is_critical = true
		crit_multiplier_percent = _owner.stats.get_stat(EntityStats.StatType.CRIT_MULT, action_type)
	
	return {"multiplier": remap(crit_multiplier_percent, 0, 100, 1, 2), "is_critical": is_critical}

func _get_strenght_weakness_multiplier(action_type: Utils.ActionType) -> float:
	var strength: float = _owner.stats.get_stat(EntityStats.StatType.STRENGTH, action_type)
	var weakness: float = _owner.stats.get_stat(EntityStats.StatType.WEAKNESS, action_type)
	return (100.0 + strength) / (100.0 + weakness)
#endregion
