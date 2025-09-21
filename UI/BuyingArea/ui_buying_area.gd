class_name UIBuyingArea
extends Control

@export_group("External nodes")
@export var _round_timer: Timer

@export_group("Middle Panels")
@export var _ui_card_shop: UICardShop
@export var _ui_oracle: UIOracle

# ============================== Local nodes ==============================

@onready var _continous_timer: UIContinousTimer = %ContinousTimer
@onready var _ui_selected_entity_stats: UICharacterStats = %SelectedCharacterStats
@onready var _round_label: Label = %RoundLabel
@onready var _ui_player_info: UIPlayerInfo = %UIPlayerInfo

# ============================== Private variables ==============================

var _is_active: bool

# ============================== Local nodes functions ==============================

func _ready() -> void:
	Events.entity_cliked.connect(_on_events_entity_clicked)
	Events.furniture_clicked.connect(_on_events_furniture_clicked)
	RoundManager.current_round_changed.connect(_on_round_manager_current_round_changed)
	_continous_timer.connect_timer(_round_timer)
	if GameManager.game_type != GameManager.GameType.SOLO and not multiplayer.is_server():
		_ui_player_info.connect_to_player(PlayerManager.get_local_player())
	elif GameManager.game_type == GameManager.GameType.SOLO:
		_ui_player_info.connect_to_player(PlayerManager.get_local_player())

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

func _on_events_entity_clicked(entity: Entity) -> void:
	_ui_selected_entity_stats.connect_entity_stats(entity)


func _on_events_furniture_clicked(furniture: Furniture) -> void:
	if GameManager.game_type != GameManager.GameType.SOLO and multiplayer.is_server():
		return
	
	_ui_card_shop.set_inactive()
	_ui_oracle.set_inactive()
	match furniture.furniture_type:
		Furniture.FurnitureType.CARD_SHOP:
			_ui_card_shop.set_active()
		Furniture.FurnitureType.ORACLE:
			_ui_oracle.set_active()


func _on_round_manager_current_round_changed(round_number: int) -> void:
	_round_label.text = str("ROUND ") + str(round_number)
