class_name ActionModule
extends Module


@export var _poison_manager: PoisonManager

var _spawn_manager: SpawnManager

const METEOR_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Meteor/meteor.tscn")
const DARK_STORM_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/DarkStorm/dark_storm.tscn")
const CONTAGION_SPELL_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Poison/Contagion/contagion_spell_area.tscn")
const SHROOM_SPELL_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Poison/Shroom/shroom_spell.tscn")
const DEATH_FOG_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Poison/DeathFog/death_fog.tscn")

const SNAKE_BARREL_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Poison/SnakeBarrel/snake_barrel.tscn")
const SNAKE_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Poison/Snake/snake.tscn")

# ============================== Public functions ==============================

func connect_to_spawn_manager(spawn_manager: SpawnManager) -> void:
	if spawn_manager == null:
		printerr("ActionModule: Trying to connect to a <null> SpawnManager")
		return
	
	_spawn_manager = spawn_manager

#region ============================== Attack ==============================

# Instantly attack the target - Apply cards damages multiplier if there are some
func direct_attack(target: Entity, damage: int, damage_type: Utils.DamageType) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var multiplier = _get_crit_multiplier(Utils.damage_to_action(damage_type))
	damage *= multiplier["multiplier"]
	target.take_damage(damage, damage_type, multiplier["is_critical"], _owner)


