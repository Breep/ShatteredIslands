class_name UIFamilyViewer
extends Control

const DESC_PANELS: Dictionary = {
	Family.Type.ARDENT_CELESTIAL: preload("res://01_Cards/Pool/Families/ArdentCelestial/ardent_celestial_desc_panel.tscn"),
	Family.Type.CHICKEN_LORD: preload("res://01_Cards/Pool/Families/ChickenLord/chicken_lord_desc_panel.tscn"),
	Family.Type.COLOSSUS: preload("res://01_Cards/Pool/Families/Colossus/colossus_desc_panel.tscn"),
	Family.Type.ENGINEER: preload("res://01_Cards/Pool/Families/Engineer/engineer_desc_panel.tscn"),
}

@onready var _family_name_label: RichTextLabel = %FamilyNameLabel
@onready var _ui_cards_viewer: UICardsViewer = %UICardsViewer
@onready var _hbox: HBoxContainer = %HBoxContainer

var _current_display_mode: UICardsViewer.DisplayMode = UICardsViewer.DisplayMode.UNLOCKED_ONLY
var _player: Player
var _family: Family
var _hero: Entity
var _current_desc_panel: Control = null

#region ============================== Public API ==============================
func display_family(player: Player, family: Family) -> void:
	if _player and _player.deck.has_changed.is_connected(_on_deck_has_changed):
		_player.deck.has_changed.disconnect(_on_deck_has_changed)

	_player = player
	_family = family
	_hero = _player.hero
	_player.deck.has_changed.connect(_on_deck_has_changed)
	_family_name_label.text = _family.family_name
	_refresh_cards_viewer()
	_refresh_desc_panel()
#endregion


#region ============================== Private functions ==============================
func _on_sort_rarity_button_pressed() -> void:
	_ui_cards_viewer.sort_cards(UICardsViewer.SortMode.RARITY)


func _on_sort_level_button_pressed() -> void:
	_ui_cards_viewer.sort_cards(UICardsViewer.SortMode.LEVEL)


func _on_sort_name_button_pressed() -> void:
	_ui_cards_viewer.sort_cards(UICardsViewer.SortMode.NAME)


func _on_show_all_button_pressed() -> void:
	if _current_display_mode == UICardsViewer.DisplayMode.DEFAULT:
		_current_display_mode = UICardsViewer.DisplayMode.UNLOCKED_ONLY
	else:
		_current_display_mode = UICardsViewer.DisplayMode.DEFAULT
	_ui_cards_viewer.set_display_mode(_current_display_mode)


func _refresh_cards_viewer() -> void:
	var unlocked_cards: Array[Card] = _player.deck.get_cards_by_type(_family.family_type)
	_ui_cards_viewer.update_content(_family.cards, unlocked_cards)
	_ui_cards_viewer.set_display_mode(_current_display_mode)
	_ui_cards_viewer.reset_scroll()


func _on_deck_has_changed() -> void:
	_refresh_cards_viewer()
	_refresh_desc_panel()


func _refresh_desc_panel() -> void:
	# Remove existing desc panel if any
	if _current_desc_panel:
		_current_desc_panel.queue_free()
		_current_desc_panel = null

	if not _family:
		return

	# Check if a desc panel exists for this family type
	var scene: PackedScene = DESC_PANELS.get(_family.family_type)
	if not scene:
		return

	_current_desc_panel = scene.instantiate() as Control
	_current_desc_panel.layout_mode = 2
	_hbox.add_child(_current_desc_panel)

	# If we have a hero, feed it to the panel's API
	if _hero and _current_desc_panel.has_method("set_hero"):
		_current_desc_panel.set_hero(_hero)
#endregion
