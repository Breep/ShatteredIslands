class_name CardLayout
extends Control

# ============================== Local scene nodes ==============================
@export_group("Levels")
@export var _level_icons: Array[TextureRect]

@export_group("Families")
@onready var _family_icon: TextureRect = %FamilyIcon
@export var _family_background: ColorRect

@export_group("Level markers")
@export var level1_texture: Texture2D
@export var level2_texture: Texture2D
@export var level3_texture: Texture2D
@export var level4_texture: Texture2D
@export var level5_texture: Texture2D

@onready var _card_name_label: RichTextLabel = $%CardNameLabel
@onready var _card_desc_label: SmartTextLabel = %CardDescSmartTextLabel
@onready var _card_portrait_texture: TextureRect = %CardPortraitTextureRect

@onready var _rune_glow_tools: RuneGlowTools = %Runes
@onready var _locked_overlay: TextureRect = %LockedCardOverlay

# ============================== Private variables ==============================

const LEVEL_COLOR := Color.GOLDENROD

var _card: Card

var _family_background_material: ShaderMaterial
var _base_intensity: float = 1.0
var _glow_hover_tween: Tween

func _ready() -> void:
	#if _family_background == null or _family_background.material == null:
		#Verbose.error("No shader found for family background", Verbose.Category.CARD)
		#return

	if _rune_glow_tools.material != null:
		_rune_glow_tools.material = _rune_glow_tools.material.duplicate()
		_rune_glow_tools.refresh_material()

# ============================== Public functions ==============================

func update_content(card: Card) -> void:
	_card = card
	if is_node_ready():
		_update_card_layout(card)
	else:
		_update_card_layout.call_deferred(card)


func set_locked(locked: bool) -> void:
	if is_node_ready():
		_locked_overlay.visible = locked
	else:
		_set_locked_deferred.call_deferred(locked)


func _set_locked_deferred(locked: bool) -> void:
	_locked_overlay.visible = locked


func mouse_entered() -> void:
	_rune_glow_tools.set_hover(true)


func mouse_exited() -> void:
	_rune_glow_tools.set_hover(false)


# ============================== Private functions ==============================

func _update_card_layout(card: Card) -> void:
	Verbose.trace("_update_card_layout() | " + card.name, Verbose.Category.CARD_LAYOUT)
	if card == null:
		Verbose.error("Trying to update a <null> card", Verbose.Category.CARD_LAYOUT)
		return
	_card_name_label.text = card.name
	_card_desc_label.text_raw = card.player_upgrade.get_description(card.lvl)
	_card_portrait_texture.texture = card.picture
	_rune_glow_tools.set_rarity(card.rarity)

	match card.rarity:
		Card.Rarity.COMMON: _base_intensity = 1.0
		Card.Rarity.RARE: _base_intensity = 2.0
		Card.Rarity.EPIC: _base_intensity = 2.0
		Card.Rarity.LEGENDARY: _base_intensity = 2.0
	_rune_glow_tools.intensity_override = _base_intensity
	_rune_glow_tools.flash_residual(1, 1)
	
	
	_family_icon.texture = Shared.FAMILIES[card.families[0]].icon
	#_update_family_background(card)

	for i in 5:
		_level_icons[i].hide()
	
	for i in card.lvl:
		_level_icons[i].show()
		match card.lvl:
			1: _level_icons[i].texture = level1_texture
			2: _level_icons[i].texture = level2_texture
			3: _level_icons[i].texture = level3_texture
			4: _level_icons[i].texture = level4_texture
			5: _level_icons[i].texture = level5_texture
			_: _level_icons[i].texture = level1_texture


#func _update_family_background(card: Card) -> void:
	#var primary_family: Family = Shared.FAMILIES[card.families[0]]
	#_family_background_material.set_shader_parameter("base_color", primary_family.color)
#
	#if card.families.size() >= 3:
		#_family_background_material.set_shader_parameter("color_count", 3)
		#_family_background_material.set_shader_parameter("override_color2", Shared.FAMILIES[card.families[1]].color)
		#_family_background_material.set_shader_parameter("override_color3", Shared.FAMILIES[card.families[2]].color)
	#elif card.families.size() == 2:
		#_family_background_material.set_shader_parameter("color_count", 2)
		#_family_background_material.set_shader_parameter("override_color2", Shared.FAMILIES[card.families[1]].color)
	#else:
		#_family_background_material.set_shader_parameter("color_count", 1)
