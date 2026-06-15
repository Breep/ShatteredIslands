class_name MoltenGolem
extends Entity

# Summoned by the Skeleton Dragon's "Couvée de cendres" (Gold) talent: it drops in from
# a meteor, so it plays its landing one-shot (JumpEnd, wired on one_shot_land) on spawn.

@onready var _animation_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	super._ready()
	if _animation_tree != null:
		_animation_tree.set("parameters/one_shot_land/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
