class_name DefaultAnimationComponent
extends AnimationComponent

# Speed thresholds for animation transitions
const WALK_SPEED_THRESHOLD: float = 0.1
const RUN_SPEED_THRESHOLD: float = 5.0

@export var _animation_tree: AnimationTree

#region AnimatorTree parameters
const PARAM_SWITCH_ENTITY_MODE: String = "parameters/switch_entity_mode/transition_request"
const VALUE_SWITCH_ENTITY_MODE_EDITOR: String = "Editor"
const VALUE_SWITCH_ENTITY_MODE_INGAME: String = "Ingame"

const PARAM_SWITCH_ENTITY_LIFE_STATE: String = "parameters/switch_entity_life_state/transition_request"
const VALUE_SWITCH_ENTITY_LIFE_STATE_DEAD: String = "Dead"
const VALUE_SWITCH_ENTITY_LIFE_STATE_ALIVE: String = "Fighting"

const PARAM_ONE_SHOT_HIT: String = "parameters/one_shot_hit/request"

const PARAM_SWITCH_STUNNED_STATE: String = "parameters/switch_stunned_state/transition_request"
const VALUE_SWITCH_STUNNED_STATE_NOT_STUNNED: String = "NotStunned"
const VALUE_SWITCH_STUNNED_STATE_STUNNED: String = "Stunned"

const PARAM_ONE_SHOT_ULTIMATE: String = "parameters/one_shot_ultimate/request"
const PARAM_SCALE_ULTIMATE: String = "parameters/scale_ultimate/scale"

const PARAM_SCALE_ATTACK: String = "parameters/scale_attack/scale"
const PARAM_ONE_SHOT_ATTACK: String = "parameters/one_shot_attack/request"
const PARAM_SWITCH_ATTACK: String = "parameters/switch_attack/transition_request"
const VALUE_SWITCH_ATTACK_1: String = "Attack1"
const VALUE_SWITCH_ATTACK_2: String = "Attack2"
const VALUE_SWITCH_ATTACK_3: String = "Attack3"

const PARAM_ONE_SHOT_LAND: String = "parameters/one_shot_land/request"

const PARAM_SWITCH_POSITIONING: String = "parameters/switch_positioning/transition_request"
const VALUE_SWITCH_POSITIONIN_OFF: String = "Off"
const VALUE_SWITCH_POSITIONIN_ON: String = "On"


const PARAM_SWITCH_MAIN: String = "parameters/switch_main/transition_request"
const VALUE_SWITCH_MAIN_IDLE: String = "Idle"
const VALUE_SWITCH_MAIN_MOVING: String = "Moving"
const VALUE_SWITCH_MAIN_CELEBRATING: String = "Celebrating"

const PARAM_SWITCH_MOVING: String = "parameters/switch_moving/transition_request"
const VALUE_SWITCH_MOVING_WALK: String = "Walk"
const VALUE_SWITCH_MOVING_RUN: String = "Run"

const PARAM_SWITCH_IDLE: String = "parameters/switch_moving/transition_request"
const VALUE_SWITCH_IDLE_STANDING_NEUTRAL: String = "StandingNeutral"
const VALUE_SWITCH_IDLE_STANDING_AGGRESIVE: String = "StandingAggresive"
const VALUE_SWITCH_IDLE_SITTING_CHAIR: String = "SittingChair"
const VALUE_SWITCH_IDLE_SITTING_FLOOR: String = "SittingFloor"
const PARAM_SEEK_IDLE_STANDING_NEUTRAL: String = "parameters/seek_idle_standing_neutral/seek_request"
const PARAM_SEEK_IDLE_STANDING_AGGRESIVE: String = "parameters/seek_idle_standing_aggresive/seek_request"
const PARAM_SEEK_IDLE_SITTING_CHAIR: String = "parameters/seek_idle_sitting_chair/seek_request"
const PARAM_SEEK_IDLE_SITTING_FLOOR: String = "parameters/seek_idle_sitting_floor/seek_request"
#endregion

@onready var _rng := RandomNumberGenerator.new()

var _lock_animation: bool = false

# Base attack animation duration (cached on ready)
var _attack_anim_base_duration: float = 3.2 # Default fallback

