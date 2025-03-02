extends Control

@onready var _vbox :HBoxContainer = %VBoxContainer

func _ready() -> void:
	var families_node = _vbox.get_children()
	for family_node in families_node:
		family_node.hide()
		
	var _portrait_family = get_tree().get_root().find_child("PortraitFamily", true, false)
	if _portrait_family == null:
		printerr("Pas de portraitfamily")
		return
	_portrait_family.connect("first_family_card_bought", _on_portrait_family_first_family_card_bought)
	
	
	
func _on_portrait_family_first_family_card_bought(family) -> void:
	var node = _vbox.get_node_or_null(family)
	if node:
		node.show()
	else:
		printerr("No node found for Family")
