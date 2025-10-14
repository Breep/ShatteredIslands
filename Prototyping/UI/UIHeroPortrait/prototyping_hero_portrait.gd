extends Control

# ============================== Local Nodes ==============================

@export var _ui_hero_portrait: UIHeroPortrait

@export var _families: Array[Family]
@export var _hero: Hero

# ============================== Private variables ==============================

@onready var _rng := RandomNumberGenerator.new()
@onready var _player := Player.new()

# ============================== Node base functions ==============================

func _enter_tree() -> void:
	GameManager.init()


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

# ============================== Callbacks ==============================

func _on_add_random_card_button_pressed() -> void:
	var rand_family_id: int = _rng.randi_range(0, _families.size() - 1)
	var rand_family: Family = _families[rand_family_id]
	_player.deck._families_count[rand_family.family_type] += 1
	_player.deck.has_changed.emit()


func _on_add_victory_button_pressed() -> void:
	_player.battle_history.append(Battle.BattleResolution.WIN)
	_ui_hero_portrait.update_content(_player)


func _on_add_loose_button_pressed() -> void:
	_player.battle_history.append(Battle.BattleResolution.LOOSE)
	_ui_hero_portrait.update_content(_player)


func _on_add_xp_pressed() -> void:
	_player.xp += 4


func _on_add_card_pressed() -> void:
	pass # Replace with function body.
