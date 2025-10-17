class_name Tooltip
extends Control

# ============================== Signal ==============================

signal queue_freed(tooltip: Tooltip)
signal focused(tooltip: Tooltip)
signal unfocused(tooltip: Tooltip)

# ============================== Public variable ==============================

var parent_tooltip: Tooltip

# ============================== Private variables ==============================

var _child_tooltip : Tooltip
var _tween: Tween 
var _mouse_on_self: bool = false

# ============================== Local Nodes ==============================

@onready var _free_timer : Timer = %FreeTimer
@onready var _tooltip_name: RichTextLabel= %NameLabel
@onready var _tooltip_description : RichTextLabel = %DescriptionLabel
@onready var _progress_bar : TextureProgressBar = %Loading
@onready var _tooltip_icon: TextureRect = %Icon

# ============================== Public functions ==============================

func init(tooltip_name: String, icon: Texture, description: String) -> void:
	_tooltip_description.text = description
	_tooltip_name.text = tooltip_name
	_tooltip_icon.texture = icon
	_init_position()


func delete() -> void:
	queue_freed.emit(self)
	queue_free()


func force_recursive_child_delete(delete_self: bool) -> void:
	if _child_tooltip != null:
		_child_tooltip.force_recursive_child_delete(true)
	if delete_self:
		delete()


func start_recursive_parent_free() -> void:
	if _mouse_on_self:
		return
	start_self_free()


func start_self_free():
	if _tween != null:
		_tween.kill()
	_free_timer.start()
	_tween = create_tween()
	_tween.tween_property(_progress_bar, "value", 0, _free_timer.wait_time)


# ============================== Privates functions ==============================

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


func _stop_self_free():
	if _tween != null:
		_tween.kill()
	_free_timer.stop()
	_tween = create_tween()
	_tween.tween_property(_progress_bar, "value", 100, 0.1)

# ============================== Callbacks ==============================

func _on_tooltip_queue_freed():
	_child_tooltip = null


func _on_free_timer_timeout() -> void:
	if parent_tooltip != null:
		parent_tooltip.start_recursive_parent_free()
	delete()


func _on_description_label_meta_hover_started(meta: Variant) -> void:
	if _child_tooltip != null:
		return
	_child_tooltip = TooltipManager.create_tooltip(meta)
	if _child_tooltip == null:
		return
	_child_tooltip.connect("queue_freed", _on_tooltip_queue_freed)
	_child_tooltip.parent_tooltip = self


func _on_description_label_meta_hover_ended(_meta: Variant) -> void:
	if _child_tooltip != null:
		_child_tooltip.start_recursive_parent_free()


func _on_mouse_exited() -> void:
	unfocused.emit(self)
	_mouse_on_self = false
	if _child_tooltip == null:
		start_recursive_parent_free()


func _on_panel_mouse_entered() -> void:
	_stop_self_free()
	focused.emit(self)
	_mouse_on_self = true
