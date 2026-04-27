class_name UIHeroPickingScreen
extends Control

signal hero_locked(hero: HeroDesc)

var _tween: Tween

var _ui_hero_portrait_button: PackedScene = preload("res://04_UI/InGame/HeroSelection/ui_hero_portrait_button.tscn")

@onready var _ui_countdown: UICountdown = %Countdown
@onready var _player_turn_label: Label = %PlayerTurnLabel
@onready var _grid_container: GridContainer = %GridContainer
@onready var _lock_hero_button: Button = %LockHeroButton
@onready var _hero_overview_panel: UIHeroOverviewPanel = %UiHeroOverviewPanel

var _selected_hero: HeroDesc

# ============================== Node base functions ==============================

func _ready() -> void:
	for child in _grid_container.get_children():
		child.queue_free()
	_lock_hero_button.disabled = true

# ============================== Public functions ==============================

func make_hero_unavailable(hero: HeroDesc) -> void:
	for child in _grid_container.get_children():
		var hero_portrait_button: UIHeroPortraitButton = child
		if hero_portrait_button.hero == hero:
			hero_portrait_button.disable()
			return


func open_hero_selection() -> void:
	_lock_hero_button.disabled = false


func update_heroes(heroes: Array[HeroDesc]) -> void:
	for hero in heroes:
		var hero_portrait: UIHeroPortraitButton = _ui_hero_portrait_button.instantiate()
		hero_portrait.hero = hero
		hero_portrait.selected.connect(_on_hero_portrait_selected)
		_grid_container.add_child(hero_portrait)


func update_bottom_player_name(player_name: String, is_local: bool) -> void:
	if is_local:
		_player_turn_label.text = "Your turn to pick !"
		_blink_player_turn_label()
	else:
		_player_turn_label.text = player_name + "'s turn to pick"
		if _tween: _tween.kill()


func update_bottom_message(message: String) -> void:
	_player_turn_label.text = message


func update_countdown(value: int) -> void:
	_ui_countdown.start(value, "")

# ============================== Private functions ==============================

func _blink_player_turn_label() -> void:
	if _tween: _tween.kill()
	_tween = create_tween().set_loops()
	_tween.tween_property(_player_turn_label, "modulate", Color.BLACK, 0.5)
	_tween.tween_property(_player_turn_label, "modulate", Color.CRIMSON, 0.5)


# ============================== Callbacks ==============================

func _on_hero_portrait_selected(hero: HeroDesc) ->void:
	_selected_hero = hero
	_hero_overview_panel.display_hero_information(hero)


func _on_lock_hero_button_pressed() -> void:
	if _selected_hero == null:
		printerr("UIHeroPickingScreen: Can't lock hero -> No selected hero")
	for child in _grid_container.get_children():
		var hero_portrait_button: UIHeroPortraitButton = child
		if hero_portrait_button.hero == _selected_hero && hero_portrait_button.disabled:
			return
	hero_locked.emit(_selected_hero)




















 
