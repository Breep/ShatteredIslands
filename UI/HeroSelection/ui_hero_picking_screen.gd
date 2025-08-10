class_name UIHeroPickingScreen
extends Control

signal hero_locked(hero: Hero)

var _tween: Tween

var _ui_hero_portrait_button: PackedScene = preload("res://UI/HeroSelection/ui_hero_portrait_button.tscn")

@onready var _ui_countdown: UICountdown = %Countdown
@onready var _player_turn_label: Label = %PlayerTurnLabel

@onready var _grid_container: GridContainer = %GridContainer
@onready var _lock_hero_button: Button = %LockHeroButton

var _selected_hero: Hero

func _ready() -> void:
	#hide()
	for child in _grid_container.get_children():
		child.queue_free()
	_lock_hero_button.disabled = true


func make_hero_unavailable(hero: Hero) -> void:
	for child in _grid_container.get_children():
		var hero_portrait_button: HeroPortraitButton = child
		if hero_portrait_button.hero == hero:
			hero_portrait_button.disable()
			return


func open_hero_selection() -> void:
	_lock_hero_button.disabled = false


func update_heroes(heroes: Array[Hero]) -> void:
	for hero in heroes:
		var hero_portrait = _ui_hero_portrait_button.instantiate()
		hero_portrait.init_hero(hero)
		hero_portrait.selected.connect(_on_hero_portrait_selected)
		_grid_container.add_child(hero_portrait)


func update_bottom_message(player_name: String, is_local: bool) -> void:
	if is_local:
		_player_turn_label.text = "Your turn to pick !"
		_blink_player_turn_label()
	else:
		_player_turn_label.text = player_name + "'s turn to pick"
		if _tween:
			_tween.kill()
	_ui_countdown.start(10, "")


func _blink_player_turn_label() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_loops()
	_tween.tween_property(_player_turn_label, "modulate", Color.BLACK, 0.5)
	_tween.tween_property(_player_turn_label, "modulate", Color.CRIMSON, 0.5)


func _on_hero_portrait_selected(hero: Hero) ->void:
	_selected_hero = hero
	%Label.text = hero.name # TMP


func _on_lock_hero_button_pressed() -> void:
	for child in _grid_container.get_children():
		var hero_portrait_button: HeroPortraitButton = child
		if hero_portrait_button.hero == _selected_hero && hero_portrait_button.disabled:
			return
	_lock_hero_button.disabled = true
	hero_locked.emit(_selected_hero)




















 
