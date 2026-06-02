# HUD persistant en run : infos du joueur local et composition des familles.
# Pilote la popup FamilyViewer en réaction aux clics sur les portraits de famille.
class_name UIPersistant
extends Control

# ============================== Local nodes ==============================

@onready var _ui_player_info: UIPlayerInfo = %UIPlayerInfo
@onready var _ui_all_families_portraits: UIAllFamiliesPortrait = %UIAllFamiliesPortrait
@onready var _ui_family_viewer: UIFamilyViewer = %UiFamilyViewer
@onready var _ui_hand: UIHand = $UIHand

# ============================== Node base functions ==============================

func _ready() -> void:
	_ui_family_viewer.hide()
	Events.ui_family_portrait_requested.connect(_on_events_ui_family_portrait_requested)
	Events.ui_family_portrait_unselected.connect(_on_events_ui_family_portrait_unselected)


# ============================== Public functions ==============================

func bind_to_local_player(player: Player) -> void:
	_ui_player_info.connect_to_player(player)
	_ui_all_families_portraits.update_content(player)
	_ui_hand.bind(player.hand)


# ============================== Callbacks ==============================

func _on_events_ui_family_portrait_requested(player: Player, family: Family) -> void:
	_ui_family_viewer.display_family(player, family)
	_ui_family_viewer.show()


func _on_events_ui_family_portrait_unselected() -> void:
	_ui_family_viewer.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not _ui_family_viewer.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_ui_family_viewer.hide()
		_ui_all_families_portraits.reset_buttons_state()
		get_viewport().set_input_as_handled()
