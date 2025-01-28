class_name CardLayout
extends Control

# ============================== Local scene nodes ==============================

@onready var _description_label : RichTextLabel = %Description
@onready var _picture : TextureRect = $Picture
@onready var _card_name : Label = $CardName
@onready var _family_icon : TextureRect = $FamilyIcon
@onready var _lvlcontainer : VBoxContainer = $currentLvlContainer

# ============================== Public functions ==============================

func update_card_layout(card: Card) :
	_description_label.text = card.player_upgrade.get_description(card.lvl)
	_picture.texture = card.picture
	_family_icon.texture = GameManager.get_family_from_type(card.families[0]).icon
	_card_name.text = card.name
	match card.rarity :
		Card.Rarity.COMMON:
			$Rarity/Common.show()
		Card.Rarity.RARE:
			$Rarity/Rare.show()
		Card.Rarity.EPIC:
			$Rarity/Epic.show()
	
	for i in 5:
		var hbox_node = _lvlcontainer.get_node(str(i))
		hbox_node.hide()
	
	for i in card.lvl:
		var hbox_node = _lvlcontainer.get_node(str(i))
		if hbox_node:
			hbox_node.show()
		else:
			print("Node not found:")
