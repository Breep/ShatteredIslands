class_name MoltenGolem
extends Entity

# Summoned by the Skeleton Dragon's "Couvée de cendres" (Gold) talent: it drops in from
# a meteor, so it plays its landing one-shot (JumpEnd, wired on one_shot_land) on spawn.

# LEVEL: spawn-time level, set before the entity enters the tree so its skill tiers
# (Couvée Gold included) unlock during _ready. Bumping the level after spawn would not
# re-apply already-skipped tiers.
enum Modifier { LEVEL }

@onready var _animation_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	super._ready()
	if _animation_tree != null:
		_animation_tree.set("parameters/one_shot_land/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
