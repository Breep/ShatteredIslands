## Implémentation par défaut d'EntityPreview, pilotée par un AnimationTree : chaque
## animation de présentation est un nœud OneShot nommé one_shot_<spawn|dazed|selected>.
## Le dazed est un one-shot qui s'auto-coupe après _dazed_duration.
class_name DefaultEntityPreview
extends EntityPreview

@export var _animation_tree: AnimationTree
## Durée (s) avant l'arrêt automatique de l'animation de dazed.
@export var _dazed_duration: float = 2.0

const PARAM_ONE_SHOT_SPAWN: String = "parameters/one_shot_spawn/request"
const PARAM_ONE_SHOT_DAZED: String = "parameters/one_shot_dazed/request"
const PARAM_ONE_SHOT_SELECTED: String = "parameters/one_shot_selected/request"

# Incrémenté à chaque dazed : un nouveau dazed invalide l'arrêt différé du précédent.
var _dazed_request_id: int = 0


# ============================== Public functions ==============================

func start_spawn_animation() -> void:
	if _animation_tree == null: return
	_animation_tree.set(PARAM_ONE_SHOT_SPAWN, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func start_selected_animation() -> void:
	if _animation_tree == null: return
	_animation_tree.set(PARAM_ONE_SHOT_SELECTED, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func start_dazed_animation() -> void:
	if _animation_tree == null: return
	_animation_tree.set(PARAM_ONE_SHOT_DAZED, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	_dazed_request_id += 1
	var request_id: int = _dazed_request_id
	await get_tree().create_timer(_dazed_duration).timeout
	if _animation_tree == null or request_id != _dazed_request_id:
		return
	_animation_tree.set(PARAM_ONE_SHOT_DAZED, AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
