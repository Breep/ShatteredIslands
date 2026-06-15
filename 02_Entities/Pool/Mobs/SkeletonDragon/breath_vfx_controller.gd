class_name BreathVfxController
extends Node

# Drives the Skeleton Dragon's fire-breath VISUALS and toggles a detection hitbox —
# NO gameplay/damage logic (that lives in the ultimate skill, which listens to the
# signals below). The VFX is toggled through its own AnimationPlayer (Start/End).
# The hitbox is a scene-authored Area3D parented under the head bone, so it sweeps
# with the roar animation and can be sized/oriented visually in the editor.
# Driving: optionally self-driven from the ultimate one-shot tree param (so it stays
# tied to the animation), or manually via set_breath_active() (e.g. the proto button).

#region Signals
signal breath_started
signal breath_ended
## A body entered the breath hitbox while active.
signal breath_body_entered(body: Node3D)
#endregion

#region Export
@export var _vfx_animation_player: AnimationPlayer
## Area3D authored in the scene under the head bone — size/orient its CapsuleShape3D
## and set its collision_mask (entities' layer) visually in the editor. The controller
## only enables/disables its monitoring.
@export var _hitbox: Area3D

## Optional: when set, the breath self-drives from this tree param (the ultimate's
## roar one-shot), staying tied to the animation. Leave null to drive it manually.
@export var _animation_tree: AnimationTree
@export var _breath_active_param: String = "parameters/one_shot_ultimate/active"
#endregion

#region Private vars
const _VFX_START: String = "Start"
const _VFX_END: String = "End"

var _active: bool = false
# Root of the VFX subtree (the AnimationPlayer's parent). We own its visibility so the
# breath never depends on a scene-authored visible flag.
var _vfx_root: Node3D
#endregion

#region Node base functions
func _ready() -> void:
	if _hitbox != null:
		_hitbox.monitoring = false
		_hitbox.body_entered.connect(_on_body_entered)
	if _vfx_animation_player != null:
		_vfx_root = _vfx_animation_player.get_parent() as Node3D
	# Start hidden: the VFX autoplays "Init" (emitting ON) on load, so force it off
	# (emitting + visibility). We can't go through set_breath_active(false): _active
	# already starts false, so its guard would skip the work.
	if _vfx_animation_player != null:
		_vfx_animation_player.play(_VFX_END)
	if _vfx_root != null:
		_vfx_root.visible = false
	set_process(_animation_tree != null) # only self-drive when wired to a tree


func _process(_delta: float) -> void:
	set_breath_active(bool(_animation_tree.get(_breath_active_param)))
#endregion

#region Public functions
## Single seam: turn the breath (VFX + hitbox) on or off.
func set_breath_active(active: bool) -> void:
	if active == _active:
		return
	_active = active
	if _vfx_root != null:
		_vfx_root.visible = active
	if _vfx_animation_player != null:
		_vfx_animation_player.play(_VFX_START if active else _VFX_END)
	if _hitbox != null:
		_hitbox.monitoring = active
	if active:
		breath_started.emit()
	else:
		breath_ended.emit()
#endregion

#region Callbacks
func _on_body_entered(body: Node3D) -> void:
	if _active:
		breath_body_entered.emit(body)
#endregion
