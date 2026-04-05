extends Node

var HEROES: Dictionary[HeroDesc.HeroId, HeroDesc] = {
	HeroDesc.HeroId.UNDEF: load("res://Entities/Heroes/Undef/undef.tres"),
	HeroDesc.HeroId.DARK_KNIGHT: load("res://Entities/Heroes/DarkKnight/dark_knight.tres"),
	HeroDesc.HeroId.TANK: load("res://Entities/Heroes/Tank/tank.tres"),
	HeroDesc.HeroId.ASSASSIN: load("res://Entities/Heroes/Assassin/assassin.tres"),
	HeroDesc.HeroId.MAGE: load("res://Entities/Heroes/Mage/mage.tres"),
}

var HERO_SCENES: Dictionary[HeroDesc.HeroId, PackedScene] = {
	HeroDesc.HeroId.UNDEF: load("res://Entities/Heroes/Undef/undef.tscn"),
	HeroDesc.HeroId.DARK_KNIGHT: load("res://Entities/Heroes/DarkKnight/dark_knight.tscn"),
	HeroDesc.HeroId.TANK: load("res://Entities/Heroes/Tank/tank.tscn"),
	HeroDesc.HeroId.ASSASSIN: load("res://Entities/Heroes/Assassin/assassin.tscn"),
	HeroDesc.HeroId.MAGE: load("res://Entities/Heroes/Mage/mage.tscn"),
}

var FAMILIES: Dictionary[Family.Type, Family] = {
	Family.Type.WARRIOR: load("res://Card/Descriptions/Families/warrior_family.tres"),
	Family.Type.ENGINEER: load("res://Card/Descriptions/Families/engineer_family.tres"),
	Family.Type.ARDENT_CELESTIAL: load("res://Card/Descriptions/Families/ardent_celestial_family.tres"),
	Family.Type.STORM_CALLER: load("res://Card/Descriptions/Families/storm_caller_family.tres"),
	Family.Type.LIGHT: load("res://Card/Descriptions/Families/light_family.tres"),
	Family.Type.COLOSSUS: load("res://Card/Descriptions/Families/colossus_family.tres"),
	Family.Type.POISON: load("res://Card/Descriptions/Families/poison_family.tres"),
	Family.Type.CHICKEN_LORD: load("res://Card/Descriptions/Families/chicken_lord_family.tres"),
	Family.Type.NECROSIS: load("res://Card/Descriptions/Families/necro_family.tres"),
}

var ENTITY_MODULE_SCENES: Dictionary[Module.ModuleType, PackedScene] = {
	Module.ModuleType.MOVEMENT: load("res://Entities/Modules/MovementModule/movement_module.tscn"),
	Module.ModuleType.TARGET: load("res://Entities/Modules/TargetModule/target_module.tscn"),
	Module.ModuleType.CONDITIONS: load("res://Entities/Modules/ConditionsModule/conditions_module.tscn"),
	Module.ModuleType.STATUS: load("res://Entities/Modules/StatusModule/status_module.tscn"),
	Module.ModuleType.AUTO_ATTACK_PERIODIC_MODULE: load("res://Entities/Modules/AutoAttackPeriodicModule/auto_attack_periodic_module.tscn"),
	
	Module.ModuleType.ACTION_SENDER_DAMAGE: load("res://Entities/Modules/ActionSenderModule/Damage/action_sender_damage_module.tscn"),
	Module.ModuleType.ACTION_SENDER_HEAL: load("res://Entities/Modules/ActionSenderModule/Heal/action_sender_heal_module.tscn"),
	Module.ModuleType.ACTION_SENDER_ADD_STACK: load("res://Entities/Modules/ActionSenderModule/AddStack/action_sender_add_stack_module.tscn"),
	Module.ModuleType.ACTION_SENDER_REMOVE_STACK: load("res://Entities/Modules/ActionSenderModule/RemoveStack/action_sender_remove_stack_module.tscn"),
	Module.ModuleType.ACTION_SENDER_PROJECTILE: load("res://Entities/Modules/ActionSenderModule/Projectile/action_sender_projectile_module.tscn"),
	Module.ModuleType.ACTION_SENDER_SPELL: load("res://Entities/Modules/ActionSenderModule/Spell/action_sender_spell_module.tscn"),
	Module.ModuleType.ACTION_SENDER_SUMMON: load("res://Entities/Modules/ActionSenderModule/Summon/action_sender_summon_module.tscn"),
	Module.ModuleType.ACTION_SENDER_AUTO_ATTACK: load("res://Entities/Modules/ActionSenderModule/AutoAttack/action_sender_auto_attack_module.tscn"),
	Module.ModuleType.ACTION_SENDER_STATUS: load("res://Entities/Modules/ActionSenderModule/Status/action_sender_status_module.tscn"),
	
	Module.ModuleType.ACTION_RECEIVER_DAMAGE: load("res://Entities/Modules/ActionReceiverModule/Damage/action_receiver_damage_module.tscn"),
	Module.ModuleType.ACTION_RECEIVER_HEAL: load("res://Entities/Modules/ActionReceiverModule/Heal/action_receiver_heal_module.tscn"),
	Module.ModuleType.ACTION_RECEIVER_ADD_STACK: load("res://Entities/Modules/ActionReceiverModule/AddStack/action_receiver_add_stack_module.tscn"),
	Module.ModuleType.ACTION_RECEIVER_REMOVE_STACK: load("res://Entities/Modules/ActionReceiverModule/RemoveStack/action_receiver_remove_stack_module.tscn"),
	Module.ModuleType.ACTION_RECEIVER_STATUS: load("res://Entities/Modules/ActionReceiverModule/Status/action_receiver_status_module.tscn"),
	
	Module.ModuleType.LABEL_POPUP_MODULE: load("res://Entities/Modules/PopupModule/label_popup_module.tscn")
}

