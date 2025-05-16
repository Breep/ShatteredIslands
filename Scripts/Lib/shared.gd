extends Node

var HEROES: Dictionary[Hero.HeroId, Hero] = {
	Hero.HeroId.ANCIENT_TREE: load("res://Resources/Heroes/ancient_tree.tres"),
	Hero.HeroId.CYBORG: load("res://Resources/Heroes/cyborg.tres"),
	Hero.HeroId.DR_BOOM: load("res://Resources/Heroes/dr_boom.tres"),
	Hero.HeroId.LAURENT_KROFT: load("res://Resources/Heroes/laurent_kroft.tres"),
	Hero.HeroId.MR_KRUMB: load("res://Resources/Heroes/mr_krumb.tres"),
	Hero.HeroId.SIR_REGINALD: load("res://Resources/Heroes/sir_reginald.tres"),
	Hero.HeroId.TONY_LE_BARDE: load("res://Resources/Heroes/tony_le_barde.tres")
}

var CHARACTERS: Dictionary[Hero.HeroId, PackedScene] = {
	Hero.HeroId.ANCIENT_TREE: load("res://Scenes/Entities/Heroes/AncientTree/ancient_tree.tscn"),
	Hero.HeroId.CYBORG: load("res://Scenes/Entities/Heroes/Cyborg/cyborg.tscn"),
	Hero.HeroId.DR_BOOM: load("res://Scenes/Entities/Heroes/DrBoom/dr_boom.tscn"),
	Hero.HeroId.LAURENT_KROFT: load("res://Scenes/Entities/Heroes/LaurentKroft/laurent_kroft.tscn"),
	Hero.HeroId.MR_KRUMB: load("res://Scenes/Entities/Heroes/MrKrumb/mr_krumb.tscn"),
	Hero.HeroId.SIR_REGINALD: load("res://Scenes/Entities/Heroes/SirReginald/sir_reginald.tscn"),
	Hero.HeroId.TONY_LE_BARDE: load("res://Scenes/Entities/Heroes/TonyLeBarde/tony_le_barde.tscn")
}


var MAPS: Dictionary[Battle.BattleType, PackedScene] = {
	Battle.BattleType.VS_1: load("res://Scenes/FightingArea/Maps/map_flat_test.tscn"),
	Battle.BattleType.VS_2: load("res://Scenes/FightingArea/Maps/map_flat_test.tscn"),
	Battle.BattleType.FFA_SOLO_3: load("res://Scenes/FightingArea/Maps/map_telescope_island.tscn")
}


var fighting_areas_ref: Dictionary[int, FightingArea] # Key=battle_id
var spawn_managers_ref: Dictionary[int, SpawnManager] # Key=battle_id
var entity_managers_ref: Dictionary[int, EntityManager] # Key=battle_id
var fighting_managers_ref: Dictionary[int, FightingManager] # Key=battle_id



















 
