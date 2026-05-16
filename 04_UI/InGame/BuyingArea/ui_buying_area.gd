class_name UIBuyingArea
extends Control

# ============================== Local nodes ==============================

@onready var _ui_card_shop: UICardShop = %CardShop

# ============================== Private variables ==============================

var _is_active: bool

# ============================== Local nodes functions ==============================

func _ready() -> void:
	Events.entity_clicked.connect(_on_events_entity_clicked)
	Events.furniture_clicked.connect(_on_events_furniture_clicked)
	Events.nothing_clicked.connect(_on_events_nothing_clicked)


# ============================== Public functions ==============================

func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()

# ============================== Callbacks ==============================

func _on_events_entity_clicked(_entity: Entity) -> void:
	if not _entity is Hero: return
	var hero: Hero = _entity

	# Find player matching this hero
	var matching_player: Player = null
	for player in PlayerManager.players.values():
		if player.hero == hero:
			matching_player = player
			break

func _on_events_furniture_clicked(furniture: Furniture) -> void:
	if GameManager.game_type != GameManager.GameType.SOLO and multiplayer.is_server():
		return
	
	_ui_card_shop.set_inactive()
	match furniture.furniture_type:
		Furniture.FurnitureType.CARD_SHOP:
			_ui_card_shop.set_active()


func _on_events_nothing_clicked() -> void:
	pass


func _on_continue_button_pressed() -> void:
	Events.signal_tavern_continue_pressed()
