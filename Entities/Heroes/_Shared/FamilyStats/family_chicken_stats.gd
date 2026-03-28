class_name FamilyChickenLordStats
extends FamilyStats

enum CbVars {
	SELF_CHICKEN,
	ALIVE_CHICKENS,
	DEATH_COUNT,
}

const HP: Array[float] = [30, 70, 110, 140, 200]
const AD: Array[float] = [12, 14, 16, 20, 25]
const ARMOR: Array[float] = [12, 12, 12, 12, 12]
const CRIT_CHANCE: Array[float] = [5, 5, 5, 5, 5]
const CRIT_MULTI: Array[float] = [100, 100, 100, 100, 100]


var on_chicken_spawned_callbacks: Array[Callable]
var on_chicken_death_callbacks: Array[Callable]

var spawn_period_decrease: float
var gifted_chance_increase: float
var spawn_number_increase: int

var dodge_inherited: float
var spawn_trex_on_start: bool

## HatchModifiers registered by cards — copied into each egg at spawn time.
var hatch_modifiers: Array[HatchModifier]
