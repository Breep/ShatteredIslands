# UI du shop de cartes : affiche jusqu'à N cartes du PlayerCardShop, en ligne,
# extensible. Conteneur de drag-and-drop enregistré auprès d'un DragCoordinator
# (injecté) ; il ne connaît PAS les autres conteneurs.
#
# Deux rôles via le contrat container :
#  - ORIGINE (achat) : on drag une carte du shop. Si elle atterrit dans un autre
#    conteneur (la main), celui-ci tente de l'accueillir ; le shop facture l'or
#    (can_supply / commit_removal). Drop ailleurs → retour au slot.
#  - CIBLE (vente) : une carte d'un autre conteneur droppée sur le shop est
#    rachetée. Le shop connaît la valeur de revente par rareté ; une carte
#    niveau N = N cartes source → remboursement = N × valeur.
class_name UICardShop
extends Control

#region ============================== Signals ==============================
signal card_bought(card: Card)
signal card_sold(card: Card, refund: int)
#endregion


#region ============================== Export ==============================
@export var _card_buttons: Array[CardButton]
## Médiateur de drag-and-drop. Injecté dans la scène parent. Le shop s'y
## enregistre au _ready ; aucune référence directe aux autres conteneurs.
@export var _drag_coordinator: DragCoordinator
## Mode proto : skip la résolution player/PlayerCardShop. Les cartes sont
## fournies par display_cards() ; pas de gold ni de serveur.
@export var _proto_mode: bool = false

@export_group("Drag")
@export var _return_tween_duration: float = 0.25
@export var _sell_vanish_duration: float = 0.2
## Zone de drop du shop (positionnée dans l'éditeur, debug rect en @tool).
@export var _drop_zone: DropZone
#endregion


#region ============================== Private variables ==============================
const _APPEAR_STAGGER: float = 0.1

var _card_shop: PlayerCardShop
var _local_player: Player

var _is_active: bool = true
var _is_locked: bool

# Cartes actuellement affichées dans les slots. Source de vérité côté UI (proto)
# ou copie locale alimentée par shop_refreshed (mode normal).
var _displayed_cards: Array[Card] = []

# Drag state quand le shop est l'origine (achat en cours).
var _drag_source_button: CardButton
var _drag_source_card: Card

var _sell_panel_shown: bool = false
#endregion


#region ============================== Local scene nodes ==============================
@onready var _refresh_button: Button = %RefreshButton
@onready var _random_card_button: Button = %RandomCardButton
@onready var _sell_card_panel: Control = %SellCardPanel
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	for card_button: CardButton in _card_buttons:
		# Le drag démarre au press ; un relâchement quasi instantané est arbitré en
		# clic court (achat routé vers la main) par le coordinator.
		card_button.card_drag_requested.connect(_on_card_shop_button_drag_requested)

	if _drag_coordinator != null:
		_drag_coordinator.register_container(self)

	if _proto_mode:
		_refresh_button.disabled = true
		_random_card_button.disabled = true
		return

	_local_player = PlayerManager.get_local_player()
	if _local_player == null:
		Verbose.error("UICardShop._ready(): PlayerManager.get_local_player() returned null", Verbose.Category.CARD_SHOP)
		return

	_card_shop = _local_player.get_node("CardShop") as PlayerCardShop
	if _card_shop == null:
		Verbose.error("UICardShop._ready(): no PlayerCardShop child node on local player '" + _local_player.player_name + "'", Verbose.Category.CARD_SHOP)
		return

	_card_shop.shop_refreshed.connect(_on_card_shop_shop_refreshed)
	_card_shop.card_releveled.connect(_on_card_shop_card_releveled)
	_card_shop.card_bought.connect(_on_card_shop_card_bought)
	_card_shop.shop_tried_to_refresh.connect(_on_card_shop_shop_tried_to_refresh)
	_card_shop.shop_tried_to_buy_random_card.connect(_on_card_shop_shop_tried_to_buy_random_card)

	_refresh_button.pressed.connect(_on_refresh_button_pressed, CONNECT_ONE_SHOT)
	_random_card_button.pressed.connect(_on_random_card_button_pressed, CONNECT_ONE_SHOT)

	_card_shop.refresh_for_free()


func _exit_tree() -> void:
	if _drag_coordinator != null:
		_drag_coordinator.unregister_container(self)
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


#region ============================== Container contract (DragCoordinator) ==============================
func get_drop_zone() -> DropZone:
	return _drop_zone


func on_drag_started(_payload: CardPayload, _origin: Object) -> void:
	pass


# Affiche le panneau de vente quand une carte EXTERNE (pas du shop) survole la
# zone du shop. La valeur affichée vient du domaine (PlayerCardShop).
func on_drag_motion(payload: CardPayload, mouse_global: Vector2) -> void:
	if payload.origin == self:
		return
	var inside: bool = _drop_zone != null and _drop_zone.contains_global(mouse_global)
	if inside and not _sell_panel_shown:
		_show_sell_panel(_domain_sell_value(payload))
	elif not inside and _sell_panel_shown:
		_hide_sell_panel()


