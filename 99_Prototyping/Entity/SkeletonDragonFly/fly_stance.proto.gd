class_name FlyStanceProto
extends Node3D

# Proto: validates the Skeleton Dragon "Fly" stance feel and API shape
# (takeoff -> fly loop -> landing) by driving the raw AnimationPlayer directly,
# BEFORE the switch_fly StateMachine is wired into the real AnimationTree.
# The public methods here mirror the API the future SkeletonDragonAnimationComponent
# will expose, so this proto doubles as an integration spec.

#region Enums
enum FlyState { GROUNDED, TAKING_OFF, FLYING, LANDING }
#endregion

#region Private vars
# Clip names exactly as authored in the AnimationPlayer (note the asset typo on takeoff).
const _ANIM_TAKEOFF: String = "Transiton_ToFly"
const _ANIM_FLY_IDLE: String = "Fly_Idle"
const _ANIM_FLY_FORWARD: String = "Walk_Fly_Forward"
const _ANIM_LANDING: String = "Transition_ToGround"
const _ANIM_GROUND_IDLE: String = "Idle_Ground"
const _ANIM_BREATH: String = "Idle_Ground01"

const _BLEND: float = 0.2

const _VFX_AP_PATH: String = "SkeletalDragonVisual/root/Skeleton3D/BoneAttachment3D/VFX_Flamethrower_Anime_A/AnimationPlayer"

@onready var _anim: AnimationPlayer = $SkeletalDragonVisual/AnimationPlayer
@onready var _camera: Camera3D = $Camera3D
@onready var _status_label: Label = %StatusLabel

var _state: FlyState = FlyState.GROUNDED
var _breath: BreathVfxController
#endregion

#region Node base functions
func _ready() -> void:
	_camera.look_at(Vector3(0.0, 4.0, 0.0))
	_anim.animation_finished.connect(_on_animation_finished)

	_setup_breath()

	%TakeOffButton.pressed.connect(play_takeoff)
	%FlyForwardButton.pressed.connect(play_fly_forward)
	%LandButton.pressed.connect(play_land)
	%ResetButton.pressed.connect(reset_ground)
	%BreathButton.pressed.connect(play_breath)

	reset_ground()
#endregion

#region Public functions
func play_takeoff() -> void:
	if _state != FlyState.GROUNDED:
		return
	_set_state(FlyState.TAKING_OFF)
	_anim.play(_ANIM_TAKEOFF, _BLEND)


func play_fly_forward() -> void:
	if _state != FlyState.FLYING:
		return
	_anim.play(_ANIM_FLY_FORWARD, _BLEND)


func play_land() -> void:
	if _state != FlyState.FLYING:
		return
	_set_state(FlyState.LANDING)
	_anim.play(_ANIM_LANDING, _BLEND)


func reset_ground() -> void:
	_set_state(FlyState.GROUNDED)
	_anim.play(_ANIM_GROUND_IDLE, _BLEND)


func play_breath() -> void:
	if _state != FlyState.GROUNDED:
		return
	_anim.play(_ANIM_BREATH, _BLEND)
	if _breath != null:
		_breath.set_breath_active(true)
#endregion

#region Private functions
func _set_state(new_state: FlyState) -> void:
	_state = new_state
	_status_label.text = "State: " + FlyState.keys()[_state]


func _setup_breath() -> void:
	_breath = BreathVfxController.new()
	_breath._vfx_animation_player = get_node_or_null(_VFX_AP_PATH) as AnimationPlayer
	add_child(_breath)
#endregion

#region Callbacks
func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		_ANIM_TAKEOFF:
			_set_state(FlyState.FLYING)
			_anim.play(_ANIM_FLY_IDLE, _BLEND)
		_ANIM_FLY_IDLE:
			if _state == FlyState.FLYING:
				_anim.play(_ANIM_FLY_IDLE, _BLEND)  # manual loop if clip is not flagged looping
		_ANIM_LANDING:
			reset_ground()
		_ANIM_BREATH:
			if _breath != null:
				_breath.set_breath_active(false)
			reset_ground()
#endregion
