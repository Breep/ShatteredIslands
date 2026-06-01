# UI du shop de cartes : affiche jusqu'à N cartes du PlayerCardShop. Les cartes
# se drag depuis le shop ; si elles sont droppées dans la drop_zone de UIHand,
# on tente l'achat via PlayerCardShop.try_buy_card. Sinon (drop hors zone ou
# achat refusé), la carte est tweenée de retour à son slot d'origine.
class_name UICardShop
extends Control

#region ============================== Signals ==============================
signal card_bought(card: Card)
#endregion


#region ============================== Export ==============================
@export var _card_buttons: Array[CardButton]
## UIHand utilisé pour interroger sa drop_zone et tenter d'ajouter la carte.
## Câblé dans la scène parent qui contient à la fois UICardShop et UIHand.
@export var _ui_hand: UIHand
## Mode proto : skip la résolution player/PlayerCardShop. Les cartes sont
## fournies par display_cards() ; le drop dans la main passe directement par
## UIHand.try_add_card (pas de gold, pas de serveur).
@export var _proto_mode: bool = false

@export_group("Drag")
@export var _hovering_scale: float = 0.55
@export var _return_tween_duration: float = 0.25
#endregion


#region ============================== Private variables ==============================
const _APPEAR_STAGGER: float = 0.1

var _card_shop: PlayerCardShop
var _local_player: Player

var _is_active: bool = true
var _is_locked: bool

# Cartes actuellement affichées dans les slots du shop. Source de vérité côté
# UI (mode proto) ou copie locale alimentée par shop_refreshed (mode normal).
var _displayed_cards: Array[Card] = []

# Drag state
var _dragging: HoveringCard
var _drag_source_button: CardButton
var _drag_source_card: Card
#endregion


#region ============================== Local scene nodes ==============================
@onready var _refresh_button: Button = %RefreshButton
@onready var _random_card_button: Button = %RandomCardButton
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	# Connexions communes aux deux modes.
	if _card_buttons.is_empty():
		Verbose.warn("UICardShop._ready(): _card_buttons is empty (export not assigned?)", Verbose.Category.CARD_SHOP)
	for card_button: CardButton in _card_buttons:
		# Connection permanente (pas CONNECT_ONE_SHOT) : c'est le _dragging flag
		# qui bloque les clics multiples pendant un drag.
		card_button.card_selected.connect(_on_card_shop_button_pressed)

	if _proto_mode:
		# Pas de player infrastructure : refresh/random sont gérés par le
		# script driver de la proto via display_cards().
		_refresh_button.disabled = true
		_random_card_button.disabled = true
		return

	# Mode normal : bind au PlayerCardShop via PlayerManager.
	#if GameManager.game_type != GameManager.GameType.SOLO and multiplayer.is_server():
		#queue_free()
		#return

	_local_player = PlayerManager.get_local_player()
	if _local_player == null:
		Verbose.error("UICardShop._ready(): PlayerManager.get_local_player() returned null", Verbose.Category.CARD_SHOP)
		return

	_card_shop = _local_player.get_node("CardShop") as PlayerCardShop
	if _card_shop == null:
		Verbose.error("UICardShop._ready(): no PlayerCardShop child node on local player '" + _local_player.player_name + "'", Verbose.Category.CARD_SHOP)
		return

	_card_shop.shop_refreshed.connect(_on_card_shop_shop_refreshed)
	_card_shop.card_bought.connect(_on_card_shop_card_bought)
	_card_shop.shop_tried_to_refresh.connect(_on_card_shop_shop_tried_to_refresh)
	_card_shop.shop_tried_to_buy_random_card.connect(_on_card_shop_shop_tried_to_buy_random_card)

	_refresh_button.pressed.connect(_on_refresh_button_pressed, CONNECT_ONE_SHOT)
	_random_card_button.pressed.connect(_on_random_card_button_pressed, CONNECT_ONE_SHOT)

	_card_shop.refresh_for_free()


