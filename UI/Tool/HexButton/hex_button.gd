class_name HexButton
extends TextureButton

# ============================== Configuration ==============================

@export_group("Shader Configuration")
@export var _make_border_shader_unique: bool = true

# ============================== Local Nodes ==============================

@onready var _border: TextureRect = %Border

# ============================== Node base functions ==============================

func _ready() -> void:
	if _make_border_shader_unique:
		_border.material = _border.material.duplicate(true)

# ============================== Public functions ==============================

func set_highlight(is_highlight_activated: bool = false) -> void:
	if is_highlight_activated:
		_activate_outline_highlight()

# ============================== Configuration ==============================

func _activate_outline_highlight() -> void:
	var now := float(Time.get_ticks_msec()) / 1000.0
	_border.material.set_shader_parameter("start_time", now - 1.0)
	_border.material.set_shader_parameter("effect_enabled", true)


func desactivate_outline_highlight() -> void:
	_border.material.set_shader_parameter("effect_enabled", false)
