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

func _ready() -> void:
	Events.entity_cliked.connect(_on_events_entity_clicked)
	Events.furniture_clicked.connect(_on_events_furniture_clicked)
	RoundManager.current_round_changed.connect(_on_round_manager_current_round_changed)
	_continous_timer.connect_timer(_round_timer)
	if GameManager.game_type != GameManager.GameType.SOLO and not multiplayer.is_server():
		_ui_player_info.connect_to_player(PlayerManager.get_local_player())
	
	#_ui_card_shop.hide()
	#_ui_oracle.hide()


func _on_events_entity_clicked(entity: Entity) -> void:
	if entity is Character:
		var character: Character = entity
		_ui_selected_entity_stats.connect_entity_stats(entity.stats, character.player.name)
	else:
		_ui_selected_entity_stats.connect_entity_stats(entity.stats, entity.name)


func _on_events_furniture_clicked(furniture: Furniture) -> void:
	if GameManager.game_type != GameManager.GameType.SOLO and multiplayer.is_server():
		return
	
	_ui_card_shop.hide()
	_ui_oracle.hide()
	match furniture.furniture_type:
		Furniture.FurnitureType.CARD_SHOP:
			_ui_card_shop.show()
		Furniture.FurnitureType.ORACLE:
			_ui_oracle.show()


func _on_round_manager_current_round_changed(round_number: int) -> void:
	_round_label.text = str("ROUND ") + str(round_number)











 


func _on_card_shop_mouse_entered() -> void:
	print("CARD SHOP MOUSE ENTERED")


func _on_ui_oracle_mouse_entered() -> void:
	print("ORACLE MOUSE ENTERED")


func _on_v_box_container_mouse_entered() -> void:
	print("VBOX MOUSE ENTERED")


func _on_top_panel_mouse_entered() -> void:
	print("TOP PANEL MOUSE ENTERED")


func _on_middle_panel_mouse_entered() -> void:
	print("MIDDLE PANEL MOUSE ENTERED")


func _on_bottom_panel_mouse_entered() -> void:
	print("BOTTOM PANEL MOUSE ENTERED")
