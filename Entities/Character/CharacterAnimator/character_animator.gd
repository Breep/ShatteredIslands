class_name CharacterAnimator
extends Node

@export var _animation_tree: AnimationTree
@export var _owner: Character

var _is_fighting: bool = false

func _ready() -> void:
	GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)
	_owner.dead.connect(_on_owner_dead)
	Events.game_state_changed.connect(_on_events_game_stated_changed)


func _process(delta: float) -> void:
	var closest_enemy: Entity = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if closest_enemy != null and _is_fighting:
		_owner.look_at_target_y_only(closest_enemy.global_position)


func _on_global_fighting_manager_state_changed(new_state: GlobalFightingManager.FightingState) -> void:
	match new_state:
		GlobalFightingManager.FightingState.POSITIONING:
			_animation_tree.set("parameters/Transition/transition_request", "Idle")
		GlobalFightingManager.FightingState.COUNTDOWN:
			_is_fighting = true
		GlobalFightingManager.FightingState.FIGHT:
			return
		GlobalFightingManager.FightingState.FIGHT_ACCELERATED:
			pass
		GlobalFightingManager.FightingState.FINISHED:
			_animation_tree.set("parameters/Transition/transition_request", "Dance")


func _on_owner_dead(_self_ref: Entity) -> void:
	_animation_tree.set("parameters/Transition/transition_request", "Die")


func _on_events_game_stated_changed(new_state: Game.GameState) -> void:
	match new_state:
		Game.GameState.BUYING:
			_animation_tree.set("parameters/Transition/transition_request", "Idle")
