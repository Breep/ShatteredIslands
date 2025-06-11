class_name HeroAnimator
extends Node

@export var _animation_tree: AnimationTree

var _character_owner: Character
var character_owner: Character:
	get: return _character_owner
	set(value):
		if value == _character_owner: return
		_character_owner = value
		_character_owner.dead.connect(_on_character_owner_dead)
		_character_owner.fight_is_won.connect(_on_character_owner_fight_is_won)

var _is_fighting: bool = false

func _ready() -> void:
	GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)
	
	Events.game_state_changed.connect(_on_events_game_stated_changed)


func _process(delta: float) -> void:
	if _character_owner == null or _character_owner.target_module == null: return
	var closest_enemy: Entity = _character_owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if closest_enemy != null and _is_fighting:
		_character_owner.look_at_target_y_only(closest_enemy.global_position)


func _on_global_fighting_manager_state_changed(new_state: GlobalFightingManager.FightingState) -> void:
	match new_state:
		GlobalFightingManager.FightingState.POSITIONING:
			_animation_tree.set("parameters/Transition/transition_request", "Idle")
		GlobalFightingManager.FightingState.COUNTDOWN:
			_is_fighting = true
		GlobalFightingManager.FightingState.FIGHT:
			return
		GlobalFightingManager.FightingState.FIGHT_ACCELERATED:
			return
		GlobalFightingManager.FightingState.FINISHED:
			return


func _on_character_owner_dead(_self_ref: Entity) -> void:
	_animation_tree.set("parameters/Transition/transition_request", "Die")


func _on_events_game_stated_changed(new_state: Game.GameState) -> void:
	match new_state:
		Game.GameState.BUYING:
			_animation_tree.set("parameters/Transition/transition_request", "Idle")


func _on_character_owner_fight_is_won() -> void:
	print("[DEBUG] ", _character_owner.name, " won a fight and should DANCE")
	_animation_tree.set("parameters/Transition/transition_request", "Dance")
