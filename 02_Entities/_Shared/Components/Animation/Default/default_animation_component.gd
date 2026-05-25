class_name DefaultAnimationComponent
extends AnimationComponent

# Speed thresholds for animation transitions
const WALK_SPEED_THRESHOLD: float = 0.1
const RUN_SPEED_THRESHOLD: float = 5.0

@export var _animation_tree: AnimationTree

#region AnimatorTree parameters
const PARAM_SWITCH_ENTITY_MODE: String = "parameters/switch_entity_mode/transition_request"
const VALUE_SWITCH_ENTITY_MODE_EDITOR: String = "Editor"
const VALUE_SWITCH_ENTITY_MODE_INGAME: String = "InGame"

const PARAM_SWITCH_ENTITY_LIFE_STATE: String = "parameters/switch_entity_life_state/transition_request"
const VALUE_SWITCH_ENTITY_LIFE_STATE_DEAD: String = "Dead"
const VALUE_SWITCH_ENTITY_LIFE_STATE_ALIVE: String = "Alive"

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
const PARAM_SCALE_ATTACK_1: String = "parameters/scale_attack_1/scale"
const PARAM_SCALE_ATTACK_2: String = "parameters/scale_attack_2/scale"
const PARAM_SCALE_ATTACK_3: String = "parameters/scale_attack_3/scale"

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

# Base attack animation duration (cached on ready) (premultiplied by default by scale_attack_<x>)
var _aa_1_anim_base_duration: float = 3.2
var _aa_2_anim_base_duration: float = 3.2
var _aa_3_anim_base_duration: float = 3.2

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
	_init_aa_durations()

	_owner.life_state_changed.connect(_on_owner_life_state_changed)
	_owner.is_moving_changed.connect(_on_owner_is_moving_changed)
	
	_owner.draggable.dragged.connect(_on_owner_dragged)
	_owner.draggable.dropped.connect(_on_owner_dropped)
	
	_owner.alterations.stunned_changed.connect(_on_owner_stunned_changed)
	
	_owner.action_received.connect(_on_owner_action_received)
	_owner.ultimate_casted.connect(_on_owner_cast_ultimate)

	_on_owner_life_state_changed(Entity.LifeState.ALIVE)


func connect_modules(auto_attack_module: AutoAttackComponent, draggable_module: DraggableComponent = null) -> void:
	if auto_attack_module != null:
		auto_attack_module.attack_started.connect(_on_owner_auto_attack_started)
	if draggable_module != null:
		draggable_module.dragged.connect(_on_owner_dragged)
		draggable_module.dropped.connect(_on_owner_dropped)


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

	var attack_index: int = _rng.randi_range(1, 3)
	var switch_value: String = VALUE_SWITCH_ATTACK_1
	var base_duration: float = _aa_1_anim_base_duration
	match attack_index:
		2:
			switch_value = VALUE_SWITCH_ATTACK_2
			base_duration = _aa_2_anim_base_duration
		3:
			switch_value = VALUE_SWITCH_ATTACK_3
			base_duration = _aa_3_anim_base_duration

	var speed_scale: float = base_duration / lock_seconds if lock_seconds > 0.0 else 1.0
	Verbose.debug("Auto attack started (attack=" + str(attack_index) + ", speed_scale=" + str(speed_scale).pad_decimals(2) + ")", Verbose.Category.ENTITY_ANIMATION)
	_animation_tree.set(PARAM_SWITCH_ATTACK, switch_value)
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


func _on_owner_dragged() -> void:
	_animation_tree.set(PARAM_SWITCH_POSITIONING, VALUE_SWITCH_POSITIONIN_ON)
	_animation_tree.set(PARAM_ONE_SHOT_LAND, AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)


func _on_owner_dropped() -> void:
	_animation_tree.set(PARAM_SWITCH_POSITIONING, VALUE_SWITCH_POSITIONIN_OFF)
	_animation_tree.set(PARAM_ONE_SHOT_LAND, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_owner_stunned_changed(is_active: bool, _duration: float, _infinite: bool) -> void:
	if is_active:
		_animation_tree.set(PARAM_SWITCH_STUNNED_STATE, VALUE_SWITCH_STUNNED_STATE_STUNNED)
	else:
		_animation_tree.set(PARAM_SWITCH_STUNNED_STATE, VALUE_SWITCH_STUNNED_STATE_NOT_STUNNED)


func _on_owner_action_received(source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	if not is_critical: return
	if not Utils.get_action_category(action_type) == Utils.ActionCategory.DAMAGE: return
	_animation_tree.set(PARAM_ONE_SHOT_HIT, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_owner_cast_ultimate() -> void:
	_animation_tree.set(PARAM_ONE_SHOT_ULTIMATE, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
#endregion


#region Private API
func _init_aa_durations() -> void:
	if _owner.entity_desc == null: return
	var scale_1: float = _animation_tree.get(PARAM_SCALE_ATTACK_1)
	var scale_2: float = _animation_tree.get(PARAM_SCALE_ATTACK_2)
	var scale_3: float = _animation_tree.get(PARAM_SCALE_ATTACK_3)

	_aa_1_anim_base_duration = _owner.entity_desc.aa_1_anim_base_duration / scale_1
	_aa_2_anim_base_duration = _owner.entity_desc.aa_2_anim_base_duration / scale_2
	_aa_3_anim_base_duration = _owner.entity_desc.aa_3_anim_base_duration / scale_3
	
