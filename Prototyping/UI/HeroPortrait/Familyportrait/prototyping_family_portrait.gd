extends Control

@export var _ui_all_families_portrait: UIAllFamiliesPortrait
@export var _hide_show_button: Button

@export var _families: Array[Family]

var _is_families_portrait_hidden: bool = false

@onready var _rng := RandomNumberGenerator.new()
@onready var _player := Player.new()

func _ready() -> void:
	_rng.randomize()
	if _is_families_portrait_hidden:
		_ui_all_families_portrait.hide_families()
	else:
		_ui_all_families_portrait.show_families()
	_ui_all_families_portrait.init_portait_families(_families)
	
	_player.deck = PlayerDeck.new()
	for family: Family in _families:
		_player.deck._families_count[family.family_type] = 0
	
	_ui_all_families_portrait.player = _player

func _on_hide_show_button_pressed() -> void:
	if _is_families_portrait_hidden:
		_hide_show_button.text = "Hide"
		_is_families_portrait_hidden = false
		_ui_all_families_portrait.show_families()
	else:
		_hide_show_button.text = "Show"
		_is_families_portrait_hidden = true
		_ui_all_families_portrait.hide_families()


func _on_add_random_card_button_pressed() -> void:
	var randi: int = _rng.randi_range(0, _families.size() - 1)
	var rand_family: Family = _families[randi]
	_player.deck._families_count[rand_family.family_type] += 1
	_player.deck.has_changed.emit()
