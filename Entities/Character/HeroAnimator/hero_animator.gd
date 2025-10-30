class_name HeroAnimator
extends Node

@export var _animation_tree: AnimationTree
@export var _weapons_node: Node3D
@export var _hero_animation_player: HeroAnimationPlayer

#region AnimatorTree parameters
const PARAM_TRANSITION_GLOBAL: String = "parameters/transition_global/transition_request"
const VALUE_TRANSITION_GLOBAL_TPOSE: String = "TPOSE"
const VALUE_TRANSITION_GLOBAL_SITTING: String = "Sitting"
const VALUE_TRANSITION_GLOBAL_FIGHTING: String = "Fighting"

const PARAM_TRANSITION_FIGHTING: String = "parameters/transition_fighting/transition_request"
const VALUE_TRANSITION_FIGHTING_IDLE: String = "Idle"
const VALUE_TRANSITION_FIGHTING_DANCE: String = "Dance"
const VALUE_TRANSITION_FIGHTING_DIE: String = "Die"

const PARAM_SCALE_IDLE: String = "parameters/scale_idle/scale"
const PARAM_SCALE_IDLE_VAR: String = "parameters/scale_idle_var/scale"
const PARAM_ONE_SHOT_IDLE: String = "parameters/one_shot_idle/request"

const PARAM_SCALE_DANCE: String = "parameters/scale_dance/scale"
const PARAM_SCALE_DIE: String = "parameters/scale_die/scale"

const PARAM_SCALE_ATTACK_LEFT: String = "parameters/scale_attack_left/scale"
const PARAM_SCALE_ATTACK_RIGHT: String = "parameters/scale_attack_right/scale"
const PARAM_ONE_SHOT_ATTACK: String = "parameters/one_shot_attack/request"
const PARAM_BLEND_ATTACK: String = "parameters/blend_attack/blend_amount"

const PARAM_SCALE_ULTIMATE: String = "parameters/scale_ultimate/scale"
const PARAM_ONE_SHOT_ULTIMATE: String = "parameters/one_shot_ultimate/request"

const PARAM_ONE_SHOT_SITTING: String = "parameters/one_shot_sitting/request"
#endregion

@onready var _rng := RandomNumberGenerator.new()
@onready var _idle_variation_timer: Timer = %IdleVariationTimer 

var _character_owner: Character
var character_owner: Character:
	get: return _character_owner
	set(value):
		if value == _character_owner: return
		_character_owner = value

var _is_fighting: bool = false

func _ready() -> void:
	if _character_owner == null:
		push_warning("HeroAnimator: No character owner")
		return
	
	_rng.randomize()
	_character_owner.dead.connect(_on_character_owner_dead)
	_character_owner.fight_is_won.connect(_on_character_owner_fight_is_won)
	_character_owner.fight_is_lost.connect(_on_character_owner_fight_is_lost)
	_character_owner.fighting_state_changed.connect(_on_character_owner_fighting_state_changed)
	_character_owner.auto_attack_started.connect(_on_character_owner_auto_attack_started)
	_character_owner.ultimate_casted.connect(_on_character_owner_ultimate_casted)
	
	GameManager.game_state_changed.connect(_on_game_manager_game_stated_changed)
	
	_idle_variation_timer.timeout.connect(_on_idle_variation_timer_timeout)
	
	_hero_animation_player.attack_done.connect(_on_hero_animation_player_attack_done)


func _process(_delta: float) -> void:
	if not _is_fighting: return
	if _character_owner == null or _character_owner.target_module == null: return
	var closest_enemy: Entity = _character_owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if closest_enemy != null:
		_character_owner.look_at_target_y_only(closest_enemy.global_position)


func _on_character_owner_fighting_state_changed(new_state: Character.FightingState) -> void:
	match new_state:
		Character.FightingState.POSITIONING:
			pass
		Character.FightingState.FIGHTING:
			_is_fighting = true
		Character.FightingState.CELEBRATING:
			_is_fighting = false


func _on_character_owner_dead(_self_ref: Entity) -> void:
	_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_DIE)


func _on_game_manager_game_stated_changed(game_state: Game.GameState) -> void:
	match game_state:
		Game.GameState.UNDEF:
			_animation_tree.set(PARAM_TRANSITION_GLOBAL, VALUE_TRANSITION_GLOBAL_TPOSE)
		Game.GameState.BUYING:
			_animation_tree.set(PARAM_TRANSITION_GLOBAL, VALUE_TRANSITION_GLOBAL_SITTING)
			_start_buying_area_animation()
			_weapons_node.hide()
		Game.GameState.FIGHTING_POSITIONING:
			_idle_variation_timer.stop()
			_animation_tree.set(PARAM_TRANSITION_GLOBAL, VALUE_TRANSITION_GLOBAL_FIGHTING)
			_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_IDLE)
			_weapons_node.show()


func _on_character_owner_fight_is_won() -> void:
	_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_DANCE)


func _on_character_owner_fight_is_lost() -> void:
	_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_DIE)

func _on_character_owner_auto_attack_started(is_critical: bool) -> void:
	var use_right_hand: bool = _rng.randf_range(0.0, 1.0) < 0.5
	if use_right_hand: _animation_tree.set(PARAM_BLEND_ATTACK, 1.0)
	else: _animation_tree.set(PARAM_BLEND_ATTACK, 0.0)
	if is_critical: _animation_tree.set(PARAM_BLEND_ATTACK, 0.5)
	_animation_tree.set(PARAM_SCALE_ATTACK_LEFT, 1.0 + character_owner.stats.attack_speed)
	_animation_tree.set(PARAM_SCALE_ATTACK_RIGHT, 1.0 + character_owner.stats.attack_speed)
	_animation_tree.set(PARAM_ONE_SHOT_ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_character_owner_ultimate_casted() -> void:
	_animation_tree.set(PARAM_ONE_SHOT_ULTIMATE, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _start_buying_area_animation() -> void:
	_idle_variation_timer.wait_time = _rng.randf_range(5.0, 15.0)
	_idle_variation_timer.start()



func _on_idle_variation_timer_timeout() -> void:
	_animation_tree.set(PARAM_ONE_SHOT_SITTING, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	_start_buying_area_animation()


func _on_hero_animation_player_attack_done() -> void:
	_character_owner.anim_events_manager.attack_hit_frame.emit()


 
