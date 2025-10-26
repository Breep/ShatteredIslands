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
	if _character_owner == null:
		push_warning("HeroAnimator: No character owner")
		return
	
	_character_owner.fighting_state_changed.connect(_on_character_owner_fighting_state_changed)
	GameManager.game_state_changed.connect(_on_game_manager_game_stated_changed)


func _process(_delta: float) -> void:
	if not _is_fighting: return
	if _character_owner == null or _character_owner.target_module == null: return
	var closest_enemy: Entity = _character_owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if closest_enemy != null:
		_character_owner.look_at_target_y_only(closest_enemy.global_position)


func _on_character_owner_fighting_state_changed(new_state: Character.FightingState) -> void:
	match new_state:
		Character.FightingState.POSITIONING:
			_animation_tree.set("parameters/Transition/transition_request", "Idle")
		Character.FightingState.FIGHTING:
			_is_fighting = true
		Character.FightingState.CELEBRATING:
			_is_fighting = false


func _on_character_owner_dead(_self_ref: Entity) -> void:
	_animation_tree.set("parameters/Transition/transition_request", "Die")


func _on_game_manager_game_stated_changed(game_state: Game.GameState) -> void:
	if game_state == Game.GameState.BUYING:
		_animation_tree.set("parameters/Transition/transition_request", "Idle")


func _on_character_owner_fight_is_won() -> void:
	_animation_tree.set("parameters/Transition/transition_request", "Dance")
