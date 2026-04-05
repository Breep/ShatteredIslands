extends Control

@export var _family: Family

@onready var _ui_family_viewer: UIFamilyViewer = $UiFamilyViewer
@onready var _add_random_card_button: Button = $Button

var _player: Player
var _next_uid: int = 0


func _ready() -> void:
	GameManager.init()

	_player = Player.new()
	_player.name = "PrototypingPlayer"
	add_child(_player)
	_player.init_player()

	for card: Card in _family.cards:
		card.lvl = 1

	_add_random_card_button.pressed.connect(_on_add_random_card_button_pressed)
	_ui_family_viewer.display_family(_player, _family)


func _on_add_random_card_button_pressed() -> void:
	var eligible_cards: Array[Card] = []
	for card: Card in _family.cards:
		if not _player.deck.get_card_lvl(card) >= Card.RARITY_MAX_LEVEL[card.rarity]:
			eligible_cards.append(card)

	if eligible_cards.is_empty():
		return

	var random_card: Card = eligible_cards.pick_random()
	var card_copy: Card = random_card.duplicate()
	card_copy.uid = _next_uid
	_next_uid += 1
	_player.deck.add_card(card_copy)
