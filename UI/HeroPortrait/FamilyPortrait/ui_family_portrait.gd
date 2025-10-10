class_name UIFamilyPortrait
extends Control

# ============================== Signal ==============================

signal selected(self_ref: UIFamilyPortrait)
signal unselected(self_ref: UIFamilyPortrait)

# ============================== Local nodes ==============================

@onready var _family_icon: TextureRect = %FamilyIcon
@onready var _family_lvl_progress_bar: TextureProgressBar = %FamilyLvlProgressBar
@onready var _current_xp_progress_bar: TextureProgressBar = %CurrentXPProgressBar
@onready var _button: TextureButton = %TextureButton

# ============================== Public variables ==============================

var family_type: Family.FamilyType

var _family_count: int = 0
var family_count: int:
	get: return _family_count
	set(value):
		if value == _family_count: return
		_family_count = value
		_update_visual()

# ============================== Private variables ==============================

var _family: Family

# ============================== Node base functions ==============================

func _ready() -> void:
	_update_visual()

# ============================== Public functions ==============================

func init(family: Family) -> void:
	family_type = family.family_type
	_family_icon.texture = family.icon
	_button.modulate = family.color
	_family = family


func unselect() -> void:
	_button.button_pressed = false

# ============================== Private functions ==============================

func _update_visual() -> void:
	_family_lvl_progress_bar.value = round(_family_count / 8)
	_current_xp_progress_bar.value = _family_count % 8


func _on_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		selected.emit(self)
	else:
		unselected.emit(self)