func _process(_delta: float) -> void:
	# Pour l'instant rien : la HoveringCard suit la souris d'elle-même via son
	# propre _process. Reservé pour un futur tracking de drop-target (highlight).
	pass


func _input(event: InputEvent) -> void:
	if _dragging == null:
		return
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_finalize_drag()
#endregion


#region ============================== Public functions ==============================
func set_active() -> void:
	if _is_active or _is_locked: return
	_is_active = true
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()


# Alimente les slots avec une liste donnée. Utilisé par le proto (et par toute
# autre source de données qui ne passe pas par PlayerCardShop / shop_refreshed).
func display_cards(cards: Array[Card]) -> void:
	_update_shop_cards_displayed_visual(cards)
#endregion


#region ============================== Private functions ==============================
func _update_shop_cards_displayed_visual(cards: Array[Card]) -> void:
	_displayed_cards = cards
	# Cache tous les slots, puis affiche autant que de cartes (jusqu'à
	# _card_buttons.size()). On masque le slot ENTIER (VBoxContainer parent)
	# pour ne pas laisser le price label visible sur un slot vide.
	for btn: CardButton in _card_buttons:
		var slot: Control = _slot_for_button(btn)
		if slot != null:
			slot.hide()
	for i: int in mini(cards.size(), _card_buttons.size()):
		var btn: CardButton = _card_buttons[i]
		var slot: Control = _slot_for_button(btn)
		if slot != null:
			slot.show()
		btn.update_visual(cards[i])
		btn.show()
		btn.play_appear_animation(i * _APPEAR_STAGGER)


# Remonte de 2 niveaux : CardButton → Control intermédiaire → VBoxContainer slot.
func _slot_for_button(btn: CardButton) -> Control:
	if btn == null:
		return null
	var intermediate: Node = btn.get_parent()
	if intermediate == null:
		return null
	return intermediate.get_parent() as Control


func _start_drag(card: Card, source_button: CardButton) -> void:
	if _dragging != null or card == null or source_button == null:
		return
	var grab_offset: Vector2 = source_button.global_position - get_global_mouse_position()
	# On cache le bouton source pendant le drag — la HoveringCard prend le relais
	# visuellement. La carte data reste dans cards_displayed du PlayerCardShop.
	source_button.hide()

	var visual_button: CardButton = _instance_card_button_for_drag()
	var hovering: HoveringCard = HoveringCard.new()
	add_child(hovering)
	hovering.init(visual_button, card, grab_offset)
	hovering.z_index = 200

	_dragging = hovering
	_drag_source_button = source_button
	_drag_source_card = card


# Instancie un CardButton à partir de la même PackedScene que les boutons du
# shop (on prend le premier comme template). Évite de hardcoder le path.
func _instance_card_button_for_drag() -> CardButton:
	# Tous les CardButton instances du shop partagent la même scene_file_path.
	var template_path: String = _card_buttons[0].scene_file_path
	var scene: PackedScene = load(template_path)
	return scene.instantiate() as CardButton


func _finalize_drag() -> void:
	if _dragging == null:
		return
	var card: Card = _drag_source_card
	var source_button: CardButton = _drag_source_button
	var drop_global: Vector2 = _dragging.global_position
	var drop_scale: Vector2 = _dragging.get_card_button().scale

	var mouse: Vector2 = get_global_mouse_position()
	var in_hand_zone: bool = _ui_hand != null and _ui_hand.is_inside_drop_zone(mouse)

	if in_hand_zone:
		var bought: bool = await _try_perform_buy(card)
		if bought:
			# Succès : en mode normal, shop_refreshed nettoie les slots.
			# En mode proto, _try_perform_buy a déjà retiré la carte localement.
			_clear_drag_state()
			return
		# Échec d'achat (gold, refus serveur, main pleine…) : retour visuel.
		_animate_return_to_source(drop_global, drop_scale, source_button)
	else:
		_animate_return_to_source(drop_global, drop_scale, source_button)


