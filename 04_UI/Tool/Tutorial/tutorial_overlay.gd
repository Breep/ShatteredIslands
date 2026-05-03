class_name TutorialOverlay
extends Control

# Overlay container that hosts the active UIBraiseBubble. Lives inside
# UIPersistant so it stays on top across the entire in-game UI. Owns no game
# logic — TutorialManager drives it. Manages an optional input blocker
# (with hole-punch on the active target) for blocking and modal-dimmed steps.

#region ============================== Signals ==============================
signal step_completed(step: TutorialStep)
#endregion


#region ============================== Constants ==============================
const _BUBBLE_SCENE: PackedScene = preload("res://04_UI/Tool/Tutorial/BraiseBubble/ui_braise_bubble.tscn")

const _DIM_ALPHA: float = 0.5
const _DIM_FADE_TIME: float = 0.2
#endregion


#region ============================== Private variables ==============================
var _current_bubble: UIBraiseBubble
var _current_step: TutorialStep
var _dim_tween: Tween
#endregion


#region ============================== Local nodes ==============================
@onready var _blocker: TutorialBlocker = %Blocker
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
#endregion


#region ============================== Public functions ==============================
func present_step(step: TutorialStep, is_last: bool = false) -> void:
	clear()
	_current_step = step
	_current_bubble = _BUBBLE_SCENE.instantiate()
	add_child(_current_bubble)
	_current_bubble.closed.connect(_on_bubble_closed)
	var target: Control = _resolve_target(step.target_unique_name)
	_apply_popup_mode(step.popup_mode, target)
	_current_bubble.show_bubble(step, target, is_last)


func complete_current_step() -> void:
	if _current_bubble == null: return
	_current_bubble.hide_bubble()
	# step_completed is emitted from _on_bubble_closed, after the close anim.


func clear() -> void:
	if _current_bubble != null and is_instance_valid(_current_bubble):
		if _current_bubble.closed.is_connected(_on_bubble_closed):
			_current_bubble.closed.disconnect(_on_bubble_closed)
		_current_bubble.queue_free()
	_current_bubble = null
	_current_step = null
	_hide_blocker()


func has_active_step() -> bool:
	return _current_step != null
#endregion


#region ============================== Private functions ==============================
func _resolve_target(unique_name: StringName) -> Control:
	if unique_name == &"":
		return null
	var node: Node = null
	if get_tree().current_scene != null:
		node = get_tree().current_scene.find_child(String(unique_name), true, false)
	if node == null:
		node = get_tree().root.find_child(String(unique_name), true, false)
	if node is Control:
		return node
	Verbose.warn("Tutorial target not found or not a Control: " + String(unique_name), Verbose.Category.TUTORIAL)
	return null


func _apply_popup_mode(mode: int, target: Control) -> void:
	match mode:
		TutorialStep.PopupMode.PASSIVE:
			_hide_blocker()
		TutorialStep.PopupMode.BLOCKING:
			_show_blocker(target, 0.0)
		TutorialStep.PopupMode.MODAL_DIMMED:
			_show_blocker(target, _DIM_ALPHA)


func _show_blocker(target: Control, target_alpha: float) -> void:
	_blocker.target_rect = target.get_global_rect() if target != null and is_instance_valid(target) else Rect2()
	_blocker.visible = true
	_kill_tween(_dim_tween)
	_dim_tween = create_tween()
	_dim_tween.tween_property(_blocker, "color:a", target_alpha, _DIM_FADE_TIME)


func _hide_blocker() -> void:
	if _blocker == null: return
	_kill_tween(_dim_tween)
	_blocker.target_rect = Rect2()
	_blocker.color.a = 0.0
	_blocker.visible = false


func _kill_tween(t: Tween) -> void:
	if t and t.is_valid():
		t.kill()
#endregion


#region ============================== Callbacks ==============================
func _on_bubble_closed() -> void:
	var step: TutorialStep = _current_step
	_current_bubble = null
	_current_step = null
	_hide_blocker()
	step_completed.emit(step)
#endregion
