extends Node

var HEROES: Dictionary[Hero.HeroId, Hero] = {
	Hero.HeroId.UNDEF: load("res://Entities/Heroes/_Undef/undef.tres"),
	Hero.HeroId.ANCIENT_TREE: load("res://Entities/Heroes/AncientTree/ancient_tree.tres"),
	Hero.HeroId.CYBORG: load("res://Entities/Heroes/Cyborg/cyborg.tres"),
	Hero.HeroId.DR_BOOM: load("res://Entities/Heroes/DrBoom/dr_boom.tres"),
	Hero.HeroId.LAURENT_KROFT: load("res://Entities/Heroes/LaurentKroft/laurent_kroft.tres"),
	Hero.HeroId.MR_KRUMB: load("res://Entities/Heroes/MrKrumb/mr_krumb.tres"),
	Hero.HeroId.SIR_REGINALD: load("res://Entities/Heroes/SirReginald/sir_reginald.tres"),
	Hero.HeroId.TONY_LE_BARDE: load("res://Entities/Heroes/TonyLeBarde/tony_le_barde.tres"),
	Hero.HeroId.RHINO: load("res://Entities/Heroes/Rhino/rhino.tres"),
	Hero.HeroId.DARK_KNIGHT: load("res://Entities/Heroes/DarkKnight/dark_knight.tres"),
	Hero.HeroId.ROCKY: load("res://Entities/Heroes/Rocky/rocky.tres")
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














 
