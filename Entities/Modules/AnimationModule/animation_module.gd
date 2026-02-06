class_name AnimationModule
extends Node

signal attack_hit_frame()

const IDLE_VAR_TIMER_MIN_WAIT_TIME: float = 5.0
const IDLE_VAR_TIMER_MAX_WAIT_TIME: float = 15.0

# Speed thresholds for animation transitions
const WALK_SPEED_THRESHOLD: float = 0.1
const RUN_SPEED_THRESHOLD: float = 5.0

@export var _animation_tree: AnimationTree
@export var _animation_player: EntityAnimationPlayer
@export var _entity_owner: Entity

#region AnimatorTree parameters
const PARAM_TRANSITION_GLOBAL: String = "parameters/transition_global/transition_request"
const VALUE_TRANSITION_GLOBAL_TPOSE: String = "TPOSE"
const VALUE_TRANSITION_GLOBAL_FIGHTING: String = "Fighting"

const PARAM_TRANSITION_FIGHTING: String = "parameters/transition_fighting/transition_request"
const VALUE_TRANSITION_FIGHTING_IDLE: String = "Idle"
const VALUE_TRANSITION_FIGHTING_WALK: String = "Walk"
const VALUE_TRANSITION_FIGHTING_RUN: String = "Run"
const VALUE_TRANSITION_FIGHTING_DANCE: String = "Dance"
const VALUE_TRANSITION_FIGHTING_DIE: String = "Die"

const PARAM_SCALE_IDLE: String = "parameters/scale_idle/scale"
const PARAM_SCALE_IDLE_VAR: String = "parameters/scale_idle_var/scale"
const PARAM_ONE_SHOT_IDLE: String = "parameters/one_shot_idle/request"

const PARAM_SCALE_DANCE: String = "parameters/scale_dance/scale"
const PARAM_SCALE_DIE: String = "parameters/scale_die/scale"
const PARAM_SCALE_WALK: String = "parameters/scale_walk/scale"
const PARAM_SCALE_RUN: String = "parameters/scale_run/scale"

const PARAM_SCALE_ATTACK: String = "parameters/scale_attack/scale"
const PARAM_ONE_SHOT_ATTACK: String = "parameters/one_shot_attack/request"

const PARAM_SCALE_ULTIMATE: String = "parameters/scale_ultimate/scale"
const PARAM_ONE_SHOT_ULTIMATE: String = "parameters/one_shot_ultimate/request"

const PARAM_ONE_SHOT_SITTING: String = "parameters/one_shot_sitting/request"
#endregion

@onready var _rng := RandomNumberGenerator.new()

var _idle_variation_timer: Timer
var _current_movement_state: String = VALUE_TRANSITION_FIGHTING_IDLE
var _lock_animation: bool = false

func _ready() -> void:
	if _entity_owner == null:
		Verbose.error("AnimationModule: No entity owner", Verbose.Category.ENTITY)
		return
	
	_rng.randomize()
	
	_idle_variation_timer = Timer.new()
	add_child(_idle_variation_timer)
	_idle_variation_timer.name = "IdleVariationTimer"
	
	_entity_owner.died.connect(_on_entity_owner_died)
	_entity_owner.auto_attack_started.connect(_on_entity_owner_auto_attack_started)

	_entity_owner.fighting_state_changed.connect(_on_entity_owner_fighting_state_changed)
	
	_animation_player.attack_done.connect(_on_animation_player_attack_done)
	
	_idle_variation_timer.timeout.connect(_on_idle_variation_timer_timeout)
	
	_animation_tree.set(PARAM_TRANSITION_GLOBAL, VALUE_TRANSITION_GLOBAL_FIGHTING)
	_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_IDLE)


func _process(_delta: float) -> void:
	if _lock_animation: return
	if _entity_owner == null:
		return
	
	# Check entity velocity to determine movement animation
	var velocity_magnitude: float = _entity_owner.velocity.length()
	
	var target_state: String = VALUE_TRANSITION_FIGHTING_IDLE
	
	if velocity_magnitude >= RUN_SPEED_THRESHOLD:
		target_state = VALUE_TRANSITION_FIGHTING_RUN
	elif velocity_magnitude >= WALK_SPEED_THRESHOLD:
		target_state = VALUE_TRANSITION_FIGHTING_WALK
	else:
		target_state = VALUE_TRANSITION_FIGHTING_IDLE
	
	# Only update if state changed
	if target_state != _current_movement_state:
		_current_movement_state = target_state
		_animation_tree.set(PARAM_TRANSITION_FIGHTING, target_state)

#region signals
func _on_entity_owner_fighting_state_changed(new_state: Entity.FightingState) -> void:
	match new_state:
		Entity.FightingState.FIGHTING: pass
		Entity.FightingState.CELEBRATING: pass
		Entity.FightingState.DEAD: _lock_animation = true


func _on_entity_owner_died(_self_ref: Entity) -> void:
	_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_DIE)


func _on_entity_owner_fight_is_won() -> void:
	if _lock_animation: return
	_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_DANCE)


func _on_entity_owner_fight_is_lost() -> void:
	if _lock_animation: return
	_animation_tree.set(PARAM_TRANSITION_FIGHTING, VALUE_TRANSITION_FIGHTING_DIE)


func _on_entity_owner_auto_attack_started(is_critical: bool) -> void:
	if _lock_animation: return
	_animation_tree.set(PARAM_SCALE_ATTACK, 1.0 + _entity_owner.stats.attack_speed)
	_animation_tree.set(PARAM_ONE_SHOT_ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_entity_owner_ultimate_casted() -> void:
	if _lock_animation: return
	_animation_tree.set(PARAM_ONE_SHOT_ULTIMATE, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_idle_variation_timer_timeout() -> void:
	if _lock_animation: return
	_animation_tree.set(PARAM_ONE_SHOT_SITTING, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	_restart_idle_variation_animation()


func _on_entity_animation_player_attack_done() -> void:
	if _lock_animation: return
	attack_hit_frame.emit()


func _on_animation_player_attack_done() -> void:
	if _lock_animation: return
	attack_hit_frame.emit()
#endregion

#region private methods
func _restart_idle_variation_animation() -> void:
	if _lock_animation: return
	_idle_variation_timer.wait_time = _rng.randf_range(IDLE_VAR_TIMER_MIN_WAIT_TIME, IDLE_VAR_TIMER_MAX_WAIT_TIME)
	_idle_variation_timer.start()
#endregion
