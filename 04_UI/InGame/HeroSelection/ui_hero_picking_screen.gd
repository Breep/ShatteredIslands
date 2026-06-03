class_name UIHeroPickingScreen
extends Control

# Hero selection screen controller: receives the available heroes via setup(),
# fills the portrait grid, drives the overview panel on selection, and exposes
# selection/lock events to whoever owns the screen (HeroSelector).

# ============================== Signals ==============================

signal hero_selected(hero: HeroDesc)
signal hero_locked(hero: HeroDesc)

# ============================== Constants ==============================

const _PORTRAIT_BUTTON: PackedScene = preload("res://04_UI/InGame/HeroSelection/ui_hero_portrait_button.tscn")

# ============================== Local nodes ==============================

@onready var _hero_grid: GridContainer = %HeroGridContainer
@onready var _overview_panel: UIHeroOverviewPanel = %UiHeroOverviewPanel

# ============================== Private vars ==============================

var _selected_hero: HeroDesc

# ============================== Public functions ==============================

func setup(heroes: Array[HeroDesc]) -> void:
	_clear_grid()
	for hero in heroes:
		var button := _PORTRAIT_BUTTON.instantiate() as UIHeroPortraitButton
		_hero_grid.add_child(button)
		button.hero = hero
		button.selected.connect(_on_portrait_button_selected)
	if not heroes.is_empty():
		_select(heroes[0])


# ============================== Private functions ==============================

func _clear_grid() -> void:
	for child in _hero_grid.get_children():
		child.queue_free()


func _select(hero: HeroDesc) -> void:
	if hero == _selected_hero:
		return
	_selected_hero = hero
	_overview_panel.update(hero)
	hero_selected.emit(hero)


# ============================== Callbacks ==============================

func _on_portrait_button_selected(hero: HeroDesc) -> void:
	_select(hero)


func _on_lock_hero_button_pressed() -> void:
	if _selected_hero == null:
		return
	hero_locked.emit(_selected_hero)