func on_drag_ended() -> void:
	if _sell_panel_shown:
		_hide_sell_panel()


# Le shop accueille un drop = VENTE. La décision « vendable ? » appartient au
# domaine (PlayerCardShop) ; sans domaine (proto) la vente est toujours permise.
func can_receive(payload: CardPayload) -> bool:
	if payload.origin == self:
		return false
	return _card_shop == null or _card_shop.can_sell(payload.source_cards)


# Délègue la transaction au domaine (or + valeur). L'UI ne fait qu'animer le
# visuel et notifier. Sans domaine (proto) : remboursement 0.
func receive(payload: CardPayload, hovering: HoveringCard) -> bool:
	var refund: int = 0
	if _card_shop != null:
		refund = _card_shop.sell(payload.source_cards)
	card_sold.emit(payload.merged_card, refund)
	AudioManager.play_ui("coin_01")
	_animate_sell_vanish(hovering)
	return true


# can_supply : appelé par la cible (la main) pour valider l'achat avant transfert.
# Décision déléguée au domaine ; sans domaine (proto) → toujours possible.
func can_supply(payload: CardPayload) -> bool:
	return _card_shop == null or _card_shop.can_buy(payload.merged_card)


# commit_supply : achat autoritaire awaité par le DragCoordinator AVANT
# l'atterrissage de la carte dans la main. On délègue la transaction au domaine
# (PlayerCardShop) qui attend la réponse serveur. Sans domaine (proto) : permis.
func commit_supply(payload: CardPayload) -> bool:
	if _card_shop == null:
		return true
	return await _card_shop.buy(payload.merged_card)


# La carte du shop a été achetée : on délègue la facturation au domaine, puis on
# retire la carte de l'affichage. La main possède la HoveringCard (atterrissage).
func commit_removal(payload: CardPayload) -> void:
	# Le débit + dé-track ont déjà eu lieu côté autorité (commit_supply). Ici on
	# ne fait que vider le slot acheté.
	var button: CardButton = _drag_source_button
	_drag_source_button = null
	_drag_source_card = null
	card_bought.emit(payload.merged_card)
	Events.card_bought.emit(payload.merged_card)
	_retire_bought_slot(payload.merged_card, button)


# Achat annulé (drop hors d'une cible valide, ou cible qui refuse) : la carte du
# shop revient à son slot.
func return_to_origin(_payload: CardPayload, hovering: HoveringCard) -> void:
	var src_button: CardButton = _drag_source_button
	var target_global: Vector2 = src_button.global_position if src_button != null else hovering.global_position
	var target_scale: Vector2 = src_button.scale if src_button != null else hovering.get_card_button().scale
	var card_btn: CardButton = hovering.get_card_button()
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(hovering, "global_position", target_global, _return_tween_duration)
	tween.tween_property(card_btn, "scale", target_scale, _return_tween_duration)
	tween.chain().tween_callback(_on_return_finished.bind(hovering, src_button))
	_drag_source_button = null
	_drag_source_card = null
	AudioManager.play_ui("card_06")
#endregion


#region ============================== Public helpers ==============================
func is_inside_drop_zone(global_pos: Vector2) -> bool:
	if _drop_zone == null:
		return false
	return _drop_zone.contains_global(global_pos)
#endregion


#region ============================== Private functions ==============================
func _update_shop_cards_displayed_visual(cards: Array[Card]) -> void:
	_displayed_cards = cards
	AudioManager.play_ui("card_shuffle_01")
	# Cache tous les slots, puis affiche autant que de cartes. On masque le slot
	# ENTIER (parent) pour ne pas laisser le price label visible sur un vide.
	for btn: CardButton in _card_buttons:
		var slot: Control = _slot_for_button(btn)
		if slot != null:
			slot.hide()
	for i: int in mini(cards.size(), _card_buttons.size()):
		var btn: CardButton = _card_buttons[i]
		var slot: Control = _slot_for_button(btn)
		if slot != null:
			slot.show()
		btn.show()
		btn.update_visual(cards[i])
		btn.play_appear_animation(i * _APPEAR_STAGGER)


# Met à jour le visuel d'UN seul slot dont le niveau dérivé a changé (vente /
# achat d'un même design). Pas d'anim d'apparition ni de shuffle : on ne touche
# que le label de la carte concernée. No-op si la carte n'est plus affichée
# (ex : slot déjà retiré après un achat).
func _relevel_displayed_card(card: Card) -> void:
	var index: int = _displayed_cards.find(card)
	if index < 0 or index >= _card_buttons.size():
		return
	_card_buttons[index].update_visual(card)


