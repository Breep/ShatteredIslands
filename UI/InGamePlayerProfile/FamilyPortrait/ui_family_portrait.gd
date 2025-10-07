class_name UIFamilyPortrait
extends Control

# ============================== Local nodes ==============================

@export_group("Local Nodes")
@export var _family_name_label: Label
@export var _icon: TextureRect
@export var _family_cards_number_label: Label

# ============================== Private variables ==============================

var _family_type: Family.FamilyType
var family_type: Family.FamilyType:
	get: return _family_type
	set(value):
		if value == _family_type: return
		_family_type = value
		_update_family_portrait()

var _family_count: int
var family_count: int:
	get: return _family_count
	set(value):
		if value == _family_count: return
		_family_count = value
		_family_cards_number_label.text = str(_family_count)

# ============================== Node base functions ==============================

func _ready() -> void:
	pass

# ============================== Private functions ==============================

func _update_family_portrait() -> void:
	var family: Family = Shared.FAMILIES[_family_type]
	_family_name_label.text = family.family_name
	_icon.texture = family.icon
	_family_cards_number_label.text = "0"
