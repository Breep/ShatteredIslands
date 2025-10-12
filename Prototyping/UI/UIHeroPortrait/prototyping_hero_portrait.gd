extends Control

@export var _ui_hero_portrait: UIHeroPortrait
@export var _ui_all_families_portrait: UIAllFamiliesPortrait

@export var _families: Array[Family]
@export var _hero: Hero

@onready var _rng := RandomNumberGenerator.new()
@onready var _player := Player.new()

func _ready() -> void:
	_rng.randomize()
	
	_player.name = "Breep"
	_player.deck = PlayerDeck.new()
	for family: Family in _families:
		_player.deck._families_count[family.family_type] = 0
	_player.hero = _hero
	_player.character = Character.new()
	_player.character.stats = EntityStats.new()
	_player.character.stats.reset_from_hero(_player.hero, 1)
	
	_ui_hero_portrait.update_content(_player)
	#_ui_all_families_portrait.init_portait_families(_families)



func _on_add_random_card_button_pressed() -> void:
	var randi: int = _rng.randi_range(0, _families.size() - 1)
	var rand_family: Family = _families[randi]
	_player.deck._families_count[rand_family.family_type] += 1
	_player.deck.has_changed.emit()
