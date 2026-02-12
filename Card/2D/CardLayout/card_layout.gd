class_name CardLayout
extends Control

# ============================== Local scene nodes ==============================
@export_group("Levels")
@export var _level_icons: Array[TextureRect]

@export_group("Families")
@onready var _family_icon: TextureRect = %FamilyIcon

@onready var _card_name_label: Label = $%CardNameLabel
@onready var _card_desc_label: SmartTextLabel = %CardDescSmartTextLabel
@onready var _card_portrait_texture: TextureRect = %CardPortraitTextureRect

# ============================== Private variables ==============================

const LEVEL_COLOR := Color.GOLDENROD

var _card: Card

# ============================== Public functions ==============================

func update_content(card: Card) -> void:
	_card = card
	if is_node_ready():
		_update_card_layout(card)
	else:
		_update_card_layout.call_deferred(card)

# ============================== Private functions ==============================

func _update_card_layout(card: Card) -> void:
	Verbose.trace("_update_card_layout() | " + card.name, Verbose.Category.CARD_LAYOUT)
	if card == null:
		Verbose.error("Trying to update a <null> card", Verbose.Category.CARD_LAYOUT)
		return
	_card_name_label.text = card.name
	_card_desc_label.text_raw = card.player_upgrade.get_description(card.lvl)
	_card_portrait_texture.texture = card.picture
	
	
	_family_icon.texture = Shared.FAMILIES[card.families[0]].icon
	
	for i in 5:
		_level_icons[i].hide()
		#_level_background[i].modulate = Color.WHITE
	
	for i in card.lvl:
		_level_icons[i].show()
		#_level_background[i].modulate = LEVEL_COLOR
