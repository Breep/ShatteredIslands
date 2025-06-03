class_name DragAndDropRestricted_Blue
extends Node

signal drag_canceled(starting_position: Vector2)
signal drag_started
signal dropped(starting_position: Vector2)

@export var enabled: bool = true
@export var target: Area2D
@export var restriction_area: Area2D
@export var out_of_bounds_color: Color = Color.RED
@export var default_color: Color = Color.WHITE
@export var spawn_area: Area2D

@onready var spawn_blue: Area2D = spawn_area
@onready var highlight_blue: TextureRect = %Blue_hightlight

var starting_position: Vector2
var offset :Vector2 = Vector2.ZERO
var dragging : bool = false
var mouse_hand = load("res://Data/Assets/Cursor/hand_thin_open.png")


func _ready() -> void:
	assert(target, "No target set for DragAndDrop Component!")
	target.input_event.connect(_on_target_input_event.unbind(1))


func _process(_delta: float) -> void:
	if dragging and target:
		target.global_position = target.get_global_mouse_position() + offset


func _input(event: InputEvent) -> void:
	if dragging and event.is_action_pressed("Cancel_drag"):
		_cancel_dragging()
		target.global_position = spawn_area.global_position + offset
		spawn_blue.show()
	elif dragging and event.is_action_released("Select"):
		_drop()


func _end_dragging() -> void:
	dragging = false
	target.remove_from_group("dragging")
	target.z_index = 0
	highlight_blue.hide()
	Input.set_custom_mouse_cursor(null)


func _cancel_dragging() -> void:
	_end_dragging()
	drag_canceled.emit(starting_position)


func _start_dragging() -> void:
	dragging = true
	starting_position = target.global_position
	target.add_to_group("dragging")
	target.z_index = 99
	offset = target.global_position - target.get_global_mouse_position()
	drag_started.emit()
	highlight_blue.show()
	


func _drop() -> void:
	_end_dragging()
	if not _is_within_restriction_area():
		target.global_position = spawn_area.global_position + offset
		spawn_blue.show()
	dropped.emit(starting_position)
	

func _on_target_input_event(_viewport: Node, event: InputEvent) -> void:
	if not enabled:
		return

	var dragging_object := get_tree().get_first_node_in_group("dragging")
	
	if not dragging and dragging_object:
		return
	
	if not dragging and event.is_action_pressed("Select"):
		_start_dragging()


func _apply_visual_feedback(is_out_of_bounds: bool) -> void:
		var modulate_color = out_of_bounds_color if is_out_of_bounds else default_color
		target.modulate = modulate_color
		
func _is_within_restriction_area() -> bool:
	return restriction_area.overlaps_area(target)

func _on_blue_team_area_area_exited(area: Area2D) -> void:
	_apply_visual_feedback(true)

func _on_blue_team_area_area_entered(area: Area2D) -> void:
	_apply_visual_feedback(false)


func _on_spawn_blue_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_hand, 0, Vector2(16, 16))


func _on_spawn_blue_area_exited(area: Area2D) -> void:
		spawn_blue.hide()
	#var area_outline = %CanvasGroup
	#if area_outline.material and area_outline.material is ShaderMaterial:
		#area_outline.material.set_shader_parameter("line_thickness", 0)
