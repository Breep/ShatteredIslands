class_name HatchModifier
extends RefCounted

## Modifier applied during egg hatching.
## Cards register HatchModifiers on FamilyChickenLordStats to alter egg behavior.
##
## Usage example (card that gives 30% chance to spawn an extra chicken):
## [codeblock]
## var mod := HatchModifier.new()
## mod.id = &"Extra Chicken"
## mod.before_hatch_callback = func(vars: Dictionary) -> void:
##     if randf() < 0.30:
##         vars[HatchModifier.VarType.SPAWN_COUNT] += 1
## family_stats.chicken_lord.hatch_modifiers.append(mod)
## [/codeblock]

enum VarType {
	EGG,            ## The ChickenEgg entity
	SUMMONER,       ## The hero that originally summoned the egg
	CHICKEN_TYPE,   ## Chicken.Type to spawn
	SPAWN_COUNT,    ## int — number of chickens to hatch (modifiable)
	SPAWN_CONFIG,   ## SpawnLocationConfig used for spawning
	CHICKEN_MODIFIERS, ## Dictionary passed to summon_entity for the chicken
}

var id: StringName
var is_one_time_effect: bool = false
var before_hatch_callback := Callable() ## (vars: Dictionary) -> void
var after_hatch_callback := Callable()  ## (vars: Dictionary) -> void
