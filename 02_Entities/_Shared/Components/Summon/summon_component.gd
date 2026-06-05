class_name SummonComponent
extends EntityComponent

var _spawn_manager: SpawnManager
var _arena_zone_manager: ArenaZoneManager

const SNAKE_BARREL_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/SnakeBarrel/snake_barrel.tscn")
const SNAKE_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/Snake/snake.tscn")

const CHICKEN_BASIC_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/Chickens/Basic/chicken_basic.tscn")
const CHICKEN_ATTACK_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/Chickens/Gifted//ChickenAttack/chicken_attack.tscn")
const CHICKEN_POISON_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/Chickens/Gifted//ChickenPoison/chicken_poison.tscn")
const CHICKEN_COLOSSUS_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/Chickens/Gifted//ChickenColossus/chicken_colossus.tscn")
const CHICKEN_LIGHT_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/Chickens/Gifted//ChickenLight/chicken_light.tscn")
const CHICKEN_ENGINEER_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/Chickens/Gifted//ChickenEngineer/chicken_engineer.tscn")
const CHICKEN_ARDENT_CELESTIAL_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/Chickens/Gifted/ChickenArdentCelestial/chicken_ardent_celestial.tscn")
const CHICKEN_STORM_CALLER: PackedScene = preload("res://02_Entities/Pool/Mobs/Chickens/Gifted//ChickenStormCaller/chicken_storm_caller.tscn")

const PROTO_SHIELD_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/ProtoShield/proto_shield.tscn")
const FORTIFICATION_DRONE_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/FortificationDrone/fortification_drone.tscn")
const AEGIS_BLADE_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/AegisBlade/aegis_blade.tscn")
const DEFLECTION_SHIELD: PackedScene = preload("res://02_Entities/Pool/Mobs/DeflectionShield/deflection_shield.tscn")

const TREX_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/TRex/trex.tscn")
const CHICKEN_EGG_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/ChickenEgg/chicken_egg.tscn")
const MOLTEN_GOLEM_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/Golems/MoltenGolem/molten_golem.tscn")

