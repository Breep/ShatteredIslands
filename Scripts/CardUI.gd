extends Control
class_name CardUI

@onready var descriptionLabel : Label = $Card/Description
@onready var image : TextureRect = $Card/Image
@onready var title : RichTextLabel = $Card/Title
@onready var type : TextureRect = $Card/Type
@onready var level : Label = $Card/Level
@onready var rarity : Control = $Card/Rarity
@onready var lvlcontainer : VBoxContainer = $Card/Control/lvlcontainer


func _ready() -> void:
	pass
	
	
func update_visual_card(card: Card) :
	descriptionLabel.text = card.description
	image.texture = card.image
	type.texture = card.famille
	title.text = card.name
	level.text = str(card.lvl) + "/5"
	match card.rarity :
		Card.Rarity.COMMON:
			print("Carte Commune")
			$Card/Rarity/Common.show()
		Card.Rarity.RARE:
			print("Carte Rare")
			$Card/Rarity/Rare.show()
		Card.Rarity.EPIC:
			print("Carte Epic")
			$Card/Rarity/Epic.show()
	for i in card.lvl:
		var hbox_node = lvlcontainer.get_node(str(i))
		if hbox_node:
			hbox_node.show()
		else:
			print("Node not found:")
