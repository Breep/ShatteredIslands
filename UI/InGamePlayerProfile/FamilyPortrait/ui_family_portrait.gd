class_name UIFamilyPortrait
extends Control

# ============================== Local nodes ==============================

var _family: Family

@onready var _family_icon: TextureRect = %FamilyIcon
@onready var _background: TextureRect = %Background

# ============================== Private variables ==============================

var _family_count: int
var family_count: int:
	get: return _family_count
	set(value):
		if value == _family_count: return
		_family_count = value

# ============================== Node base functions ==============================

func _ready() -> void:
	pass

# ============================== Public functions ==============================

func init(family: Family) -> void:
	_family = family
	_family_icon.texture = family.icon
	_background.modulate = family.color
