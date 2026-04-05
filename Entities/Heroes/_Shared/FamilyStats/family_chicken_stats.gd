class_name FamilyChickenLordStats
extends FamilyStats

enum CbVars {
	SELF_CHICKEN,
	ALIVE_CHICKENS,
	DEATH_COUNT,
}

const HP: Array[float] = [0, 16, 32, 48, 64]
const AD: Array[float] = [0, 2, 4, 6, 8]
const ARMOR: Array[float] = [0, 0, 0, 0, 0]
const CRIT_CHANCE: Array[float] = [0, 3, 5, 7, 11]
const CRIT_MULTI: Array[float] = [0, 0, 0, 0, 0]

var on_chicken_spawned_callbacks: Array[Callable]
var on_chicken_death_callbacks: Array[Callable]

var spawn_period_decrease: float
var gifted_chance_increase: float
var spawn_number_increase: int = 0

var dodge_inherited: float
var spawn_trex_on_start: bool

var dead_chicken_count: int
var alive_chicken_count: int

var gifted_types: Array[Chicken.Type]

## HatchModifiers registered by cards — copied into each egg at spawn time.
var hatch_modifiers: Array[HatchModifier]
