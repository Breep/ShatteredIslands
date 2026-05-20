extends Node

var HEROES: Dictionary[HeroDesc.HeroId, HeroDesc] = {
	HeroDesc.HeroId.UNDEF: load("res://02_Entities/Heroes/Undef/undef.tres"),
	HeroDesc.HeroId.DARK_KNIGHT: load("res://02_Entities/Heroes/DarkKnight/dark_knight.tres"),
	HeroDesc.HeroId.TANK: load("res://02_Entities/Heroes/Tank/tank.tres"),
	HeroDesc.HeroId.ASSASSIN: load("res://02_Entities/Heroes/Assassin/assassin.tres"),
	HeroDesc.HeroId.MAGE: load("res://02_Entities/Heroes/Mage/mage.tres"),
}

var HERO_SCENES: Dictionary[HeroDesc.HeroId, PackedScene] = {
	HeroDesc.HeroId.UNDEF: load("res://02_Entities/Heroes/Undef/undef.tscn"),
	HeroDesc.HeroId.DARK_KNIGHT: load("res://02_Entities/Heroes/DarkKnight/dark_knight.tscn"),
	HeroDesc.HeroId.TANK: load("res://02_Entities/Heroes/Tank/tank.tscn"),
	HeroDesc.HeroId.ASSASSIN: load("res://02_Entities/Heroes/Assassin/assassin.tscn"),
	HeroDesc.HeroId.MAGE: load("res://02_Entities/Heroes/Mage/mage.tscn"),
	HeroDesc.HeroId.LATIKA: load("res://02_Entities/Heroes/Latika/latika.tscn")
}

var FAMILIES: Dictionary[Family.Type, Family] = {
	Family.Type.WARRIOR: load("res://01_Cards/Descriptions/Families/warrior_family.tres"),
	Family.Type.ENGINEER: load("res://01_Cards/Descriptions/Families/Engineer/engineer_family.tres"),
	Family.Type.ARDENT_CELESTIAL: load("res://01_Cards/Descriptions/Families/ArdentCelestial/ardent_celestial_family.tres"),
	Family.Type.STORM_CALLER: load("res://01_Cards/Descriptions/Families/storm_caller_family.tres"),
	Family.Type.LIGHT: load("res://01_Cards/Descriptions/Families/light_family.tres"),
	Family.Type.COLOSSUS: load("res://01_Cards/Descriptions/Families/Colossus/colossus_family.tres"),
	Family.Type.POISON: load("res://01_Cards/Descriptions/Families/poison_family.tres"),
	Family.Type.CHICKEN_LORD: load("res://01_Cards/Descriptions/Families/ChickenLord/chicken_lord_family.tres"),
	Family.Type.NECROSIS: load("res://01_Cards/Descriptions/Families/necro_family.tres"),
}

var ENTITY_COMPONENT_SCENES: Dictionary[EntityComponent.Type, PackedScene] = {
	EntityComponent.Type.MOVEMENT: load("res://02_Entities/_Shared/Components/Movement/movement_component.tscn"),
	EntityComponent.Type.TARGET: load("res://02_Entities/_Shared/Components/Target/target_component.tscn"),
	EntityComponent.Type.ALTERATIONS: load("res://02_Entities/_Shared/Components/Alterations/alterations_component.tscn"),
	EntityComponent.Type.DAMAGE: load("res://02_Entities/_Shared/Components/Damage/damage_component.tscn"),
	EntityComponent.Type.HEAL: load("res://02_Entities/_Shared/Components/Heal/heal_component.tscn"),
	EntityComponent.Type.PROJECTILE: load("res://02_Entities/_Shared/Components/Projectile/projectile_component.tscn"),
	EntityComponent.Type.SPELL: load("res://02_Entities/_Shared/Components/Spell/spell_component.tscn"),
	EntityComponent.Type.SUMMON: load("res://02_Entities/_Shared/Components/Summon/summon_component.tscn"),
	EntityComponent.Type.AUTO_ATTACK: load("res://02_Entities/_Shared/Components/AutoAttack/auto_attack_component.tscn"),

	EntityComponent.Type.AUTO_ATTACK_PERIODIC_MODULE: load("res://02_Entities/_Shared/Components/AutoAttackPeriodicModule/auto_attack_periodic_module.tscn"),
	EntityComponent.Type.LABEL_POPUP_MODULE: load("res://02_Entities/_Shared/Components/PopupModule/label_popup_module.tscn"),
	
	EntityComponent.Type.ANIMATION: load("res://02_Entities/_Shared/Components/Animation/animation_component.tscn"),
	EntityComponent.Type.SPAWN_ANIMATION: load("res://02_Entities/_Shared/Components/SpawnAnimation/spawn_animation_component.tscn"),
	EntityComponent.Type.CLICKABLE: load("res://02_Entities/_Shared/Components/Clickable/clickable_component.tscn"),
	EntityComponent.Type.DESPAWN: load("res://02_Entities/_Shared/Components/Despawn/despawn_module.tscn"),
	EntityComponent.Type.DISPLAY_MODE: load("res://02_Entities/_Shared/Components/DisplayMode/display_mode_module.tscn"),
}

