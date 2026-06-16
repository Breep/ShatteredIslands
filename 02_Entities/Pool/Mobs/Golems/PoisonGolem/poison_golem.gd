class_name PoisonGolem
extends Entity

# Golem de poison. Comme le Molten, il arrive en tombant : il joue son anim d'atterrissage
# (one_shot_land) au spawn. Toute sa logique vit dans ses skills (Skills/).

@onready var _animation_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	super._ready()
	if _animation_tree != null:
		_animation_tree.set("parameters/one_shot_land/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_died() -> void:
	super._on_died()
	AudioManager.play_3d("golem_collapse", global_position)
