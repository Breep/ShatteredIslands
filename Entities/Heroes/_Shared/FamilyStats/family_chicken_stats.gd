class_name FamilyChickenLordStats
extends FamilyStats

enum CbVars {
	SELF_CHICKEN,
	ALIVE_CHICKENS,
}

var on_chicken_spawned_callbacks: Array[Callable]
var on_chicken_death_callbacks: Array[Callable]

var spawn_period_decrease: float
var gifted_chance_increase: float
var spawn_number_increase: int

var twins_chance: float
var dodge_inherited: float
