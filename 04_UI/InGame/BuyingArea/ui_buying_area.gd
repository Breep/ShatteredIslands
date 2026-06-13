# Panneau UI de la phase tavern : héberge le CardShop et propage le clic "Continue"
# qui termine la phase. Piloté de l'extérieur via set_active/set_inactive.
class_name UIBuyingArea
extends Control

# ============================== Local nodes ==============================

@onready var _ui_card_shop: UICardShop = %CardShop
@onready var _shop_main_control: Control = %ShopMainControl
@onready var _open_shop_button: Button = %OpenShopButton

# ============================== Private variables ==============================

var _is_active: bool


#region ============================== Node base functions ==============================
func _ready() -> void:
	_shop_main_control.hide()
	_shop_main_control.modulate.a = 0.0
	_open_shop_button.show()


func _unhandled_input(event: InputEvent) -> void:
	if not _shop_main_control.visible:
		return
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_hide_shop_panel()

# ============================== Public functions ==============================

func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()
	show_card_shop()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide_card_shop()
	hide()


func show_card_shop() -> void:
	_ui_card_shop.set_active()


func hide_card_shop() -> void:
	_ui_card_shop.set_inactive()


# ============================== Callbacks ==============================

func _on_continue_button_pressed() -> void:
	var hero_skill: HeroSkillComponent = _local_hero_skill()
	if hero_skill != null and hero_skill.has_pending_choice():
		hero_skill.request_pending_choices()
		return
	Events.signal_tavern_continue_pressed()


func _local_hero_skill() -> HeroSkillComponent:
	var local_player: Player = PlayerManager.get_local_player()
	if local_player == null or not is_instance_valid(local_player.hero):
		return null
	return local_player.hero.skill as HeroSkillComponent


func _on_open_shop_button_pressed() -> void:
	Events.shop_opened.emit()
	_show_shop_panel()


var _shop_panel_tween: Tween
func _show_shop_panel() -> void:
	if _shop_panel_tween != null and _shop_panel_tween.is_valid():
		_shop_panel_tween.kill()
	_shop_main_control.show()
	_shop_panel_tween = create_tween()
	_shop_panel_tween.tween_property(_shop_main_control, "modulate:a", 1.0, 0.25)
	_shop_panel_tween.tween_callback(_open_shop_button.hide)


func _hide_shop_panel() -> void:
	if _shop_panel_tween != null and _shop_panel_tween.is_valid():
		_shop_panel_tween.kill()
	_shop_panel_tween = create_tween()
	_shop_panel_tween.tween_property(_shop_main_control, "modulate:a", 0.0, 0.25)
	_shop_panel_tween.tween_callback(_shop_main_control.hide)
	_shop_panel_tween.tween_callback(_open_shop_button.show)
