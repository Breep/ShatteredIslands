extends Node

var HEROES: Dictionary[HeroDesc.HeroId, HeroDesc] = {
	HeroDesc.HeroId.UNDEF: load("res://Entities/Heroes/Undef/undef.tres"),
	HeroDesc.HeroId.DARK_KNIGHT: load("res://Entities/Heroes/DarkKnight/dark_knight.tres"),
}

var HERO_SCENES: Dictionary[HeroDesc.HeroId, PackedScene] = {
	HeroDesc.HeroId.UNDEF: load("res://Entities/Heroes/Undef/undef.tscn"),
	HeroDesc.HeroId.DARK_KNIGHT: load("res://Entities/Heroes/DarkKnight/dark_knight.tscn"),
}

var FAMILIES: Dictionary[Family.FamilyType, Family] = {
	Family.FamilyType.ATTACK: load("res://Card/Descriptions/Families/attack_family.tres"),
	Family.FamilyType.DEFENSE: load("res://Card/Descriptions/Families/defense_family.tres"),
	Family.FamilyType.FIRE: load("res://Card/Descriptions/Families/fire_family.tres"),
	Family.FamilyType.STORM: load("res://Card/Descriptions/Families/storm_family.tres"),
	Family.FamilyType.SERENITY: load("res://Card/Descriptions/Families/serenity_family.tres"),
	Family.FamilyType.LIFE: load("res://Card/Descriptions/Families/life_family.tres"),
	Family.FamilyType.POISON: load("res://Card/Descriptions/Families/poison_family.tres"),
	Family.FamilyType.MANA: load("res://Card/Descriptions/Families/mana_family.tres"),
	Family.FamilyType.CHICKEN: load("res://Card/Descriptions/Families/chickenlord_family.tres"),
	Family.FamilyType.LIGHTNING: load("res://Card/Descriptions/Families/lightning_family.tres"),
	Family.FamilyType.NECROSIS: load("res://Card/Descriptions/Families/necro_family.tres"),
	Family.FamilyType.SHADOW: load("res://Card/Descriptions/Families/shadow_family.tres")
}

var ENTITY_MODULE_SCENES: Dictionary[Module.ModuleType, PackedScene] = {
	Module.ModuleType.MOVEMENT: load("res://Entities/Modules/MovementModule/movement_module.tscn"),
	Module.ModuleType.ACTION: load("res://Entities/Modules/ActionModule/action_module.tscn"),
	Module.ModuleType.INTERACT: load("res://Entities/Modules/InteractModule/interact_module.tscn"),
	Module.ModuleType.AUTOATTACK: load("res://Entities/Modules/AutoAttackModule/auto_attack_module.tscn"),
	Module.ModuleType.TARGET: load("res://Entities/Modules/TargetModule/target_module.tscn"),
	Module.ModuleType.STACK_HANDLER: load("res://Entities/Modules/StackHandlerModule/stack_handler_module.tscn")
}

var FAMILY_MANAGER_SCENES: Dictionary[Family.FamilyType, PackedScene] = {
	Family.FamilyType.DEFENSE: load("res://Entities/Heroes/_Shared/FamiliesManagers/Defense/defense_manager.tscn"),
	Family.FamilyType.FIRE: load("res://Entities/Heroes/_Shared/FamiliesManagers/Fire/fire_manager.tscn"),
	Family.FamilyType.LIFE: load("res://Entities/Heroes/_Shared/FamiliesManagers/Life/life_manager.tscn"),
	Family.FamilyType.POISON: load("res://Entities/Heroes/_Shared/FamiliesManagers/Poison/poison_manager.tscn"),
	Family.FamilyType.SERENITY: load("res://Entities/Heroes/_Shared/FamiliesManagers/Serenity/serenity_manager.tscn"),
	Family.FamilyType.STORM: load("res://Entities/Heroes/_Shared/FamiliesManagers/Storm/storm_manager.tscn"),
	Family.FamilyType.ATTACK: load("res://Entities/Heroes/_Shared/FamiliesManagers/Attack/attack_manager.tscn"),
	Family.FamilyType.MANA: load("res://Entities/Heroes/_Shared/FamiliesManagers/Mana/mana_manager.tscn"),
	Family.FamilyType.NECROSIS: load("res://Entities/Heroes/_Shared/FamiliesManagers/Necro/necro_manager.tscn"),
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
