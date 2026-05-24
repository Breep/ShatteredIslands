extends Node

var HEROES: Dictionary[HeroDesc.HeroId, HeroDesc] = {
	HeroDesc.HeroId.DARK_KNIGHT: load("res://02_Entities/Pool/Heroes/DarkKnight/dark_knight.tres"),
	HeroDesc.HeroId.LATIKA: load("res://02_Entities/Pool/Heroes/Latika/latika.tres"),
}

var HERO_SCENES: Dictionary[HeroDesc.HeroId, PackedScene] = {
	HeroDesc.HeroId.DARK_KNIGHT: load("res://02_Entities/Pool/Heroes/DarkKnight/dark_knight.tscn"),
	HeroDesc.HeroId.LATIKA: load("res://02_Entities/Pool/Heroes/Latika/latika.tscn")
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

var FAMILY_MANAGER_SCENES: Dictionary[Family.Type, PackedScene] = {
	Family.Type.ENGINEER: load("res://02_Entities/_Shared/FamiliesManagers/Engineer/engineer_manager.tscn"),
	Family.Type.ARDENT_CELESTIAL: load("res://02_Entities/_Shared/FamiliesManagers/ArdentCelestial/ardent_celestial_manager.tscn"),
	Family.Type.COLOSSUS: load("res://02_Entities/_Shared/FamiliesManagers/Colossus/colossus_manager.tscn"),
	Family.Type.POISON: load("res://02_Entities/_Shared/FamiliesManagers/Poison/poison_manager.tscn"),
	Family.Type.LIGHT: load("res://02_Entities/_Shared/FamiliesManagers/Light/light_manager.tscn"),
	Family.Type.STORM_CALLER: load("res://02_Entities/_Shared/FamiliesManagers/StormCaller/storm_caller_manager.tscn"),
	Family.Type.WARRIOR: load("res://02_Entities/_Shared/FamiliesManagers/Warrior/warrior_manager.tscn"),
	Family.Type.NECROSIS: load("res://02_Entities/_Shared/FamiliesManagers/Necro/necro_manager.tscn"),
	Family.Type.CHICKEN_LORD: load("res://02_Entities/_Shared/FamiliesManagers/ChickenLord/chicken_lord_manager.tscn"),
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
