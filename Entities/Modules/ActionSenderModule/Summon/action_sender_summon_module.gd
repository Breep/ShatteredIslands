class_name ActionSenderSummonModule
extends ActionSenderModule

var _spawn_manager: SpawnManager
var _arena_zone_manager: ArenaZoneManager

const SNAKE_BARREL_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Poison/SnakeBarrel/snake_barrel.tscn")
const SNAKE_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Poison/Snake/snake.tscn")
const FIELD_GENERATOR_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Engineer/FieldGenerator/field_generator.tscn")

const CHICKEN_BASIC_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/ChickenLord/Chicken/Basic/chicken_basic.tscn")
const CHICKEN_ATTACK_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenAttack/chicken_attack.tscn")
const CHICKEN_POISON_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenPoison/chicken_poison.tscn")
const CHICKEN_COLOSSUS_SCENE: PackedScene = preload('res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenColossus/chicken_colossus.tscn')
const CHICKEN_LIGHT_SCENE: PackedScene = preload('res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenLight/chicken_light.tscn')
const CHICKEN_ENGINEER_SCENE: PackedScene = preload('res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenEngineer/chicken_engineer.tscn')
const CHICKEN_ARDENT_CELESTIAL_SCENE: PackedScene = preload('res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenArdentCelestial/chicken_ardent_celestial.tscn')
const CHICKEN_STORM_CALLER: PackedScene = preload('res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenStormCaller/chicken_storm_caller.tscn')

const PROTO_SHIELD_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Engineer/ProtoShield/proto_shield.tscn")
const FORTIFICATION_DRONE_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Engineer/FortificationDrone/fortification_drone.tscn")
const AEGIS_BLADE_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Engineer/AegisBlade/aegis_blade.tscn")
const DEFLECTION_SHIELD: PackedScene = preload("res://Entities/NPC/Fighting/Engineer/DeflectionShield/deflection_shield.tscn")

const TREX_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/ChickenLord/TRex/trex.tscn")
const CHICKEN_EGG_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/ChickenLord/ChickenEgg/chicken_egg.tscn")

# ============================== Public functions ==============================

func connect_to_spawn_manager(spawn_manager: SpawnManager) -> void:
	if spawn_manager == null:
		Verbose.error("Trying to connect to a <null> SpawnManager", Verbose.Category.ENTITY_MODULE)
		return
	_spawn_manager = spawn_manager


func connect_to_arena_zone_manager(arena_zone_manager: ArenaZoneManager) -> void:
	if arena_zone_manager == null:
		Verbose.error("Trying to connect to a <null> ArenaZoneManager", Verbose.Category.ENTITY_MODULE)
		return
	_arena_zone_manager = arena_zone_manager


func summon_entity(entity_type: Entity.EntityType, spawn_config: SpawnLocationConfig, entity_modifier: Dictionary) -> void:
	if _owner.status_module.has_status(Status.Type.STUN):
		return

	if _owner.status_module.has_status(Status.Type.SILENCE):
		Verbose.debug("Summon blocked by SILENCE on " + _owner.entity_name, Verbose.Category.ENTITY_MODULE)
		return

	if _spawn_manager == null:
		Verbose.error("Can't summon an entity if no SpawnManager is linked", Verbose.Category.ENTITY_MODULE)
		return

	var spawn_position := spawn_config.resolve(_arena_zone_manager)

	var modifiers_data: Dictionary = _consume_before_action_modifiers(Utils.ActionCategory.SUMMON, {
		ActionModifier.VarType.ENTITY_TYPE: entity_type,
		ActionModifier.VarType.ENTITY_MODIFIER: entity_modifier,
	})
	entity_modifier = modifiers_data.get(ActionModifier.VarType.ENTITY_MODIFIER, entity_modifier)
	entity_type = modifiers_data.get(ActionModifier.VarType.ENTITY_TYPE, entity_type)

	match entity_type:
		Entity.EntityType.SNAKE_BARREL: _summon_snake_barrel(spawn_position, entity_modifier)
		Entity.EntityType.SNAKE: _summon_snake(spawn_position, entity_modifier)
		Entity.EntityType.FIELD_GENERATOR: _summon_field_generator(spawn_position, entity_modifier)
		Entity.EntityType.CHICKEN: _summon_chicken(spawn_position, entity_modifier)
		Entity.EntityType.PROTO_SHIELD: _summon_proto_shield(spawn_position, entity_modifier)
		Entity.EntityType.FORTIFICATION_DRONE: _summon_fortification_drone(spawn_position, entity_modifier)
		Entity.EntityType.AEGIS_BLADE: _summon_aegis_blade(spawn_position, entity_modifier)
		Entity.EntityType.DEFLECTION_SHIELD: _summon_deflection_shield(spawn_position, entity_modifier)
		Entity.EntityType.TREX: _summon_trex(spawn_position, entity_modifier)
		Entity.EntityType.CHICKEN_EGG: _summon_chicken_egg(spawn_position, entity_modifier)

	_consume_after_action_modifiers(Utils.ActionCategory.SUMMON, {
		ActionModifier.VarType.ENTITY_TYPE: entity_type,
		ActionModifier.VarType.ENTITY_MODIFIER: entity_modifier,
	})

