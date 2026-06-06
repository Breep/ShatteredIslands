class_name IceGolem
extends Entity

# Golem de glace. Comme le Molten, il arrive en tombant : il joue son anim d'atterrissage
# (one_shot_land) au spawn. Toute sa logique vit dans ses skills (Skills/).

@onready var _animation_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	super._ready()
	if _animation_tree != null:
		_animation_tree.set("parameters/one_shot_land/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