# Remonte de 2 niveaux : CardButton → Control intermédiaire → VBoxContainer slot.
func _slot_for_button(btn: CardButton) -> Control:
	if btn == null:
		return null
	var intermediate: Node = btn.get_parent()
	if intermediate == null:
		return null
	return intermediate.get_parent() as Control


# Retire une carte achetée de l'affichage (drag ou clic) : vide son slot et, si
# plus aucune carte n'est affichée, déclenche un refresh gratuit automatique.
func _retire_bought_slot(card: Card, button: CardButton) -> void:
	_displayed_cards.erase(card)
	var slot: Control = _slot_for_button(button)
	if slot != null:
		slot.hide()
	if _displayed_cards.is_empty() and _card_shop != null:
		_card_shop.refresh_for_free()


func _begin_drag_from_shop(card: Card, source_button: CardButton) -> void:
	if _drag_coordinator == null or _drag_coordinator.is_dragging():
		return
	var grab_offset: Vector2 = source_button.global_position - get_global_mouse_position()
	source_button.hide()

	var visual_button: CardButton = _instance_card_button_for_drag()
	# Une carte du shop est une carte unique → une seule carte source.
	var sources: Array[Card] = [card]
	var payload: CardPayload = CardPayload.new(card, sources, self)
	_drag_source_button = source_button
	_drag_source_card = card
	_drag_coordinator.begin_drag(self, payload, visual_button, grab_offset)


# Instancie un CardButton à partir de la même PackedScene que les boutons du
# shop (premier comme template). Évite de hardcoder le path.
func _instance_card_button_for_drag() -> CardButton:
	var template_path: String = _card_buttons[0].scene_file_path
	var scene: PackedScene = load(template_path)
	return scene.instantiate() as CardButton


# Valeur de revente, demandée au domaine (le shop sait combien vaut une carte).
# Sans domaine (proto) : 0 — on n'affiche pas de chiffre.
func _domain_sell_value(payload: CardPayload) -> int:
	if _card_shop == null:
		return 0
	return _card_shop.get_sell_value(payload.source_cards)


# Anime la carte vendue qui « disparaît » dans le shop (shrink + fade) puis free.
func _animate_sell_vanish(hovering: HoveringCard) -> void:
	var card_btn: CardButton = hovering.get_card_button()
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(card_btn, "scale", card_btn.scale * 0.2, _sell_vanish_duration)
	tween.tween_property(hovering, "modulate:a", 0.0, _sell_vanish_duration)
	tween.chain().tween_callback(_free_hovering.bind(hovering))


func _free_hovering(hovering: HoveringCard) -> void:
	if is_instance_valid(hovering):
		hovering.queue_free()


func _on_return_finished(hovering: HoveringCard, source_button: CardButton) -> void:
	if is_instance_valid(hovering):
		hovering.queue_free()
	if is_instance_valid(source_button):
		source_button.show()


var _sell_panel_tween: Tween
func _show_sell_panel(refund_value: int) -> void:
	_sell_panel_shown = true
	if _sell_panel_tween != null and _sell_panel_tween.is_valid():
		_sell_panel_tween.kill()
	_set_sell_panel_value(refund_value)
	_sell_card_panel.show()
	_sell_panel_tween = create_tween()
	_sell_panel_tween.tween_property(_sell_card_panel, "modulate:a", 1.0, 0.25)


func _hide_sell_panel() -> void:
	_sell_panel_shown = false
	if _sell_panel_tween != null and _sell_panel_tween.is_valid():
		_sell_panel_tween.kill()
	_sell_panel_tween = create_tween()
	_sell_panel_tween.tween_property(_sell_card_panel, "modulate:a", 0.0, 0.25)
	_sell_panel_tween.tween_callback(_sell_card_panel.hide)


# Affiche la valeur de revente sur le panneau si un Label est présent dessous.
func _set_sell_panel_value(refund_value: int) -> void:
	var label: Label = _sell_card_panel.get_node_or_null("Label") as Label
	if label != null:
		label.text = "+%d" % refund_value
#endregion


#region ============================== Callbacks ==============================
# Press sur une carte du shop : démarre le drag. Un relâchement quasi instantané
# sera arbitré en clic court (achat routé vers la main) par le coordinator.
func _on_card_shop_button_drag_requested(button: CardButton, card: Card) -> void:
	if card == null:
		return
	_begin_drag_from_shop(card, button)


func _on_card_shop_shop_refreshed(new_cards: Array[Card]) -> void:
	_update_shop_cards_displayed_visual(new_cards)


func _on_card_shop_card_releveled(card: Card) -> void:
	_relevel_displayed_card(card)


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
	Events.shop_refreshed.emit()
	_card_shop.try_refresh_shop_cards()


func _on_random_card_button_pressed() -> void:
	_random_card_button.disabled = true
	_card_shop.try_buy_random_card()
#endregion
