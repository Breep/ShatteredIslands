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

var DAMAGE_POPUP_SCENE: PackedScene = load("res://UI/3D/DamagePopup/damage_popup.tscn")

















 
