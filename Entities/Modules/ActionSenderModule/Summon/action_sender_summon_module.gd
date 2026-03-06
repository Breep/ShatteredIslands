class_name ActionSenderSummonModule
extends ActionSenderModule

var _spawn_manager: SpawnManager
var _arena_zone_manager: ArenaZoneManager

const SNAKE_BARREL_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Poison/SnakeBarrel/snake_barrel.tscn")
const SNAKE_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Poison/Snake/snake.tscn")
const FIELD_GENERATOR_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Defense/FieldGenerator/field_generator.tscn")

const CHICKEN_BASIC_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/ChickenLord/Chicken/Basic/chicken_basic.tscn")
const CHICKEN_ATTACK_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenAttack/chicken_attack.tscn")
const CHICKEN_POISON_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenPoison/chicken_poison.tscn")
const CHICKEN_COLOSSUS_SCENE: PackedScene = preload('res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenColossus/chicken_colossus.tscn')
const CHICKEN_LIGHT_SCENE: PackedScene = preload('res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenLight/chicken_light.tscn')
const CHICKEN_ENGINEER_SCENE: PackedScene = preload('res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenShield/chicken_shield.tscn')
const CHICKEN_ARDENT_CELESTIAL_SCENE: PackedScene = preload('res://Entities/NPC/Fighting/ChickenLord/Chicken/Gifted/ChickenArdentCelestial/chicken_ardent_celestial.tscn')

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
	
	match entity_type:
		Entity.EntityType.SNAKE_BARREL: _summon_snake_barrel(spawn_position, entity_modifier)
		Entity.EntityType.SNAKE: _summon_snake(spawn_position, entity_modifier)
		Entity.EntityType.FIELD_GENERATOR: _summon_field_generator(spawn_position, entity_modifier)
		Entity.EntityType.CHICKEN: _summon_chicken(spawn_position, entity_modifier)


# ============================== Private functions ==============================

func _summon_snake_barrel(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var snake_barrel: SnakeBarrel = SNAKE_BARREL_SCENE.instantiate()
	var snake_number: int = entity_modifier[Entity.SnakeBarrelModifier.SNAKE_NUMBER]
	var snake_poison_stacks: int = entity_modifier[Entity.SnakeBarrelModifier.SNAKE_POISON_STACKS]
	var max_health: int = entity_modifier[Entity.SnakeBarrelModifier.MAX_HEALTH]
	snake_barrel.init(snake_number, snake_poison_stacks, max_health)
	_spawn_manager.spawn_entity(snake_barrel, spawn_position, _owner.get_context(), Entity.EntityType.SNAKE_BARREL)


func _summon_snake(spawn_position: Vector3, _entity_modifier: Dictionary) -> void:
	var snake: Snake = SNAKE_SCENE.instantiate()
	_spawn_manager.spawn_entity(snake, spawn_position, _owner.get_context(), Entity.EntityType.SNAKE)


func _summon_field_generator(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var field_generator: FieldGenerator = FIELD_GENERATOR_SCENE.instantiate()
	var max_health: int = entity_modifier.get(Entity.FieldGeneratorModifier.MAX_HEALTH, 1)
	var shield_amount: int = entity_modifier.get(Entity.FieldGeneratorModifier.SHIELD_AMOUNT, 100)
	var shield_interval: float = entity_modifier.get(Entity.FieldGeneratorModifier.SHIELD_INTERVAL, 1.0)
	var initial_shield: int = entity_modifier.get(Entity.FieldGeneratorModifier.INITIAL_SHIELD, 150)
	var target_count: int = entity_modifier.get(Entity.FieldGeneratorModifier.TARGET_COUNT, 2)
	field_generator.init(max_health, shield_amount, shield_interval, initial_shield, target_count)
	_spawn_manager.spawn_entity(field_generator, spawn_position, _owner.get_context(), Entity.EntityType.FIELD_GENERATOR)


func _summon_chicken(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var chicken: Chicken
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
			
	_spawn_manager.spawn_entity(chicken, spawn_position, _owner.get_context(), Entity.EntityType.CHICKEN)
