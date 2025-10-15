class_name HexButton
extends TextureButton

# ============================== Enum ==============================

enum HighlightType {
	OUTLINE,
	PLAIN
}

# ============================== Configuration ==============================

@export_group("Shader Configuration")
@export var _make_border_shader_unique: bool = true
@export var _make_plain_shader_unique: bool = true

# ============================== Local Nodes ==============================

@onready var _border: TextureRect = %Border
@onready var _background: TextureRect = %Background

# ============================== Node base functions ==============================

func _ready() -> void:
	if _make_border_shader_unique:
		_border.material = _border.material.duplicate(true)
	if _make_plain_shader_unique:
		_background.material = _background.material.duplicate(true)

# ============================== Public functions ==============================

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
	print("DEBUG  SHOULD ACTIVTE OUTLINE HIGHLIGHT")
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
