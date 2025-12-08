class_name CardLayout
extends Control

# ============================== Local scene nodes ==============================
@export_group("Levels")
@export var _level_containers: Array[Control]
@export var _level_background: Array[Control]

@export_group("Families")
@export var _family_icon_containers: Array[Control]
@export var _family_icons: Array[Control]

@onready var _card_name_label: Label = $%CardNameLabel
@onready var _card_desc_label: SmartTextLabel = %CardDescSmartTextLabel
@onready var _card_portrait_texture: TextureRect = %CardPortraitTextureRect
@onready var _bottom_background: TextureRect = %BottomBackground

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
	_family_icons[0].texture = Shared.FAMILIES[card.family].icon
	_bottom_background.modulate = Card.RARITY_COLORS[card.rarity]
	
	for i in 5:
		_level_containers[i].hide()
		_level_background[i].modulate = Color.WHITE
	match card.rarity:
		Card.Rarity.COMMON: for i in 5: _level_containers[i].show()
		Card.Rarity.RARE: for i in 3: _level_containers[i].show()
		Card.Rarity.EPIC: for i in 2: _level_containers[i].show()
		Card.Rarity.LEGENDARY: for i in 1: _level_containers[i].show()
	
	for i in card.lvl:
		_level_background[i].modulate = LEVEL_COLOR
