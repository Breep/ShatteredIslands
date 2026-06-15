class_name SE_CouveeBlindee
extends SkillEffect

# Talent "Couvée blindée": les poulets invoqués par ce poulailler gagnent _block Block à
# leur apparition (appliqué par ChickenCoop.summon_chicken via meta).

@export var _block: float = 3.0


func apply(ctx: SkillContext) -> void:
	var coop: ChickenCoop = ctx.entity as ChickenCoop
	if coop == null:
		Verbose.error("SE_CouveeBlindee: owner is not a ChickenCoop", Verbose.Category.ENTITY_MODULE)
		return
	coop.set_meta(ChickenCoop.META_SPAWN_BLOCK, _block)


func get_description() -> String:
	return "Les poulets invoqués par ce poulailler gagnent " + _value(_block) + " [[BLOCK]] " \
		+ "à leur apparition."
