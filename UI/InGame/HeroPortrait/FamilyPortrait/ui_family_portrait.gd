class_name UIFamilyPortrait
extends Control

# ============================== Signal ==============================

signal selected(self_ref: UIFamilyPortrait)
signal unselected(self_ref: UIFamilyPortrait)

# ============================== Constants ==============================

const FAMILY_LEVEL_MAP_PROGRESS_BAR_VALUE: Array[float] =[0, 30, 50, 70, 100]

# ============================== Local nodes ==============================

@onready var _family_icon: TextureRect = %FamilyIcon
@onready var _family_lvl_progress_bar: TextureProgressBar = %FamilyLvlProgressBar
@onready var _current_xp_progress_bar: TextureProgressBar = %XPProgressBar
@onready var _button: TextureButton = %TextureButton
@onready var _glow_effet: TextureRect = %GlowEffect
@onready var _family_background: TextureRect = %FamilyBackground

# ============================== Public variables ==============================

var family_type: Family.Type

var _family_xp: int = 0
var family_xp: int:
	get: return _family_xp
	set(value):
		if value == _family_xp: return
		_family_xp = value
		_current_xp_progress_bar.value = _family_xp

var _family_xp_max: int = 0
var family_xp_max: int:
	get: return _family_xp_max
	set(value):
		if value == _family_xp_max: return
		_family_xp_max = value
		_current_xp_progress_bar.max_value = _family_xp_max

var _family_lvl: int = 0
var family_lvl: int:
	get: return _family_lvl
	set(value):
		if value == _family_lvl: return
		_family_lvl = value
		_family_lvl_progress_bar.value = FAMILY_LEVEL_MAP_PROGRESS_BAR_VALUE[_family_lvl]


# ============================== Private variables ==============================

var _family: Family

# ============================== Node base functions ==============================

func _ready() -> void:
	if _glow_effet.material != null:
		_glow_effet.material = _glow_effet.material.duplicate()

# ============================== Public functions ==============================

func init(family: Family) -> void:
	family_type = family.family_type
	_family_background.modulate = family.color
	_glow_effet.material.set_shader_parameter("glow_color", family.color)
	_family_icon.texture = family.icon
	_family = family


func unselect() -> void:
	_button.set_pressed_no_signal(false)

# ============================== Private functions ==============================

func _on_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		selected.emit(self)
	else:
		unselected.emit(self)
