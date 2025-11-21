extends Node

var HEROES: Dictionary[Hero.HeroId, Hero] = {
	Hero.HeroId.UNDEF: load("res://Entities/Heroes/Undef/undef.tres"),
	Hero.HeroId.DARK_KNIGHT: load("res://Entities/Heroes/DarkKnight/dark_knight.tres"),
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

var DAMAGE_POPUP_SCENE: PackedScene = load("res://UI/3D/DamagePopup/damage_popup.tscn")

var scene_switcher: SceneSwitcher

const LAYER_WALLS: int = 1 << 0
const LAYER_PROJECTILES: int = 1 << 1
const LAYER_SPAWN_AREAS: int = 1 << 2
const LAYER_FLOOR: int = 1 << 3
const LAYER_ENTITIES: int = 1 << 4
const LAYER_PICKABLE_CONSTRAINT: int = 1 << 5
const LAYER_FURNITURE: int = 1 << 6







 
