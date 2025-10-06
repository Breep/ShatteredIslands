class_name UILevelContainer
extends TextureRect

signal activated(self_ref: UILevelContainer)

const SKILL_PORTRAIT_BLINK_FREQUENCY: float = 5.0

@export var level: int = 0

@onready var _outline_metal: TextureRect = %OutlineMetal
@onready var _inside_metal: TextureProgressBar = %InsideMetalProgressBar
@onready var _button: TextureButton = %TextureButton

var _is_activated: bool = false

func _ready() -> void:
	_reset()


func blink() -> void:
	(material as ShaderMaterial).set_shader_parameter("frequency", SKILL_PORTRAIT_BLINK_FREQUENCY)

func unlock() -> void:
	_inside_metal.value = 0
	_button.mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND
	_button.disabled = false


func set_xp_value(current_value: int, max_value: int) -> void:
	_inside_metal.max_value = max_value
	_inside_metal.value = max_value - current_value


func desactivate() -> void:
	_button.button_pressed = false
	_desactivate_outline_highlight()
	_is_activated = false


func _reset() -> void:
	_desactivate_outline_highlight()
	_button.button_pressed = false
	_button.disabled = true
	_inside_metal.max_value = 100.0
	_inside_metal.value = 100.0
	_button.mouse_default_cursor_shape = CursorShape.CURSOR_ARROW


func _activate_outline_highlight() -> void:
	var now := float(Time.get_ticks_msec()) / 1000.0
	_outline_metal.material.set_shader_parameter("start_time", now-1.0)
	_outline_metal.material.set_shader_parameter("effect_enabled", true)


func _desactivate_outline_highlight() -> void:
	_outline_metal.material.set_shader_parameter("effect_enabled", false)


func _on_texture_button_pressed() -> void:
	if _is_activated: return
	_activate_outline_highlight()
	_is_activated = true
	activated.emit(self)
