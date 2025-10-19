class_name UIBuyingArea
extends Control

# ============================== Local nodes ==============================

@onready var _ui_card_shop: UICardShop = %CardShop
@onready var _ui_local_player_hero_portrait: UIHeroPortrait = %LocalPlayerHeroPortrait

# ============================== Private variables ==============================

var _is_active: bool

# ============================== Local nodes functions ==============================

func _ready() -> void:
	Events.entity_cliked.connect(_on_events_entity_clicked)
	Events.furniture_clicked.connect(_on_events_furniture_clicked)
	Events.nothing_clicked.connect(_on_events_nothing_clicked)
	#RoundManager.current_round_changed.connect(_on_round_manager_current_round_changed)
	#if GameManager.game_type != GameManager.GameType.SOLO and not multiplayer.is_server():
		#_ui_player_info.connect_to_player(PlayerManager.get_local_player())
	#elif GameManager.game_type == GameManager.GameType.SOLO:
		#_ui_player_info.connect_to_player(PlayerManager.get_local_player())

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
	pass


func _on_events_furniture_clicked(furniture: Furniture) -> void:
	if GameManager.game_type != GameManager.GameType.SOLO and multiplayer.is_server():
		return
	
	_ui_card_shop.set_inactive()
	match furniture.furniture_type:
		Furniture.FurnitureType.CARD_SHOP:
			_ui_card_shop.set_active()


func _on_events_nothing_clicked() -> void:
	pass