func _enter_tree() -> void:
	if _owner == null: return
	if _owner.animation != null and _owner.animation != self:
		Verbose.trace("Override: DefaultAnimationComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.animation.queue_free()
	_owner.animation = self


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.animation != self:
		return

	if _animation_tree == null:
		Verbose.error("AnimationModule: No animation tree", Verbose.Category.ENTITY)
		queue_free()
		return

	_rng.randomize()

	_animation_tree.set(PARAM_SWITCH_ENTITY_MODE, VALUE_SWITCH_ENTITY_MODE_INGAME)

	_owner.life_state_changed.connect(_on_owner_life_state_changed)
	_owner.is_moving_changed.connect(_on_owner_is_moving_changed)
	
	_owner.draggable.dragged.connect(_on_dragged)
	_owner.draggable.dropped.connect(_on_dropped)

	_on_owner_life_state_changed(Entity.LifeState.ALIVE)


func connect_modules(auto_attack_module: AutoAttackComponent, draggable_module: DraggableComponent = null) -> void:
	if auto_attack_module != null:
		auto_attack_module.attack_started.connect(_on_owner_auto_attack_started)
	if draggable_module != null:
		draggable_module.dragged.connect(_on_dragged)
		draggable_module.dropped.connect(_on_dropped)


func stop_attack_animation() -> void:
	_animation_tree.set(PARAM_ONE_SHOT_ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)


#region signals
func _on_owner_life_state_changed(life_state: Entity.LifeState) -> void:
	match life_state:
		Entity.LifeState.ALIVE:
			_animation_tree.set(PARAM_SWITCH_ENTITY_LIFE_STATE, VALUE_SWITCH_ENTITY_LIFE_STATE_ALIVE)
		Entity.LifeState.DEAD:
			_animation_tree.set(PARAM_SWITCH_ENTITY_LIFE_STATE, VALUE_SWITCH_ENTITY_LIFE_STATE_DEAD)


func _on_owner_auto_attack_started(lock_seconds: float) -> void:
	Verbose.debug("Auto attack started (lock_seconds=" + str(lock_seconds).pad_decimals(2) + ")", Verbose.Category.ENTITY_ANIMATION)
	if _lock_animation:
		Verbose.warn("Auto attack - Animation is locked", Verbose.Category.ENTITY_ANIMATION)
		return
	# Calculate speed_scale so animation fits within lock_seconds
	var speed_scale: float = _attack_anim_base_duration / lock_seconds if lock_seconds > 0.0 else 1.0
	Verbose.debug("Auto attack started (speed_scale=" + str(speed_scale).pad_decimals(2) + ")", Verbose.Category.ENTITY_ANIMATION)
	_animation_tree.set(PARAM_SCALE_ATTACK, speed_scale)
	_animation_tree.set(PARAM_ONE_SHOT_ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_owner_ultimate_casted() -> void:
	if _lock_animation: return
	_animation_tree.set(PARAM_ONE_SHOT_ULTIMATE, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_owner_is_moving_changed(is_moving: bool) -> void:
	if _lock_animation: return
	if is_moving:
		var speed: float = _owner.stats.movement_speed if _owner.stats != null else 0.0
		var moving_state: String = VALUE_SWITCH_MOVING_RUN if speed >= RUN_SPEED_THRESHOLD else VALUE_SWITCH_MOVING_WALK
		_animation_tree.set(PARAM_SWITCH_MOVING, moving_state)
		_animation_tree.set(PARAM_SWITCH_MAIN, VALUE_SWITCH_MAIN_MOVING)
	else:
		_animation_tree.set(PARAM_SWITCH_MAIN, VALUE_SWITCH_MAIN_IDLE)


func _on_dragged() -> void:
	_animation_tree.set(PARAM_SWITCH_POSITIONING, VALUE_SWITCH_POSITIONIN_ON)
	_animation_tree.set(PARAM_ONE_SHOT_LAND, AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)


func _on_dropped() -> void:
	_animation_tree.set(PARAM_SWITCH_POSITIONING, VALUE_SWITCH_POSITIONIN_OFF)
	_animation_tree.set(PARAM_ONE_SHOT_LAND, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

#endregion
