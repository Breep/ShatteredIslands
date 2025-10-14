class_name CardLayout
extends Control

# ============================== Local scene nodes ==============================

@onready var _description_label : RichTextLabel = %Description
@onready var _picture : TextureRect = $Picture
@onready var _card_name_label : Label = $CardName
@onready var _family_icon : TextureRect = $FamilyIcon
@onready var _lvlcontainer : VBoxContainer = $currentLvlContainer

# ============================== Private variables ==============================

var _card: Card

# ============================== Node base functions ==============================

func _ready() -> void:
	_update_card_layout(_card)

# ============================== Public functions ==============================

func update_content(card: Card) -> void:
	_card = card
	if is_node_ready():
		_update_card_layout(card)

# ============================== Private functions ==============================

func _update_card_layout(card: Card) -> void:
	if card == null:
		return
	_description_label.text = card.player_upgrade.get_description(card.lvl)
	_picture.texture = card.picture
	_family_icon.texture = Shared.FAMILIES[card.family].icon
	_card_name_label.text = card.name
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

func _on_description_meta_hover_started(meta: Variant) -> void:
	TooltipManager.create_tooltip(meta)
