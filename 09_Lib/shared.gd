extends Node

# Pools de ressources chargés paresseusement : chaque dictionnaire / scène ne se
# charge qu'au 1er accès, puis est mis en cache. Évite de tout charger (héros,
# familles+cartes, family managers, projectiles VFX) au démarrage de chaque
# scène — y compris les scènes de test qui n'en ont pas besoin.

var _heroes_cache: Dictionary[HeroDesc.HeroId, EntityDesc] = {}
var HEROES: Dictionary[HeroDesc.HeroId, EntityDesc]:
	get:
		if _heroes_cache.is_empty():
			_heroes_cache = {
				HeroDesc.HeroId.DARK_KNIGHT: load("res://02_Entities/Pool/Heroes/DarkKnight/dark_knight.tres"),
				HeroDesc.HeroId.LATIKA: load("res://02_Entities/Pool/Heroes/Latika/latika_desc.tres"),
			}
		return _heroes_cache

var _hero_scenes_cache: Dictionary[HeroDesc.HeroId, PackedScene] = {}
var HERO_SCENES: Dictionary[HeroDesc.HeroId, PackedScene]:
	get:
		if _hero_scenes_cache.is_empty():
			_hero_scenes_cache = {
				HeroDesc.HeroId.DARK_KNIGHT: load("res://02_Entities/Pool/Heroes/DarkKnight/dark_knight.tscn"),
				HeroDesc.HeroId.LATIKA: load("res://02_Entities/Pool/Heroes/Latika/latika.tscn"),
			}
		return _hero_scenes_cache

var _families_cache: Dictionary[Family.Type, Family] = {}
var FAMILIES: Dictionary[Family.Type, Family]:
	get:
		if _families_cache.is_empty():
			_families_cache = {
				Family.Type.WARRIOR: load("res://01_Cards/Pool/Families/warrior_family.tres"),
				Family.Type.ENGINEER: load("res://01_Cards/Pool/Families/Engineer/engineer_family.tres"),
				Family.Type.ARDENT_CELESTIAL: load("res://01_Cards/Pool/Families/ArdentCelestial/ardent_celestial_family.tres"),
				Family.Type.STORM_CALLER: load("res://01_Cards/Pool/Families/storm_caller_family.tres"),
				Family.Type.LIGHT: load("res://01_Cards/Pool/Families/light_family.tres"),
				Family.Type.COLOSSUS: load("res://01_Cards/Pool/Families/Colossus/colossus_family.tres"),
				Family.Type.POISON: load("res://01_Cards/Pool/Families/poison_family.tres"),
				Family.Type.CHICKEN_LORD: load("res://01_Cards/Pool/Families/ChickenLord/chicken_lord_family.tres"),
				Family.Type.NECROSIS: load("res://01_Cards/Pool/Families/necro_family.tres"),
			}
		return _families_cache

var _family_manager_scenes_cache: Dictionary[Family.Type, PackedScene] = {}
var FAMILY_MANAGER_SCENES: Dictionary[Family.Type, PackedScene]:
	get:
		if _family_manager_scenes_cache.is_empty():
			_family_manager_scenes_cache = {
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
		return _family_manager_scenes_cache

var _projectile_scenes_cache: Dictionary[Projectile.Type, PackedScene] = {}
var PROJECTILE_SCENES: Dictionary[Projectile.Type, PackedScene]:
	get:
		if _projectile_scenes_cache.is_empty():
			_projectile_scenes_cache = {
				Projectile.Type.SHADOW_BOLT: load("res://03_SpellsAndProjectiles/Projectiles/AutoAttacks/ShadowBolt/shadow_bolt_projectile.tscn"),
				Projectile.Type.VENOMOUS_DART: load("res://03_SpellsAndProjectiles/Projectiles/Abilities/Small/VenomousDart/venomous_dart_projectile.tscn"),
				Projectile.Type.COSMIC_BOLT: load("res://03_SpellsAndProjectiles/Projectiles/Abilities/Small/CosmicBolt/cosmic_bolt_projectile.tscn"),
				Projectile.Type.SHIELD_THROW: load("res://03_SpellsAndProjectiles/Projectiles/Abilities/Small/ShieldThrow/shield_throw_projectile.tscn"),
				Projectile.Type.POISON_FLASK: load("res://03_SpellsAndProjectiles/Projectiles/Abilities/Small/PoisonFlask/poison_flask_projectile.tscn"),
				Projectile.Type.SMALL_EGG: load("res://03_SpellsAndProjectiles/Projectiles/Abilities/Small/SmallEgg/small_egg_projectile.tscn"),
				Projectile.Type.FIRE_BALL: load("res://03_SpellsAndProjectiles/Projectiles/Abilities/Small/FireBall/fire_ball_projectile.tscn"),
				Projectile.Type.BULLET: load("res://03_SpellsAndProjectiles/Projectiles/AutoAttacks/Bullet/bullet_projectile.tscn"),
				Projectile.Type.GAMMA_TURRET: load("res://03_SpellsAndProjectiles/Projectiles/AutoAttacks/GammaTurret/gamma_turret_projectile.tscn"),
				Projectile.Type.ARROW: load("res://03_SpellsAndProjectiles/Projectiles/AutoAttacks/Arrow/arrow_projectile.tscn"),
				Projectile.Type.GRENADE: load("res://03_SpellsAndProjectiles/Projectiles/Abilities/Grenade/grenade.tscn"),
				Projectile.Type.BOULDER: load("res://03_SpellsAndProjectiles/Projectiles/Abilities/Big/Boulder/boulder.tscn"),
				Projectile.Type.NIGHTFALL: load("res://03_SpellsAndProjectiles/Projectiles/Abilities/Nightfall/nightfall.tscn"),
			}
		return _projectile_scenes_cache


# Résout la Size d'un Projectile.Type. La taille n'est portée que par la scène
# (Projectile.size) : on instancie une fois la scène hors de l'arbre (donc sans
# déclencher _ready) pour lire la valeur, puis on cache le résultat.
var _projectile_sizes_cache: Dictionary[Projectile.Type, Projectile.Size] = {}
func get_projectile_size(type: Projectile.Type) -> Projectile.Size:
	if not _projectile_sizes_cache.has(type):
		var instance := PROJECTILE_SCENES[type].instantiate() as Projectile
		_projectile_sizes_cache[type] = instance.size
		instance.free()
	return _projectile_sizes_cache[type]

var _damage_popup_scene_cache: PackedScene
var DAMAGE_POPUP_SCENE: PackedScene:
	get:
		if _damage_popup_scene_cache == null:
			_damage_popup_scene_cache = load("res://04_UI/3D/DamagePopup/damage_popup.tscn")
		return _damage_popup_scene_cache

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
