@tool

class_name UICardsViewer
extends Control

var _mirrored: bool
@export var mirrored: bool:
	get: return _mirrored
	set(value):
		_mirrored = value
		_mirror_ui()

@onready var _grid_container: GridContainer = %GridContainer
@onready var _scroll_container: ScrollContainer = %ScrollContainer
@onready var _main_texture_rect: TextureRect = %MainTextureRect

const CARD_BUTTON_SCENE: PackedScene = preload("res://Card/2D/CardButton/card_button.tscn")

func _ready() -> void:
	_mirror_ui()


func update_content(cards: Array[Card]) -> void:
	_clear_all()
	for card: Card in cards:
		var card_button: CardButton = CARD_BUTTON_SCENE.instantiate()
		card_button.remove_shader()
		card_button.custom_minimum_size = Vector2(630, 880)
		card_button.update_visual(card)
		_grid_container.add_child(card_button)


func reset_scroll() -> void:
	_scroll_container.scroll_vertical = 0


func _clear_all() -> void:
	for child: CardButton in _grid_container.get_children():
		child.queue_free()


func _mirror_ui() -> void:
	if not is_node_ready(): return
	if _mirrored:
		_main_texture_rect.flip_h = true
	else:
		_main_texture_rect.flip_h = false