var FAMILY_MANAGER_SCENES: Dictionary[Family.Type, PackedScene] = {
	Family.Type.ENGINEER: load("res://02_Entities/Heroes/_Shared/FamiliesManagers/Engineer/engineer_manager.tscn"),
	Family.Type.ARDENT_CELESTIAL: load("res://02_Entities/Heroes/_Shared/FamiliesManagers/ArdentCelestial/ardent_celestial_manager.tscn"),
	Family.Type.COLOSSUS: load("res://02_Entities/Heroes/_Shared/FamiliesManagers/Colossus/colossus_manager.tscn"),
	Family.Type.POISON: load("res://02_Entities/Heroes/_Shared/FamiliesManagers/Poison/poison_manager.tscn"),
	Family.Type.LIGHT: load("res://02_Entities/Heroes/_Shared/FamiliesManagers/Light/light_manager.tscn"),
	Family.Type.STORM_CALLER: load("res://02_Entities/Heroes/_Shared/FamiliesManagers/StormCaller/storm_caller_manager.tscn"),
	Family.Type.WARRIOR: load("res://02_Entities/Heroes/_Shared/FamiliesManagers/Warrior/warrior_manager.tscn"),
	Family.Type.NECROSIS: load("res://02_Entities/Heroes/_Shared/FamiliesManagers/Necro/necro_manager.tscn"),
	Family.Type.CHICKEN_LORD: load("res://02_Entities/Heroes/_Shared/FamiliesManagers/ChickenLord/chicken_lord_manager.tscn"),
}

var PROJECTILE_SCENES: Dictionary[Projectile.Type, PackedScene] = {
	Projectile.Type.SHADOW_BOLT: load("res://03_SpellsAndProjectiles/Projectiles/ShadowBolt/shadow_bolt_projectile.tscn"),
	Projectile.Type.VENOMOUS_DART: load("res://03_SpellsAndProjectiles/Projectiles/Poison/VenomousDart/venomous_dart_projectile.tscn"),
	Projectile.Type.SNAKE: load("res://03_SpellsAndProjectiles/Projectiles/Poison/Snake/snake_projectile.tscn"),
	Projectile.Type.COSMIC_BOLT: load("res://03_SpellsAndProjectiles/Projectiles/CosmicBolt/cosmic_bolt_projectile.tscn"),
	Projectile.Type.SHIELD_THROW: load("res://03_SpellsAndProjectiles/Projectiles/ShieldThrow/shield_throw_projectile.tscn"),
	Projectile.Type.POISON_FLASK: load("res://03_SpellsAndProjectiles/Projectiles/Poison/PoisonFlask/poison_flask_projectile.tscn"),
	Projectile.Type.SMALL_EGG: load("res://03_SpellsAndProjectiles/Projectiles/SmallEgg/small_egg_projectile.tscn"),
	Projectile.Type.FIRE_BALL: load("res://03_SpellsAndProjectiles/Projectiles/FireBall/fire_ball_projectile.tscn"),
	Projectile.Type.BULLET: load("res://03_SpellsAndProjectiles/Projectiles/Bullet/bullet_projectile.tscn"),
	Projectile.Type.GAMMA_TURRET: load("res://03_SpellsAndProjectiles/Projectiles/GammaTurret/gamma_turret_projectile.tscn"),
	Projectile.Type.ARROW: load("res://03_SpellsAndProjectiles/Projectiles/Arrow/arrow_projectile.tscn")
}

var DAMAGE_POPUP_SCENE: PackedScene = load("res://04_UI/3D/DamagePopup/damage_popup.tscn")

var scene_switcher: SceneSwitcher

const LAYER_WALLS: int = 1 << 0
const LAYER_PROJECTILES: int = 1 << 1
const LAYER_SPAWN_AREAS: int = 1 << 2
const LAYER_FLOOR: int = 1 << 3
const LAYER_ENTITIES: int = 1 << 4
const LAYER_PICKABLE_CONSTRAINT: int = 1 << 5
const LAYER_FURNITURE: int = 1 << 6

func _init() -> void:
	Verbose.debug("SHARED INIT", Verbose.Category.DEFAULT)