# Instantly attack the target - Apply cards damages multiplier if there are some
func direct_attack_percent(target: Entity, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var hp: int
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - _owner.stats.health
	var damage = hp * damage_percent  / 100.0
	direct_attack(target, damage, damage_type)


# Create a projectile to attack the target - Apply cards damages multiplier if there are some
func build_projectile_attack(target: Entity, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> AttackCommand:
	if not multiplayer.is_server(): return
	if target == null: return
	var physical_multiplier = _get_crit_multiplier(Utils.ActionType.DAMAGE_PHYSICAL)
	projectile_stats.physical_is_critical = physical_multiplier["is_critical"]
	projectile_stats.physical_damage_flat *= physical_multiplier["multiplier"]
	projectile_stats.physical_damage_percent *= physical_multiplier["multiplier"]
	
	var magical_multiplier = _get_crit_multiplier(Utils.ActionType.DAMAGE_MAGICAL)
	projectile_stats.magical_is_critical = magical_multiplier["is_critical"]
	projectile_stats.magical_damage_flat *= magical_multiplier["multiplier"]
	projectile_stats.magical_damage_percent *= magical_multiplier["multiplier"]
	
	var poison_stacks_multiplier = _get_crit_multiplier(Utils.ActionType.DAMAGE_POISON)
	projectile_stats.poison_stacks_is_critical = poison_stacks_multiplier["is_critical"]
	projectile_stats.poison_stacks *= poison_stacks_multiplier["multiplier"]
	return AttackCommand.new().setup(target, projectile_type, projectile_spawn, projectile_stats)


func projectile_attack(target: Entity, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	_spawn_manager.spawn_projectile(_owner, target, projectile_type, projectile_spawn, projectile_stats)

func _spawn_projectile(target: Entity, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	if target == null: return
	_spawn_manager.spawn_projectile(_owner, target, projectile_type, projectile_spawn, projectile_stats)
#endregion

#region ============================== Heal ==============================
# [Server only]
func heal(target: Entity, heal_amount: int) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var multipliers = _get_crit_multiplier(Utils.ActionType.UTILITY_HEAL)
	heal_amount *= multipliers["multiplier"]
	target.take_heal(heal_amount, multipliers["is_critical"], _owner)


func heal_percent(target: Entity, percent: float, percent_modifier: Utils.PercentModifier) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var hp: int
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - _owner.stats.health
	var heal_amount: int = floor((percent * hp as float) / 100.0)
	heal(target, heal_amount)
#endregion

#region ============================== Condition stacks ==============================
# [Server only]
func inflict_condition_stacks(target: Entity, stacks_number: int, stack_type: Utils.StackType) -> void:
	if not multiplayer.is_server(): return
	if target == null: return
	var stack_multiplier = _get_crit_multiplier(Utils.stack_to_action(stack_type))
	stacks_number *= stack_multiplier["multiplier"]
	_check_on_inflict_condition_stacks_modifier(target, stacks_number, stack_type)
	target.take_condition_stacks(stacks_number, stack_type, stack_multiplier["is_critical"], _owner)


#TODO Use a StackModifier like the AutoAttackModifier to remove dependancies between action module and family managers
func _check_on_inflict_condition_stacks_modifier(target: Entity, stacks_number: int, stack_type: Utils.StackType) -> void:
	if _poison_manager != null:
		_poison_manager.check_on_apply_poison_stack(target, stacks_number, stack_type)
#endregion

#region ============================== Spells ==============================
func cast_spell(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary = {}) -> void:
	match spell_type:
		Spell.Type.METEOR: _cast_meteor(target, spell_modifier)
		Spell.Type.DARK_STORM: _cast_dark_storm(target, spell_modifier)
		Spell.Type.CONTAGION: _cast_contagion(spell_modifier)
		Spell.Type.SHROOM: _cast_shroom(target, spell_modifier)
		Spell.Type.DEATH_FOG: _cast_death_fog(spell_modifier)


func _cast_meteor(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null: return
	_owner.signal_spell_casted(target, Spell.Type.METEOR)
	var meteor: Meteor = METEOR_SCENE.instantiate()
	if multiplayer.is_server():
		var ignite_stacks: int = spell_modifier[Spell.MeteorModifier.IGNITE_STACKS]
		var damage_per_stack: int = spell_modifier[Spell.MeteorModifier.DAMAGE_PER_STACK]
		meteor.init(target, ignite_stacks, damage_per_stack, _owner)
	else:
		meteor.init(target, 0, 0, _owner)
	_spawn_manager.spawn_spell(meteor)


func _cast_dark_storm(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null: return
	_owner.signal_spell_casted(target, Spell.Type.DARK_STORM)
	var dark_storm: DarkStorm = DARK_STORM_SCENE.instantiate()
	if multiplayer.is_server():
		var damage: int = spell_modifier[Spell.DarkStormModifier.DAMAGE]
		var period: float = spell_modifier[Spell.DarkStormModifier.PERIOD]
		var lifespan: float = spell_modifier[Spell.DarkStormModifier.LIFESPAN]
		var pain_stack_percent: float = spell_modifier[Spell.DarkStormModifier.PAIN_STACK_PERCENT]
		dark_storm.init(target, damage, period, lifespan, _owner, pain_stack_percent)
	else:
		dark_storm.init(target, 0, 0, 0, _owner)
	_spawn_manager.spawn_spell(dark_storm)


func _cast_contagion(spell_modifier: Dictionary) -> void:
	_owner.signal_spell_casted(_owner, Spell.Type.CONTAGION)
	var contagion: ContagionSpellArea = CONTAGION_SPELL_SCENE.instantiate()
	if multiplayer.is_server():
		var radius: float = spell_modifier[Spell.ContagionModifier.RADIUS]
		var spread_percent: float = spell_modifier[Spell.ContagionModifier.SPREAD_PERCENT]
		contagion.init(_owner, radius, spread_percent)
	_spawn_manager.spawn_spell(contagion)


func _cast_shroom(target: Entity, spell_modifier: Dictionary) -> void:
	_owner.signal_spell_casted(_owner, Spell.Type.CONTAGION)
	var shroom: Shroom = SHROOM_SPELL_SCENE.instantiate()
	if multiplayer.is_server():
		var radius: float = spell_modifier[Spell.ShroomModifier.RADIUS]
		var life_time: float = spell_modifier[Spell.ShroomModifier.LIFE_TIME]
		var damage: int = spell_modifier[Spell.ShroomModifier.DAMAGE]
		shroom.init(_owner, target, damage, radius, life_time)
	_spawn_manager.spawn_spell(shroom)


func _cast_death_fog(spell_modifier: Dictionary) -> void:
	_owner.signal_spell_casted(_owner, Spell.Type.DEATH_FOG)
	var death_fog: DeathFog = DEATH_FOG_SCENE.instantiate()
	if multiplayer.is_server():
		var grow_speed: float = spell_modifier[Spell.DeathFogModifier.GROW_SPEED]
		var tick_period: float = spell_modifier[Spell.DeathFogModifier.TICK_PERIOD]
		var damage_multiplier: float = spell_modifier[Spell.DeathFogModifier.DAMAGE_MULTIPLIER]
		death_fog.init(_owner, grow_speed, tick_period, damage_multiplier)
	_spawn_manager.spawn_spell(death_fog)
#endregion

#region  ============================== Summon ==============================
func summon_entity(entity_type: Entity.EntityType, entity_spawn_global_position: Vector3, entity_modifier: Dictionary) -> void:
	if _spawn_manager == null:
		push_error("ActionModule: Can't summon an entity if no SpawnManager is linked to me [", get_path(), "]")
		return
	match entity_type:
		Entity.EntityType.CHARACTER: print("Summon a character ? I think not !")
		Entity.EntityType.SNAKE_BARREL:  _summon_snake_barrel(entity_spawn_global_position, entity_modifier)
		Entity.EntityType.SNAKE: _summon_snake(entity_spawn_global_position, entity_modifier)


func _summon_snake_barrel(entity_spawn_global_position: Vector3, entity_modifier: Dictionary) -> void:
	var snake_barrel: SnakeBarrel = SNAKE_BARREL_SCENE.instantiate()
	if multiplayer.is_server():
		var snake_number: int = entity_modifier[Entity.SnakeBarrelModifier.SNAKE_NUMBER]
		var snake_poison_stacks: int = entity_modifier[Entity.SnakeBarrelModifier.SNAKE_POISON_STACKS]
		var max_health: int = entity_modifier[Entity.SnakeBarrelModifier.MAX_HEALTH]
		snake_barrel.init(snake_number, snake_poison_stacks, max_health)
	snake_barrel.team = _owner.team
	_spawn_manager.spawn_entity(snake_barrel, entity_spawn_global_position)


func _summon_snake(entity_spawn_global_position: Vector3, _entity_modifier: Dictionary) -> void:
	var snake: Snake = SNAKE_SCENE.instantiate()
	snake.team = _owner.team
	_spawn_manager.spawn_entity(snake, entity_spawn_global_position)
	print("SUMMON SNAKE")
#endregion

#region ===== Private functions
func _get_crit_multiplier(action_type: Utils.ActionType) -> Dictionary:
	var is_critical: bool = false
	var crit_chance: float = _owner.stats.get_stat(EntityStats.StatType.CRIT_CHANCE, action_type)
	var crit_multiplier_percent: float = 0.0
	
	if Utils.is_randomize_modifier_active(crit_chance):
		is_critical = true
		crit_multiplier_percent = _owner.stats.get_stat(EntityStats.StatType.CRIT_MULT, action_type)
	
	return { "multiplier": remap(crit_multiplier_percent, 0, 100, 1, 2), "is_critical": is_critical } 