var FAMILY_MANAGER_SCENES: Dictionary[Family.Type, PackedScene] = {
	Family.Type.ENGINEER: load("res://Entities/Heroes/_Shared/FamiliesManagers/Engineer/engineer_manager.tscn"),
	Family.Type.ARDENT_CELESTIAL: load("res://Entities/Heroes/_Shared/FamiliesManagers/ArdentCelestial/ardent_celestial_manager.tscn"),
	Family.Type.COLOSSUS: load("res://Entities/Heroes/_Shared/FamiliesManagers/Colossus/colossus_manager.tscn"),
	Family.Type.POISON: load("res://Entities/Heroes/_Shared/FamiliesManagers/Poison/poison_manager.tscn"),
	Family.Type.LIGHT: load("res://Entities/Heroes/_Shared/FamiliesManagers/Light/light_manager.tscn"),
	Family.Type.STORM_CALLER: load("res://Entities/Heroes/_Shared/FamiliesManagers/StormCaller/storm_caller_manager.tscn"),
	Family.Type.WARRIOR: load("res://Entities/Heroes/_Shared/FamiliesManagers/Warrior/warrior_manager.tscn"),
	Family.Type.NECROSIS: load("res://Entities/Heroes/_Shared/FamiliesManagers/Necro/necro_manager.tscn"),
	Family.Type.CHICKEN_LORD: load("res://Entities/Heroes/_Shared/FamiliesManagers/ChickenLord/chicken_lord_manager.tscn"),
}

var PROJECTILE_SCENES: Dictionary[Projectile.Type, PackedScene] = {
	Projectile.Type.SHADOW_BOLT: load("res://SpellsAndProjectiles/Projectiles/ShadowBolt/shadow_bolt_projectile.tscn"),
	Projectile.Type.VENOMOUS_DART: load("res://SpellsAndProjectiles/Projectiles/Poison/VenomousDart/venomous_dart_projectile.tscn"),
	Projectile.Type.SNAKE: load("res://SpellsAndProjectiles/Projectiles/Poison/Snake/snake_projectile.tscn"),
	Projectile.Type.COSMIC_BOLT: load("res://SpellsAndProjectiles/Projectiles/CosmicBolt/cosmic_bolt_projectile.tscn"),
	Projectile.Type.SHIELD_THROW: load("res://SpellsAndProjectiles/Projectiles/ShieldThrow/shield_throw_projectile.tscn"),
	Projectile.Type.POISON_FLASK: load("res://SpellsAndProjectiles/Projectiles/Poison/PoisonFlask/poison_flask_projectile.tscn"),
	Projectile.Type.SMALL_EGG: load("res://SpellsAndProjectiles/Projectiles/SmallEgg/small_egg_projectile.tscn"),
	Projectile.Type.FIRE_BALL: load("res://SpellsAndProjectiles/Projectiles/FireBall/fire_ball_projectile.tscn"),
	Projectile.Type.BULLET: load("res://SpellsAndProjectiles/Projectiles/Bullet/bullet_projectile.tscn")
}

var DAMAGE_POPUP_SCENE: PackedScene = load("res://UI/3D/DamagePopup/damage_popup.tscn")

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
