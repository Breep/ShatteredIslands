class_name UIBuyingArea
extends Control

# ============================== Local nodes ==============================

@onready var _ui_card_shop: UICardShop = %CardShop

@onready var _ui_local_player_hero_portrait: UIHeroPortrait = %LocalPlayerHeroPortrait
@onready var _ui_selected_player_hero_portrait: UIHeroPortrait = %SelectedPlayerHeroPortrait

# ============================== Private variables ==============================

var _is_active: bool

# ============================== Local nodes functions ==============================

func _ready() -> void:
	Events.entity_cliked.connect(_on_events_entity_clicked)
	Events.furniture_clicked.connect(_on_events_furniture_clicked)
	Events.nothing_clicked.connect(_on_events_nothing_clicked)
	_ui_selected_player_hero_portrait.hide()


# ============================== Public functions ==============================

func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()
	if not multiplayer.is_server() or GameManager.game_type == GameManager.GameType.SOLO:
		_ui_local_player_hero_portrait.update_content(PlayerManager.get_local_player())


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()

# ============================== Callbacks ==============================

func _on_events_entity_clicked(_entity: Entity) -> void:
	if not _entity is Character: return
	var character: Character = _entity
	if character.player == PlayerManager.get_local_player(): return
	_ui_selected_player_hero_portrait.show()
	_ui_selected_player_hero_portrait.update_content(character.player)


func _on_events_furniture_clicked(furniture: Furniture) -> void:
	if GameManager.game_type != GameManager.GameType.SOLO and multiplayer.is_server():
		return
	
	_ui_card_shop.set_inactive()
	match furniture.furniture_type:
		Furniture.FurnitureType.CARD_SHOP:
			_ui_card_shop.set_active()


func _on_events_nothing_clicked() -> void:
	_ui_selected_player_hero_portrait.hide()
