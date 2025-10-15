class_name UIInGameFamilyViewer
extends Control

@export_group("Local Nodes")
@export var _family_name_label: Label
@export var _family_description_label: Label
@export var _ui_cards_viewer: UICardsViewer

func update_content(player: Player, family: Family) -> void:
	_family_name_label.text = family.family_name
	_family_description_label.text = family.description
	var cards: Array[Card] = player.deck.get_cards_by_type(family.family_type)
	_ui_cards_viewer.update_content(cards)
	_ui_cards_viewer.reset_scroll()
