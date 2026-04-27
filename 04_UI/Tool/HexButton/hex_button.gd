class_name HexButton
extends Control

# ============================== Signal ==============================

signal pressed(self_ref: HexButton)
signal button_mouse_entered(self_ref: HexButton)
signal button_mouse_exited(self_ref: HexButton)

# ============================== Enum ==============================

enum HighlightType {
	OUTLINE,
	PLAIN
}

# ============================== Configuration ==============================

@export_group("Shader Configuration")
@export var _make_border_shader_unique: bool = true
@export var _make_plain_shader_unique: bool = true

@export_group("Misc Configuration")
@export var _hover_color: Color

# ============================== Public variable ==============================

var tooltip_attached: Tooltip

# ============================== Local Nodes ==============================

@onready var _border: TextureRect = %Border
@onready var _background: TextureRect = %Background
@onready var _hover_texture: TextureRect = %HoverTexture
@onready var _button: TextureButton = %TextureButton

# ============================== Node base functions ==============================

func _ready() -> void:
	if _make_border_shader_unique:
		_border.material = _border.material.duplicate(true)
	if _make_plain_shader_unique:
		_background.material = _background.material.duplicate(true)

# ============================== Public functions ==============================

func activate() -> void:
	_button.disabled = false


func deactivate() -> void:
	_button.disabled = true


func set_hover_mode(is_activated: bool, color: Color = Color.TRANSPARENT) -> void:
	if color != Color.TRANSPARENT:
		_hover_color = color
		_hover_texture.modulate = _hover_color
	if is_activated:
		_hover_texture.show()
	else:
		_hover_texture.hide()


func set_highlight(highlight_type: HighlightType, is_highlight_activated: bool = true) -> void:
		match highlight_type:
			HighlightType.OUTLINE:
				if is_highlight_activated:
					_activate_outline_highlight()
				else:
					_deactivate_outline_highlight()
			HighlightType.PLAIN:
				if is_highlight_activated:
					_activate_plain_highlight()
				else:
					_deactivate_plain_highlight()


func set_texture(background_texture: CompressedTexture2D) -> void:
	_background.texture = background_texture


func set_outline_color(color: Color) -> void:
	_border.modulate = color

# ============================== Configuration ==============================

func _activate_outline_highlight() -> void:
	_border.material.set_shader_parameter("start_time", 0.0)
	_border.material.set_shader_parameter("effect_enabled", true)


func _deactivate_outline_highlight() -> void:
	_border.material.set_shader_parameter("effect_enabled", false)


func _activate_plain_highlight() -> void:
	_background.material.set_shader_parameter("enable_blink", true)
	_background.material.set_shader_parameter("enable_shine", true)


func _deactivate_plain_highlight() -> void:
	_background.material.set_shader_parameter("enable_blink", false)
	_background.material.set_shader_parameter("enable_shine", false)


func _on_texture_button_pressed() -> void:
	pressed.emit(self)


func _on_texture_button_mouse_entered() -> void:
	button_mouse_entered.emit(self)


func _on_texture_button_mouse_exited() -> void:
	button_mouse_exited.emit(self)
