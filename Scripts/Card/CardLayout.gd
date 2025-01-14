extends Control
class_name CardLayout

# ============================== Local scene nodes ==============================

@onready var _descriptionLabel : Label = $Description
@onready var _picture : TextureRect = $Picture
@onready var _cardName : Label = $CardName
@onready var _familyIcon : TextureRect = $FamilyIcon
@onready var _rarity : Control = $Rarity
@onready var _lvlcontainer : VBoxContainer = $currentLvlContainer

# ============================== Public functions ==============================

func updateCardLayout(card: Card) :
	_descriptionLabel.text = card.playerUpgrade.get_description(card.lvl)
	_picture.texture = card.picture
	_familyIcon.texture = card.families[0].icon
	_cardName.text = card.name
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

# ============================== Private functions ==============================
