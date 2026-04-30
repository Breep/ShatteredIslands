class_name TutorialOverlay
extends Control

# Overlay container that hosts the active UIBraiseBubble. Lives inside
# UIPersistant so it stays on top across the entire in-game UI. Owns no game
# logic — TutorialManager drives it.

#region ============================== Signals ==============================
signal step_completed(step: TutorialStep)
signal step_skipped(step: TutorialStep)
#endregion


#region ============================== Constants ==============================
const _BUBBLE_SCENE: PackedScene = preload("res://04_UI/Tool/Tutorial/BraiseBubble/ui_braise_bubble.tscn")
#endregion


#region ============================== Private variables ==============================
var _current_bubble: UIBraiseBubble
var _current_step: TutorialStep
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
#endregion


#region ============================== Public functions ==============================
func present_step(step: TutorialStep) -> void:
	clear()
	_current_step = step
	_current_bubble = _BUBBLE_SCENE.instantiate()
	add_child(_current_bubble)
	_current_bubble.skipped.connect(_on_bubble_skipped)
	_current_bubble.closed.connect(_on_bubble_closed)
	var target: Control = _resolve_target(step.target_unique_name)
	_current_bubble.show_bubble(step.text, target)


func complete_current_step() -> void:
	if _current_bubble == null: return
	_current_bubble.hide_bubble()
	# step_completed is emitted from _on_bubble_closed, after the close anim.


func clear() -> void:
	if _current_bubble != null and is_instance_valid(_current_bubble):
		if _current_bubble.skipped.is_connected(_on_bubble_skipped):
			_current_bubble.skipped.disconnect(_on_bubble_skipped)
		if _current_bubble.closed.is_connected(_on_bubble_closed):
			_current_bubble.closed.disconnect(_on_bubble_closed)
		_current_bubble.queue_free()
	_current_bubble = null
	_current_step = null


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
#endregion


#region ============================== Callbacks ==============================
func _on_bubble_skipped() -> void:
	var step: TutorialStep = _current_step
	step_skipped.emit(step)


func _on_bubble_closed() -> void:
	var step: TutorialStep = _current_step
	_current_bubble = null
	_current_step = null
	step_completed.emit(step)
#endregion
