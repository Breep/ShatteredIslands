extends Control

@export var _family: Family
@export var _hero_id: HeroDesc.HeroId = HeroDesc.HeroId.MAGE

@onready var _ui_family_viewer: UIFamilyViewer = $UiFamilyViewer
@onready var _add_random_card_button: Button = $Button
@onready var _desc_panel: ArdentCelestialDescPanel = $UiFamilyViewer/HBoxContainer/ArdentCelestialDescPanel

var _player: Player
var _hero: Hero
var _next_uid: int = 0


func _ready() -> void:
	GameManager.init()

	_player = Player.new()
	_player.name = "PrototypingPlayer"
	add_child(_player)
	_player.init_player()
	
	_build_hero()
	
	_player.hero = _hero
	_hero.player = _player
	
	for card: Card in _family.cards:
		card.lvl = 1
	
	_add_random_card_button.pressed.connect(_on_add_random_card_button_pressed)
	_player.deck.has_changed.connect(_on_player_deck_has_changed)
	_ui_family_viewer.display_family(_player, _family)


func _build_hero() -> void:
	if _hero != null:
		_hero.queue_free()
		_hero = null

	_hero = Shared.HERO_SCENES[_hero_id].instantiate() as Hero
	_hero.hero_desc = Shared.HEROES[_hero_id]
	_hero._custom_deck = _player.deck
	_hero.visible = false
	_hero._health_bar.hide()
	add_child(_hero)

	# Attendre que _ready() du Hero ait fini (cards appliquées, family managers initialisés)
	await _hero.ready
	_desc_panel.set_hero(_hero)


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


func _on_player_deck_has_changed() -> void:
	_desc_panel.set_hero(_hero)
