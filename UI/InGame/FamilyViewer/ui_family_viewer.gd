class_name UIFamilyViewer
extends Control

@onready var _family_name_label: RichTextLabel = %FamilyNameLabel
@onready var _ui_cards_viewer: UICardsViewer = %UICardsViewer

var _current_display_mode: UICardsViewer.DisplayMode = UICardsViewer.DisplayMode.UNLOCKED_ONLY
var _player: Player
var _family: Family

#region ============================== Public API ==============================
func display_family(player: Player, family: Family) -> void:
	if _player and _player.deck.has_changed.is_connected(_on_deck_has_changed):
		_player.deck.has_changed.disconnect(_on_deck_has_changed)

	_player = player
	_family = family
	_player.deck.has_changed.connect(_on_deck_has_changed)
	_family_name_label.text = _family.family_name
	_refresh_cards_viewer()
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
#endregion
