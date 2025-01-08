extends Control

var card : Card
@onready var cardTextureRect : TextureRect = $Card/Card
@onready var descriptionLabel : Label = $Card/Card/Description
@onready var image : TextureRect = $Card/Card/Image
@onready var title : RichTextLabel = $Card/Card/Title
@onready var type : TextureRect = $Card/Card/Type
@onready var level : Label = $Card/Card/Level
@onready var rarity : Control = $Card/Card/Rarity
@onready var lvlcontainer : VBoxContainer = $Card/Card/Control/lvlcontainer


func _ready() -> void:
	card = load("res://Resources/Card/Attack/AttackDamage.tres")
	update_visual_card()
	
	
func update_visual_card() :
	descriptionLabel.text = card.description
	image.texture = card.image
	type.texture = card.famille
	title.text = card.name
	level.text = str(card.lvl) + "/5"
	match card.rarity :
		Card.Rarity.COMMON:
			print("Carte Commune")
			$Card/Card/Rarity/Common.show()
		Card.Rarity.RARE:
			print("Carte Rare")
			$Card/Card/Rarity/Rare.show()
		Card.Rarity.EPIC:
			print("Carte Epic")
			$Card/Card/Rarity/Epic.show()
	for i in card.lvl:
		var hbox_node = lvlcontainer.get_node(str(i))
		if hbox_node:
			hbox_node.show()
		else:
			print("Node not found:")
		
