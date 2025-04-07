extends Node

var HEROES: Dictionary[Hero.HeroId, Hero] = {
	Hero.HeroId.ANCIENT_TREE: load("res://Resources/Heroes/ancient_tree.tres"),
	Hero.HeroId.CYBORG: load("res://Resources/Heroes/cyborg.tres"),
	Hero.HeroId.DR_BOOM: load("res://Resources/Heroes/dr_boom.tres"),
	Hero.HeroId.ENERGY_MAN: load("res://Resources/Heroes/energy_man.tres"),
	Hero.HeroId.LAURENT_KROFT: load("res://Resources/Heroes/laurent_kroft.tres"),
	Hero.HeroId.MR_KRUMB: load("res://Resources/Heroes/mr_krumb.tres"),
	Hero.HeroId.SIR_REGINALD: load("res://Resources/Heroes/sir_reginald.tres"),
	Hero.HeroId.TONY_LE_BARDE: load("res://Resources/Heroes/tony_le_barde.tres")
}

var fighting_areas_ref: Dictionary[int, FightingArea] # Key=battle_id
var spawn_managers_ref: Dictionary[int, SpawnManager] # Key=battle_id
var entity_managers_ref: Dictionary[int, EntityManager] # Key=battle_id
var fighting_managers_ref: Dictionary[int, FightingManager] # Key=battle_id



















 