# ============================== Private functions ==============================

func _summon_snake_barrel(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var snake_barrel: SnakeBarrel = SNAKE_BARREL_SCENE.instantiate()
	var snake_number: int = entity_modifier[SnakeBarrel.Modifier.SNAKE_NUMBER]
	var snake_poison_stacks: int = entity_modifier[SnakeBarrel.Modifier.SNAKE_POISON_STACKS]
	var max_health: int = entity_modifier[SnakeBarrel.Modifier.MAX_HEALTH]
	snake_barrel.init(snake_number, snake_poison_stacks, max_health)
	_spawn_manager.spawn_entity(snake_barrel, spawn_position, _owner.get_context(), Entity.EntityType.SNAKE_BARREL)


func _summon_snake(spawn_position: Vector3, _entity_modifier: Dictionary) -> void:
	var snake: Snake = SNAKE_SCENE.instantiate()
	_spawn_manager.spawn_entity(snake, spawn_position, _owner.get_context(), Entity.EntityType.SNAKE)


func _summon_field_generator(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var field_generator: FieldGenerator = FIELD_GENERATOR_SCENE.instantiate()
	var max_health: int = entity_modifier.get(FieldGenerator.Modifier.MAX_HEALTH, 1)
	var shield_amount: int = entity_modifier.get(FieldGenerator.Modifier.SHIELD_AMOUNT, 100)
	var shield_interval: float = entity_modifier.get(FieldGenerator.Modifier.SHIELD_INTERVAL, 1.0)
	var initial_shield: int = entity_modifier.get(FieldGenerator.Modifier.INITIAL_SHIELD, 150)
	var target_count: int = entity_modifier.get(FieldGenerator.Modifier.TARGET_COUNT, 2)
	field_generator.init(max_health, shield_amount, shield_interval, initial_shield, target_count)
	_spawn_manager.spawn_entity(field_generator, spawn_position, _owner.get_context(), Entity.EntityType.FIELD_GENERATOR)


func _summon_chicken(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var chicken: Chicken
	var base_hp: float = entity_modifier.get(Chicken.BaseStatsModifier.HP, 50)
	var base_ad: float = entity_modifier.get(Chicken.BaseStatsModifier.AD, 10)
	var base_armor: float = entity_modifier.get(Chicken.BaseStatsModifier.ARMOR, 0)
	var base_crit_chance: float = entity_modifier.get(Chicken.BaseStatsModifier.CRIT_CHANCE, 5)
	var base_crit_multi: float = entity_modifier.get(Chicken.BaseStatsModifier.CRIT_MULTI, 100)
	
	var chicken_type: Chicken.Type = entity_modifier.get("Type", Chicken.Type.BASIC)
	match chicken_type:
		Chicken.Type.BASIC: chicken = CHICKEN_BASIC_SCENE.instantiate()
		Chicken.Type.GIFTED_ATTACK: 
			chicken = CHICKEN_ATTACK_SCENE.instantiate()
			var attack_damage: float = entity_modifier.get("ad", 10)
			var attack_speed: float = entity_modifier.get("as", 10)
			(chicken as ChickenAttack).init(attack_damage, attack_speed)
		Chicken.Type.GIFTED_POISON: 
			chicken = CHICKEN_POISON_SCENE.instantiate()
			var poison_stack_ratio: float = entity_modifier.get("ratio", 0)
			var stacks_number: int = entity_modifier.get("number", 1)
			(chicken as ChickenPoison).init(poison_stack_ratio, stacks_number)
		Chicken.Type.GIFTED_COLOSSUS:
			chicken = CHICKEN_COLOSSUS_SCENE.instantiate()
			var health_max_ratio: float = entity_modifier.get("hpmax", 0)
			(chicken as ChickenColossus).init(health_max_ratio)
		Chicken.Type.GIFTED_LIGHT:
			chicken = CHICKEN_LIGHT_SCENE.instantiate()
			var ratio_regen: float = entity_modifier.get("ratio_regen", 0)
			var heal_strength_modifier: float = entity_modifier.get("inherited_heal_ratio", 0)
			(chicken as ChickenLight).init(ratio_regen, heal_strength_modifier)
		Chicken.Type.GIFTED_ENGINEER:
			chicken = CHICKEN_ENGINEER_SCENE.instantiate()
			var shield_per_attack: int = entity_modifier.get("shield_per_attack", 0)
			var bonus_spawn: int = entity_modifier.get("bonus_spawn", 0)
			var shield_strength_inherited: float = entity_modifier.get("shield_strength_inherited", 0)
			(chicken as ChickenShield).init(bonus_spawn, shield_per_attack, shield_strength_inherited)
		Chicken.Type.GIFTED_ARDENT_CELESTIAL:
			chicken = CHICKEN_ARDENT_CELESTIAL_SCENE.instantiate()
			var ignite_stacks: int = entity_modifier.get("ignite_stacks", 0)
			(chicken as ChickenArdentCelestial).init(ignite_stacks)
		Chicken.Type.GIFTED_STORM_CALLER:
			chicken = CHICKEN_STORM_CALLER.instantiate()
			var crit_chance: float = entity_modifier.get("crit_chance", 0)
			var crit_mult: float = entity_modifier.get("crit_mult", 0)
			(chicken as ChickenStormCaller).init(crit_chance, crit_mult)
			
	chicken.set_base_stats(base_hp, base_ad, base_armor, base_crit_chance, base_crit_multi)
	_spawn_manager.spawn_entity(chicken, spawn_position, _owner.get_context(), Entity.EntityType.CHICKEN)


func _summon_proto_shield(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var proto_shield: ProtoShield = PROTO_SHIELD_SCENE.instantiate()
	var shield_amount: float = entity_modifier.get(ProtoShield.Modifier.SHIELD, 0)
	var hp_max: int = entity_modifier.get(ProtoShield.Modifier.HP_MAX, 1)
	proto_shield.init(shield_amount, hp_max)
	_spawn_manager.spawn_entity(proto_shield, spawn_position, _owner.get_context())


func _summon_fortification_drone(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var fortification_drone: FortificationDrone = FORTIFICATION_DRONE_SCENE.instantiate()
	var shield_amount: float = entity_modifier.get(FortificationDrone.Modifier.SHIELD, 0)
	var hp_max: int = entity_modifier.get(FortificationDrone.Modifier.HP_MAX, 1)
	var shield_per_second: float = entity_modifier.get(FortificationDrone.Modifier.SHIELD_PER_SECOND, 1)
	var respawn_timer: float = entity_modifier.get(FortificationDrone.Modifier.RESPAWN_TIMER, 10.0)
	fortification_drone.init(shield_amount, hp_max, shield_per_second, respawn_timer)
	_spawn_manager.spawn_entity(fortification_drone, spawn_position, _owner.get_context())


func _summon_aegis_blade(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var aegis_blade: AegisBlade = AEGIS_BLADE_SCENE.instantiate()
	var attack_damage: float = entity_modifier.get(AegisBlade.Modifier.AD, 0)
	var attack_speed: float = entity_modifier.get(AegisBlade.Modifier.AS, 1)
	var shield_ad_max: float = entity_modifier.get(AegisBlade.Modifier.SHIELD_AD_MAX, 0)
	var shield_ad_tau: float = entity_modifier.get(AegisBlade.Modifier.SHIELD_AD_TAU, 1)
	var damage_as_shield_ratio: float = entity_modifier.get(AegisBlade.Modifier.DAMAGE_AS_SHIELD, 0)
	aegis_blade.init(attack_damage, attack_speed, shield_ad_max, shield_ad_tau, damage_as_shield_ratio)
	_spawn_manager.spawn_entity(aegis_blade, spawn_position, _owner.get_context())


func _summon_trex(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var trex: TRex = TREX_SCENE.instantiate()
	var gifted_spawn_period: float = entity_modifier.get(TRex.Modifier.PRIMAL_SHAKE_PERIOD, 0)
	var gifted_spawn_number: int = entity_modifier.get(TRex.Modifier.PRIMAL_SHAKE_NUMBER, 0)
	var hp_bonus: float = entity_modifier.get(TRex.Modifier.HP_BONUS, 0)
	trex.init(gifted_spawn_period, gifted_spawn_number, hp_bonus)
	_spawn_manager.spawn_entity(trex, spawn_position, _owner.get_context())

 
func _summon_chicken_egg(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var egg: ChickenEgg = CHICKEN_EGG_SCENE.instantiate()
	var hatch_time: float = entity_modifier.get(ChickenEgg.Modifier.HATCH_TIME, 3.0)
	var chicken_type: Chicken.Type = entity_modifier.get(ChickenEgg.Modifier.CHICKEN_TYPE, Chicken.Type.BASIC)
	var chicken_modifiers: Dictionary = entity_modifier.get(ChickenEgg.Modifier.CHICKEN_MODIFIERS, {})
	var hatch_modifiers: Array[HatchModifier] = entity_modifier.get(ChickenEgg.Modifier.HATCH_MODIFIERS, [] as Array[HatchModifier])
	var opt_scale: float = entity_modifier.get(ChickenEgg.Modifier.SCALE, 1)
	egg.init(hatch_time, chicken_type, chicken_modifiers, hatch_modifiers, opt_scale)
	_spawn_manager.spawn_entity(egg, spawn_position, _owner.get_context(), Entity.EntityType.CHICKEN_EGG)


func _summon_deflection_shield(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var deflection_shield: DeflectionShield = DEFLECTION_SHIELD.instantiate()
	var blocked_projectiles: int = entity_modifier.get(DeflectionShield.Modifier.BLOCKED_PROJECTILES, 1)
	var shield_per_block: float = entity_modifier.get(DeflectionShield.Modifier.SHIELD_PER_BLOCK, 10)
	deflection_shield.init(blocked_projectiles, shield_per_block)
	_spawn_manager.spawn_entity(deflection_shield, spawn_position, _owner.get_context())
	
	
	
