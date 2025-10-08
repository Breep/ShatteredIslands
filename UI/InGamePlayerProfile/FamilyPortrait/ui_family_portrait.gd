class_name UIFamilyPortrait
extends Control

# ============================== Local nodes ==============================


@onready var _family_icon: TextureRect = %FamilyIcon
@onready var _background: TextureRect = %Background
@onready var _family_lvl_progress_bar: TextureProgressBar = %FamilyLvlProgressBar
@onready var _current_xp_progress_bar: TextureProgressBar = %CurrentXPProgressBar

# ============================== Public variables ==============================

var family_type: Family.FamilyType

var _family_count: int = 0
var family_count: int:
	get: return _family_count
	set(value):
		if value == _family_count: return
		_family_count = value
		_update_visual()

# ============================== Node base functions ==============================

func _ready() -> void:
	_update_visual()

# ============================== Public functions ==============================

func init(family: Family) -> void:
	family_type = family.family_type
	_family_icon.texture = family.icon
	_background.modulate = family.color

# ============================== Private functions ==============================

func _update_visual() -> void:
	_family_lvl_progress_bar.value = round(_family_count / 8)
	_current_xp_progress_bar.value = _family_count % 8