func _enter_tree() -> void:
	if _owner == null: return
	if _owner.summon != null and _owner.summon != self:
		Verbose.trace("Override: SummonComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.summon.queue_free()
	_owner.summon = self


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.summon != self:
		return

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
	if _owner.alterations.has_timed(Alteration.Type.STUN):
		return

	if _owner.alterations.has_timed(Alteration.Type.SILENCE):
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
		Entity.EntityType.CHICKEN: _summon_chicken(spawn_position, entity_modifier)
		Entity.EntityType.PROTO_SHIELD: _summon_proto_shield(spawn_position, entity_modifier)
		Entity.EntityType.FORTIFICATION_DRONE: _summon_fortification_drone(spawn_position, entity_modifier)
		Entity.EntityType.AEGIS_BLADE: _summon_aegis_blade(spawn_position, entity_modifier)
		Entity.EntityType.DEFLECTION_SHIELD: _summon_deflection_shield(spawn_position, entity_modifier)
		Entity.EntityType.TREX: _summon_trex(spawn_position, entity_modifier)
		Entity.EntityType.CHICKEN_EGG: _summon_chicken_egg(spawn_position, entity_modifier)
		Entity.EntityType.MOLTEN_GOLEM: _summon_molten_golem(spawn_position, entity_modifier)

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
	_spawn_manager.spawn_entity(snake_barrel, Transform3D(Basis(), spawn_position), _owner.get_context(), Entity.EntityType.SNAKE_BARREL)


func _summon_snake(spawn_position: Vector3, _entity_modifier: Dictionary) -> void:
	var snake: Snake = SNAKE_SCENE.instantiate()
	_spawn_manager.spawn_entity(snake, Transform3D(Basis(), spawn_position), _owner.get_context(), Entity.EntityType.SNAKE)


func _summon_molten_golem(spawn_position: Vector3, _entity_modifier: Dictionary) -> void:
	var golem: MoltenGolem = MOLTEN_GOLEM_SCENE.instantiate()
	_spawn_manager.spawn_entity(golem, Transform3D(Basis(), spawn_position), _owner.get_context(), Entity.EntityType.MOLTEN_GOLEM)


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
	_spawn_manager.spawn_entity(chicken, Transform3D(Basis(), spawn_position), _owner.get_context(), Entity.EntityType.CHICKEN)


func _summon_proto_shield(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var proto_shield: ProtoShield = PROTO_SHIELD_SCENE.instantiate()
	var shield_amount: float = entity_modifier.get(ProtoShield.Modifier.SHIELD, 0)
	var hp_max: int = entity_modifier.get(ProtoShield.Modifier.HP_MAX, 1)
	proto_shield.init(shield_amount, hp_max)
	_spawn_manager.spawn_entity(proto_shield, Transform3D(Basis(), spawn_position), _owner.get_context())


func _summon_fortification_drone(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var fortification_drone: FortificationDrone = FORTIFICATION_DRONE_SCENE.instantiate()
	var shield_amount: float = entity_modifier.get(FortificationDrone.Modifier.SHIELD, 0)
	var hp_max: int = entity_modifier.get(FortificationDrone.Modifier.HP_MAX, 1)
	var shield_per_second: float = entity_modifier.get(FortificationDrone.Modifier.SHIELD_PER_SECOND, 1)
	var respawn_timer: float = entity_modifier.get(FortificationDrone.Modifier.RESPAWN_TIMER, 10.0)
	fortification_drone.init(shield_amount, hp_max, shield_per_second, respawn_timer)
	_spawn_manager.spawn_entity(fortification_drone, Transform3D(Basis(), spawn_position), _owner.get_context())


func _summon_aegis_blade(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var aegis_blade: AegisBlade = AEGIS_BLADE_SCENE.instantiate()
	var attack_damage: float = entity_modifier.get(AegisBlade.Modifier.AD, 0)
	var attack_speed: float = entity_modifier.get(AegisBlade.Modifier.AS, 1)
	var shield_ad_max: float = entity_modifier.get(AegisBlade.Modifier.SHIELD_AD_MAX, 0)
	var shield_ad_tau: float = entity_modifier.get(AegisBlade.Modifier.SHIELD_AD_TAU, 1)
	var damage_as_shield_ratio: float = entity_modifier.get(AegisBlade.Modifier.DAMAGE_AS_SHIELD, 0)
	aegis_blade.init(attack_damage, attack_speed, shield_ad_max, shield_ad_tau, damage_as_shield_ratio)
	_spawn_manager.spawn_entity(aegis_blade, Transform3D(Basis(), spawn_position), _owner.get_context())


func _summon_trex(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var trex: TRex = TREX_SCENE.instantiate()
	var gifted_spawn_period: float = entity_modifier.get(TRex.Modifier.PRIMAL_SHAKE_PERIOD, 0)
	var gifted_spawn_number: int = entity_modifier.get(TRex.Modifier.PRIMAL_SHAKE_NUMBER, 0)
	var hp_bonus: float = entity_modifier.get(TRex.Modifier.HP_BONUS, 0)
	trex.init(gifted_spawn_period, gifted_spawn_number, hp_bonus)
	_spawn_manager.spawn_entity(trex, Transform3D(Basis(), spawn_position), _owner.get_context())

 
func _summon_chicken_egg(_spawn_position: Vector3, _entity_modifier: Dictionary) -> void:
	pass


func _summon_deflection_shield(spawn_position: Vector3, entity_modifier: Dictionary) -> void:
	var deflection_shield: DeflectionShield = DEFLECTION_SHIELD.instantiate()
	var blocked_projectiles: int = entity_modifier.get(DeflectionShield.Modifier.BLOCKED_PROJECTILES, 1)
	var shield_per_block: float = entity_modifier.get(DeflectionShield.Modifier.SHIELD_PER_BLOCK, 10)
	var respawn_timer: float = entity_modifier.get(DeflectionShield.Modifier.RESPAWN_TIMER, -1.0)
	deflection_shield.init(blocked_projectiles, shield_per_block, respawn_timer)
	_spawn_manager.spawn_entity(deflection_shield, Transform3D(Basis(), spawn_position), _owner.get_context())