# Tente l'achat selon le mode. Mode normal : PlayerCardShop (gold + serveur).
# Mode proto : appel direct à UIHand.try_add_card + mise à jour locale du shop.
func _try_perform_buy(card: Card) -> bool:
	if _card_shop != null:
		return await _card_shop.try_buy_card(card)
	if _ui_hand != null:
		var added: bool = _ui_hand.try_add_card(card)
		if added:
			# Pas de shop_refreshed en proto : on retire localement et on
			# rafraîchit le visuel.
			_displayed_cards.erase(card)
			_update_shop_cards_displayed_visual(_displayed_cards)
		return added
	return false


# Tween la HoveringCard de sa position actuelle vers la position du bouton
# source, puis free la HoveringCard et réaffiche le bouton.
func _animate_return_to_source(start_global: Vector2, start_scale: Vector2, source_button: CardButton) -> void:
	if _dragging == null:
		return
	var target_global: Vector2 = source_button.global_position
	var target_scale: Vector2 = source_button.scale
	# La HoveringCard est déjà à start_global / start_scale — on tween vers
	# la position du slot. Pendant ce temps le bouton source reste caché ;
	# il sera réaffiché à la fin du tween.
	var hovering: HoveringCard = _dragging
	hovering.set_process(false) # Stop le follow-souris pendant l'anim retour.
	var card_btn: CardButton = hovering.get_card_button()
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(hovering, "global_position", target_global, _return_tween_duration)
	tween.tween_property(card_btn, "scale", target_scale, _return_tween_duration)
	tween.chain().tween_callback(_on_return_animation_finished.bind(hovering, source_button))
	# Reset l'état drag tout de suite côté UIHand : nouveau clic permis pendant
	# que l'anim de retour joue (sur n'importe quelle autre carte).
	_dragging = null
	_drag_source_button = null
	_drag_source_card = null


func _on_return_animation_finished(hovering: HoveringCard, source_button: CardButton) -> void:
	if is_instance_valid(hovering):
		hovering.queue_free()
	if is_instance_valid(source_button):
		source_button.show()


func _clear_drag_state() -> void:
	if _dragging != null and is_instance_valid(_dragging):
		_dragging.queue_free()
	_dragging = null
	_drag_source_button = null
	_drag_source_card = null
#endregion


#region ============================== Callbacks ==============================
func _on_card_shop_button_pressed(button: CardButton, card: Card) -> void:
	if _dragging != null:
		return
	if card == null:
		return
	_start_drag(card, button)


func _on_card_shop_shop_refreshed(new_cards: Array[Card]) -> void:
	# Si un drag est en cours quand le shop refresh (succès d'achat), on cancel
	# proprement (la HoveringCard est déjà en train de disparaître par _clear_drag_state
	# si on vient de drop in-hand-zone ; sinon on s'assure de cleanup).
	if _dragging != null:
		_clear_drag_state()
	_update_shop_cards_displayed_visual(new_cards)


func _on_card_shop_card_bought(card: Card) -> void:
	card_bought.emit(card)
	Events.card_bought.emit(card)


func _on_card_shop_shop_tried_to_refresh() -> void:
	_refresh_button.pressed.connect(_on_refresh_button_pressed, CONNECT_ONE_SHOT)
	_refresh_button.disabled = false


func _on_card_shop_shop_tried_to_buy_random_card() -> void:
	_random_card_button.pressed.connect(_on_random_card_button_pressed, CONNECT_ONE_SHOT)
	_random_card_button.disabled = false


func _on_close_button_pressed() -> void:
	set_inactive()


func _on_refresh_button_pressed() -> void:
	_refresh_button.disabled = true
	_card_shop.try_refresh_shop_cards()


func _on_random_card_button_pressed() -> void:
	_random_card_button.disabled = true
	_card_shop.try_buy_random_card()
#endregion
