class_name Tooltip
extends Control

signal queue_freed(tooltip: Tooltip)
signal focused(tooltip: Tooltip)
signal unfocused(tooltip: Tooltip)

var parent_tooltip: Tooltip
var debugg_int = 0 

var _child_tooltip : Tooltip
var _tween: Tween 
var _mouse_on_self: bool = false

@onready var _hide_timer : Timer = %FreeTimer
@onready var _tooltip_name: RichTextLabel= %Name
@onready var _tooltip_description : RichTextLabel = %Description
@onready var _progress_bar : TextureProgressBar = %Loading
@onready var _tooltip_icon: TextureRect = %Icon


func init(tooltip_name: String, icon: Texture, description: String) -> void:
	_tooltip_description.text = description
	_tooltip_name.text = tooltip_name
	_tooltip_icon.texture = icon
	_init_position()
	#_next_tooltip.connect("queue_freed",_on_tooltip_queue_freed)


func delete() -> void:
	queue_freed.emit(self)
	queue_free()


func force_recursive_child_delete(delete_self: bool) -> void:
	if _child_tooltip != null:
		_child_tooltip.force_recursive_child_delete(true)
	if delete_self:
		delete()

func start_recursive_parent_free() -> void:
	print(debugg_int , "start_recursive_parent_free()")
	if _mouse_on_self:
		print(debugg_int , "mouse-self")
		return
	start_self_free()


func _init_position() -> void:
	var mouse_position = get_viewport().get_mouse_position()
	position = _calculate_tooltip_position(mouse_position)


func _calculate_tooltip_position(mouse_position) -> Vector2:
	var screen_width = get_viewport().size.x
	var screen_height = get_viewport().size.y
	var tooltip_size = Vector2(450, 120)  
	var offset = Vector2(10, 10)
	var tooltip_position = mouse_position + offset
	
	if mouse_position.x > screen_width / 2:
		tooltip_position = mouse_position - Vector2(tooltip_size.x + 10, -10)
	
	if tooltip_position.x + tooltip_size.x > screen_width:
		tooltip_position.x = screen_width - tooltip_size.x - 10
	
	if tooltip_position.y + tooltip_size.y > screen_height:
		tooltip_position.y = screen_height - tooltip_size.y - 10
	
	if tooltip_position.y < 0:
		tooltip_position.y = 10  
	
	return tooltip_position

func _on_tooltip_queue_freed():
	_child_tooltip = null


func start_self_free():
	if _tween != null:
		_tween.kill()
	_hide_timer.start()
	_tween = create_tween()
	_tween.tween_property(_progress_bar, "value", 0, _hide_timer.wait_time)

func _stop_self_free():
	if _tween != null:
		_tween.kill()
	_hide_timer.stop()
	_tween = create_tween()
	_tween.tween_property(_progress_bar, "value", 100, 0.1)


func _on_free_timer_timeout() -> void:
	#print("free_timer_timeout", debugg_int)
	if parent_tooltip != null:
		parent_tooltip.start_recursive_parent_free()
	delete()


func _on_description_meta_hover_started(meta: Variant) -> void:
	if _child_tooltip != null:
		return
	_child_tooltip = TooltipManager.create_tooltip(meta)
	_child_tooltip.connect("queue_freed", _on_tooltip_queue_freed)
	_child_tooltip.parent_tooltip = self
	#print("meta_started", debugg_int)


func _on_mouse_exited() -> void:
	unfocused.emit(self)
	_mouse_on_self = false
	#print("mouse_exited", debugg_int)
	if _child_tooltip == null:
		start_recursive_parent_free()


func _on_panel_mouse_entered() -> void:
	var debugg_string : String = ""
	if parent_tooltip != null:
		debugg_string += str(parent_tooltip.debugg_int) + " "
	debugg_string += str(debugg_int) + " "
	if _child_tooltip != null:
		debugg_string += str(_child_tooltip.debugg_int)
	print(debugg_string)
	_stop_self_free()
	focused.emit(self)
	_mouse_on_self = true


func _on_description_meta_hover_ended(_meta: Variant) -> void:
	if _child_tooltip != null:
		_child_tooltip.start_recursive_parent_free()
