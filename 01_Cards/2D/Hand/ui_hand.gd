# UI de la main du joueur : affiche les cartes d'une Hand sous forme d'éventail
# façon Hearthstone. Sous _straight_threshold cartes elles restent droites et
# alignées ; au-delà, elles s'arrangent sur un arc dont l'écartement angulaire
# croît légèrement avec le nombre de cartes (spread = base + a*sqrt(N)). Au
# survol d'une carte : la carte se redresse + grossit + monte, les voisines
# s'écartent (décroissance exponentielle), et un preview agrandi apparaît près
# du curseur après un délai.
#
# Drag-and-drop : la main est un conteneur enregistré auprès d'un DragCoordinator
# (injecté). Elle ne connaît PAS les autres conteneurs (shop, coffre) ; le
# coordinator route les transferts. La main implémente le contrat container
# (get_drop_zone / on_drag_* / can_receive / receive / return_to_origin /
# commit_removal). Une carte tenue reste dans la Hand (hold) tant qu'elle n'est
# pas transférée ailleurs ; un drop dans la main = simple reorder.
class_name UIHand
extends Control

#region ============================== Signals ==============================
signal card_clicked(card: Card)
#endregion


#region ============================== Export ==============================
## Médiateur de drag-and-drop. Injecté dans la scène parent. La main s'y
## enregistre au _ready ; aucune référence directe aux autres conteneurs.
@export var _drag_coordinator: DragCoordinator

@export_group("Fan layout")
## Rayon de l'arc virtuel sur lequel se placent les cartes. Plus grand = arc
## plus plat (cartes presque horizontales sur les côtés).
@export var _fan_radius: float = 800.0
## Ouverture angulaire fixe de l'éventail (en degrés).
@export var _fan_base_spread_deg: float = 30.0
## Coefficient `a` ajouté en `a*sqrt(N)` degrés au spread total : plus N grandit,
## plus l'éventail s'élargit, mais l'écart angulaire entre voisines diminue (le
## fan « se ressert »).
@export var _fan_spread_growth: float = 8.0

@export_group("Straight layout")
## Sous (ou égal à) ce seuil, les cartes restent droites et horizontales.
@export var _straight_threshold: int = 3
## Espacement horizontal entre cartes en mode droit (pixels).
@export var _straight_spacing: float = 250.0

@export_group("Cards")
@export var _card_scale: float = 0.5
@export var _card_button_scene: PackedScene

@export_group("Hover")
## Décalage latéral max appliqué à la voisine immédiate de la carte survolée.
@export var _hover_spread_amount: float = 60.0
## Coefficient de décroissance exponentielle : à distance d (≥1) du hover,
## le décalage vaut `_hover_spread_amount * exp(-(d-1) * _hover_spread_falloff)`.
@export var _hover_spread_falloff: float = 0.5
## Élévation verticale (en px) de la carte survolée par rapport à sa base.
@export var _hovered_lift: float = 30.0
## Boost de scale relatif de la carte survolée (0.15 = +15 %).
@export var _hovered_scale_boost: float = 0.15

@export_group("Preview")
## Délai (s) de survol avant l'apparition du preview agrandi.
@export var _preview_delay: float = 0.5
## Scale du preview agrandi (1.0 ≈ 2× la carte en main quand _card_scale = 0.5).
@export var _preview_scale: float = 1.0
## Offset (px) appliqué entre la position de la souris au moment du snap et le
## centre visuel du preview. Par défaut, le preview apparaît en haut à droite.
@export var _preview_offset: Vector2 = Vector2(300.0, -380.0)

@export_group("Drag & Drop")
## Zone (Control positionné dans l'éditeur) considérée comme « dans la main » :
## un release dedans insère la carte à l'index calculé, dehors la carte garde
## sa position d'origine. Le Control est visible en éditeur (debug rect), inerte
## en runtime (mouse_filter IGNORE).
@export var _drop_zone: DropZone
## z_index temporaire de la carte droppée pendant qu'elle « atterrit » dans son
## slot, pour rester visible au-dessus des autres. Reset à 0 à la fin du tween.
@export var _drop_landing_z_index: int = 50

@export_group("Anim")
## Durée du tween de layout sur ajout/retrait de carte.
@export var _layout_tween_duration: float = 0.25
## Durée du tween de layout sur changement d'état de hover (plus snappy).
@export var _hover_layout_duration: float = 0.15

@export_group("Internal")
@export var _hand_pivot: Control
@export var _editor_preview_root: Control

@export_group("HideShow")
@export var _hide_show_duration: float = 0.5
## Glissement vers le bas en mode entièrement masqué (combat / hors tavern) : la
## main sort complètement de l'écran.
@export var _hide_offset_y: float = 350.0
## Glissement vers le bas en mode replié (tavern, souris hors zone) : plus court
## que _hide_offset_y pour laisser dépasser le haut des cartes du milieu.
@export var _peek_offset_y: float = 250.0
## Zone basse (Control positionné dans l'éditeur) qui, survolée shop fermé,
## redéploie la main repliée.
@export var _show_hand_zone: DropZone
#endregion

#region ============================== Internals ==============================
@onready var _card_counter_label: RichTextLabel = %CardCounterLabel
@onready var _warning_hand_full_label: RichTextLabel = %WarningHandFullLabel
@onready var _warning_not_enough_gold_label: RichTextLabel = %WarningNotEnoughGoldLabel

#region ============================== Private vars ==============================
var _hand: Hand
var _card_buttons: Dictionary[StringName, CardButton] = {}
var _layout_tweens: Dictionary[StringName, Tween] = {}

var _hovered_card: Card
# Epoch incrémenté à chaque démarrage de timer de preview ; les timeouts
# obsolètes (mouse a quitté la carte avant la fin) sont ignorés via cette valeur.
var _preview_epoch: int = 0
var _preview_instance: CardButton

# État de drag (piloté par le DragCoordinator via le contrat container).
# _drag_active : un drag est en cours (n'importe quelle origine) → hover suspendu.
# _drag_drop_index : position du « trou » visuel dans le fan (-1 = pas de trou).
# _drag_original_index : index d'origine de la carte tenue, pour un retour hors zone.
var _drag_active: bool = false
var _drag_drop_index: int = -1
var _drag_original_index: int = -1
# Quand true, _layout_all() est court-circuité. Utilisé pour grouper plusieurs
# mutations de la main (reorder + release, ou adds multiples) sans déclencher de
# layouts intermédiaires : le layout final part de la position de la HoveringCard.
var _batch_mode: bool = false

var _hand_pivot_starting_position: Vector2

# Tweens de feedback de refus d'ajout. Chaque cible a son propre tracker pour
# qu'un nouveau refus sur une cible n'aille pas tuer un tween en cours sur
# une autre (sinon la précédente reste figée à mi-anim).
var _card_flash_tweens: Dictionary[StringName, Tween] = {}
var _counter_flash_tween: Tween
var _hand_full_warning_tween: Tween
var _not_enough_gold_warning_tween: Tween

# Nom de la carte qui vient d'être droppée : on ignore le mouse_entered qu'elle
# va recevoir au prochain frame (le rect du nouveau bouton contient déjà la
# souris). Sinon le hover se déclenche immédiatement après drop → carte
# redressée à 0° + preview popup au curseur. Le flag est nettoyé au premier
# mouse_exited sur cette carte (utilisateur a bougé la souris hors d'elle).
var _just_dropped_card_name: StringName = &""
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	if _editor_preview_root != null:
		_editor_preview_root.queue_free()
		_editor_preview_root = null
	_hand_pivot_starting_position = _hand_pivot.position
	if _drag_coordinator != null:
		_drag_coordinator.register_container(self)
	Events.tutorial_set_hand_visible.connect(_on_tutorial_set_hand_visible)
	Events.insufficient_gold.connect(_on_insufficient_gold)
	Events.shop_opened.connect(_on_events_shop_opened)
	Events.shop_closed.connect(_on_events_shop_closed)


func _on_tutorial_set_hand_visible(is_visible: bool) -> void:
	visible = is_visible


func _exit_tree() -> void:
	if _drag_coordinator != null:
		_drag_coordinator.unregister_container(self)
#endregion


#region ============================== Public functions ==============================
func bind(hand: Hand) -> void:
	if _hand == hand:
		return
	unbind()
	if hand == null:
		return
	_hand = hand
	_hand.card_added.connect(_on_hand_card_added)
	_hand.card_removed.connect(_on_hand_card_removed)
	_hand.card_held.connect(_on_hand_card_held)
	_hand.card_released.connect(_on_hand_card_released)
	_hand.has_changed.connect(_on_hand_changed)
	_hand.card_addition_refused.connect(_on_hand_card_addition_refused)
	_rebuild_all()
	_update_counter()


func unbind() -> void:
	if _hand == null:
		return
	_hand.card_added.disconnect(_on_hand_card_added)
	_hand.card_removed.disconnect(_on_hand_card_removed)
	_hand.card_held.disconnect(_on_hand_card_held)
	_hand.card_released.disconnect(_on_hand_card_released)
	_hand.has_changed.disconnect(_on_hand_changed)
	_hand.card_addition_refused.disconnect(_on_hand_card_addition_refused)
	_hand = null
	_hovered_card = null
	_just_dropped_card_name = &""
	_hide_preview()
	_clear_all_card_buttons()
	_kill_refusal_tweens()
#endregion


#region ============================== Container contract (DragCoordinator) ==============================
func get_drop_zone() -> DropZone:
	return _drop_zone


# Un drag a commencé quelque part (cette main ou ailleurs). On suspend le hover
# et on nettoie tout état de survol en cours.
func on_drag_started(_payload: CardPayload, _origin: Object) -> void:
	_drag_active = true
	if _hovered_card != null:
		_hovered_card = null
		_cancel_preview_timer()
		_hide_preview()
	_layout_all(_hover_layout_duration)


# Chaque frame du drag : on calcule où la carte atterrirait si on était dans la
# zone, et on déplace le « trou » du fan en conséquence.
func on_drag_motion(_payload: CardPayload, mouse_global: Vector2) -> void:
	var inside: bool = is_inside_drop_zone(mouse_global)
	var new_index: int = _compute_drop_index(mouse_global) if inside else -1
	if new_index != _drag_drop_index:
		_drag_drop_index = new_index
		_layout_all(_hover_layout_duration)


func on_drag_ended() -> void:
	_drag_active = false
	_drag_drop_index = -1
	_layout_all(_hover_layout_duration)


# La main peut-elle accueillir ce payload ? Room dans la main + (optionnel) la
# source autorise la fourniture (ex : le shop vérifie l'or du joueur).
func can_receive(payload: CardPayload) -> bool:
	if _hand == null or payload.merged_card == null:
		return false
	if not _hand.can_add(payload.merged_card):
		return false
	if payload.origin != null and payload.origin != self and payload.origin.has_method("can_supply"):
		if not payload.origin.can_supply(payload):
			return false
	return true


# Accueille le payload : ajoute toutes les cartes source (niveau N → N adds) et
# fait atterrir la carte agrégée depuis la position de la HoveringCard.
func receive(payload: CardPayload, hovering: HoveringCard) -> bool:
	_batch_mode = true
	for src: Card in payload.source_cards:
		_hand.add_card(src)
	_land_dropped_card(payload.merged_card, hovering)
	_batch_mode = false
	return true


# La carte tenue revient à la main : reorder à l'index visé si on est dans la
# zone, sinon retour à sa position d'origine. Puis release du hold + atterrissage.
func return_to_origin(payload: CardPayload, hovering: HoveringCard) -> void:
	var mouse: Vector2 = get_global_mouse_position()
	var idx: int = _compute_drop_index(mouse) if is_inside_drop_zone(mouse) else _drag_original_index
	_batch_mode = true
	if idx >= 0:
		_hand.reorder_card(payload.merged_card.name, idx)
	_hand.release_held_card()
	_land_dropped_card(payload.merged_card, hovering)
	_batch_mode = false


# La carte tenue a été transférée ailleurs (vendue / mise au coffre) : on la
# retire pour de bon. Le hold est nettoyé par Hand.remove_card.
func commit_removal(payload: CardPayload) -> void:
	if _hand == null:
		return
	_hand.remove_card(payload.merged_card)
#endregion


#region ============================== Public helpers ==============================
# Vrai si le point global est dans la zone d'accueil de la main.
func is_inside_drop_zone(global_pos: Vector2) -> bool:
	if _drop_zone == null:
		return false
	return _drop_zone.contains_global(global_pos)
#endregion


#region ============================== Private functions ==============================
func _rebuild_all() -> void:
	_clear_all_card_buttons()
	for card: Card in _hand.get_cards_raw():
		_create_card_button(card)
	_layout_all()


func _clear_all_card_buttons() -> void:
	for tween: Tween in _layout_tweens.values():
		if tween != null and tween.is_running():
			tween.kill()
	_layout_tweens.clear()
	for btn: CardButton in _card_buttons.values():
		btn.queue_free()
	_card_buttons.clear()


func _create_card_button(card: Card) -> CardButton:
	var btn: CardButton = _card_button_scene.instantiate()
	_hand_pivot.add_child(btn)
	btn.update_visual(card)
	btn.scale = Vector2(_card_scale, _card_scale)
	btn.set_hover_enabled(false)
	btn.set_hover_audio_enabled(false)
	btn.remove_shader()
	btn.mouse_entered_card.connect(_on_card_button_mouse_entered)
	btn.mouse_exited_card.connect(_on_card_button_mouse_exited)
	btn.card_drag_requested.connect(_on_card_button_drag_requested)
	_card_buttons[card.name] = btn
	return btn


# Démarre un drag depuis la main : marque la carte comme tenue (hold, données
# préservées) et délègue la HoveringCard au coordinator.
func _begin_drag_from_hand(card: Card) -> void:
	if _drag_coordinator == null or _drag_coordinator.is_dragging():
		return
	var btn: CardButton = _card_buttons.get(card.name)
	if btn == null:
		return
	# Offset cursor→centre AVANT hold (le bouton sera freed par _on_hand_card_held).
	var grab_offset: Vector2 = btn.global_position - get_global_mouse_position()

	# Index d'origine dans l'ordre complet : un release hors zone y ramène la carte.
	_drag_original_index = -1
	var cards: Array[Card] = _hand.get_cards_raw()
	for i: int in cards.size():
		if cards[i].name == card.name:
			_drag_original_index = i
			break
	if _drag_original_index < 0:
		return

	# Les cartes source réelles (UID) voyagent dans le payload pour une éventuelle
	# vente/stockage. La carte n'est PAS retirée : juste tenue.
	var sources: Array[Card] = _hand.get_source_cards(card.name)
	if not _hand.hold_card(card):
		return

	var visual_button: CardButton = _card_button_scene.instantiate()
	var payload: CardPayload = CardPayload.new(card, sources, self)
	_drag_coordinator.begin_drag(self, payload, visual_button, grab_offset)


# Fait apparaître/positionne le bouton de la carte agrégée à la position de la
# HoveringCard, puis libère cette dernière. Le tween vers le slot final est
# joué par le _layout_all() qui suit (déclenché par on_drag_ended).
func _land_dropped_card(merged: Card, hovering: HoveringCard) -> void:
	var btn: CardButton = _card_buttons.get(merged.name)
	if btn == null:
		btn = _create_card_button(merged)
	btn.global_position = hovering.global_position
	btn.scale = hovering.get_card_button().scale
	btn.z_index = _drop_landing_z_index
	_just_dropped_card_name = merged.name
	if is_instance_valid(hovering):
		hovering.queue_free()
	AudioManager.play_ui("card_06")
	# Reset du z_index après le tween. Timer (pas tween.finished) car un autre
	# layout pourrait kill le tween avant son terme.
	get_tree().create_timer(_layout_tween_duration).timeout.connect(
		_on_drop_landing_finished.bind(btn)
	)


# `duration < 0` => utilise _layout_tween_duration. Les callbacks de hover passent
# _hover_layout_duration pour une réaction plus snappy.
func _layout_all(duration: float = -1.0) -> void:
	if _batch_mode:
		return
	if _hand == null:
		return
	_sync_child_order()
	var effective_duration: float = duration if duration >= 0.0 else _layout_tween_duration
	# La carte tenue (drag depuis cette main) est exclue : get_visible_cards filtre.
	var cards: Array[Card] = _hand.get_visible_cards()
	var n_real: int = cards.size()
	var has_gap: bool = _drag_active and _drag_drop_index >= 0
	var n_visual: int = n_real + (1 if has_gap else 0)
	# Hover suspendu pendant un drag : pas de lift + scale, pas de spread.
	var hovered_index: int = -1 if _drag_active else _find_hovered_index(cards)

	var visual_index: int = 0
	for i: int in n_real:
		if has_gap and visual_index == _drag_drop_index:
			visual_index += 1
		var card: Card = cards[i]
		var btn: CardButton = _card_buttons.get(card.name)
		if btn != null:
			var t: Dictionary = _compute_card_transform(visual_index, n_visual)
			var target_pos: Vector2
			var target_rot: float
			var target_scale: Vector2
			if i == hovered_index:
				target_pos = t["position"] + Vector2(0.0, -_hovered_lift)
				target_rot = 0.0
				target_scale = Vector2(_card_scale, _card_scale) * (1.0 + _hovered_scale_boost)
			else:
				target_pos = t["position"] + _compute_spread_offset(i, hovered_index)
				target_rot = t["rotation"]
				target_scale = Vector2(_card_scale, _card_scale)
			_tween_card_to(card.name, btn, target_pos, target_rot, target_scale, effective_duration)
		visual_index += 1


# Calcule la transform locale (relative à _hand_pivot) de la carte d'index `index`
# dans une main de `count` cartes. Le pivot virtuel de l'arc est sous `_hand_pivot` :
# une carte au milieu (angle 0) se retrouve à la position de `_hand_pivot`, les
# cartes excentrées descendent et se tournent radialement.
func _compute_card_transform(index: int, count: int) -> Dictionary:
	if count <= 0:
		return {"position": Vector2.ZERO, "rotation": 0.0}
	if count <= _straight_threshold:
		var total_width: float = float(count - 1) * _straight_spacing
		var x: float = -total_width * 0.5 + float(index) * _straight_spacing
		return {"position": Vector2(x, 0.0), "rotation": 0.0}

	var spread_rad: float = deg_to_rad(_compute_spread_deg(count))
	var angle_per_card: float = spread_rad / float(count - 1)
	var angle: float = -spread_rad * 0.5 + float(index) * angle_per_card
	var pos: Vector2 = Vector2(_fan_radius * sin(angle), _fan_radius * (1.0 - cos(angle)))
	return {"position": pos, "rotation": angle}


func _compute_spread_deg(count: int) -> float:
	return _fan_base_spread_deg + _fan_spread_growth * sqrt(float(count))


func _compute_spread_offset(i: int, hovered_index: int) -> Vector2:
	if hovered_index < 0:
		return Vector2.ZERO
	if i == hovered_index:
		return Vector2.ZERO
	var dist: int = absi(i - hovered_index)
	var magnitude: float = _hover_spread_amount * exp(-float(dist - 1) * _hover_spread_falloff)
	var direction: float = signf(float(i - hovered_index))
	return Vector2(magnitude * direction, 0.0)


func _find_hovered_index(cards: Array[Card]) -> int:
	if _hovered_card == null:
		return -1
	for i: int in cards.size():
		if cards[i].name == _hovered_card.name:
			return i
	return -1


# Réordonne les enfants de _hand_pivot pour que l'index dans la liste corresponde
# à l'index de la carte dans la main. Effet visuel : carte de gauche au fond,
# carte de droite devant (ordre naturel de rendu pour le fan).
func _sync_child_order() -> void:
	if _hand == null:
		return
	var cards: Array[Card] = _hand.get_visible_cards()
	for i: int in cards.size():
		var card: Card = cards[i]
		var btn: CardButton = _card_buttons.get(card.name)
		if btn != null and btn.get_parent() == _hand_pivot:
			_hand_pivot.move_child(btn, i)


func _tween_card_to(card_name: StringName, btn: CardButton, target_pos: Vector2, target_rot: float, target_scale: Vector2, duration: float) -> void:
	var existing: Tween = _layout_tweens.get(card_name)
	if existing != null and existing.is_running():
		existing.kill()
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(btn, "position", target_pos, duration)
	tween.tween_property(btn, "rotation", target_rot, duration)
	tween.tween_property(btn, "scale", target_scale, duration)
	_layout_tweens[card_name] = tween


func _kill_card_flash_tween(card_name: StringName) -> void:
	var tween: Tween = _card_flash_tweens.get(card_name)
	if tween != null and tween.is_valid():
		tween.kill()
	_card_flash_tweens.erase(card_name)


# Coupe tous les tweens de feedback de refus en cours et remet les cibles à
# leur état neutre (modulate blanc, warning label caché).
func _kill_refusal_tweens() -> void:
	for tween: Tween in _card_flash_tweens.values():
		if tween != null and tween.is_valid():
			tween.kill()
	_card_flash_tweens.clear()
	if _counter_flash_tween != null and _counter_flash_tween.is_valid():
		_counter_flash_tween.kill()
	_counter_flash_tween = null
	if _card_counter_label != null:
		_card_counter_label.modulate = Color.WHITE
	if _hand_full_warning_tween != null and _hand_full_warning_tween.is_valid():
		_hand_full_warning_tween.kill()
	_hand_full_warning_tween = null
	if _warning_hand_full_label != null:
		_warning_hand_full_label.visible = false
	if _not_enough_gold_warning_tween != null and _not_enough_gold_warning_tween.is_valid():
		_not_enough_gold_warning_tween.kill()
	_not_enough_gold_warning_tween = null
	if _warning_not_enough_gold_label != null:
		_warning_not_enough_gold_label.visible = false


func _start_preview_timer(card: Card) -> void:
	_preview_epoch += 1
	var my_epoch: int = _preview_epoch
	get_tree().create_timer(_preview_delay).timeout.connect(
		func() -> void: _on_preview_timer_timeout(card, my_epoch)
	)


# Annule tout timer de preview en attente en bumpant l'epoch : les callbacks
# encore vivants verront leur epoch périmé et n'agiront pas.
func _cancel_preview_timer() -> void:
	_preview_epoch += 1


func _show_preview(card: Card) -> void:
	_hide_preview()
	_preview_instance = _card_button_scene.instantiate()
	add_child(_preview_instance)
	_preview_instance.update_visual(card)
	_preview_instance.set_hover_enabled(false)
	_preview_instance.set_hover_audio_enabled(false)
	_preview_instance.remove_shader()
	_preview_instance.scale = Vector2(_preview_scale, _preview_scale)
	_preview_instance.z_index = 100
	# Empêche le preview d'intercepter la souris (sinon il vole le hover de la
	# carte en main, faisant osciller mouse_entered/mouse_exited).
	_disable_mouse_recursive(_preview_instance)
	_preview_instance.global_position = get_global_mouse_position() + _preview_offset


func _hide_preview() -> void:
	if _preview_instance != null:
		_preview_instance.queue_free()
		_preview_instance = null


func _disable_mouse_recursive(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child: Node in node.get_children():
		_disable_mouse_recursive(child)


func _compute_drop_index(mouse_global: Vector2) -> int:
	if _hand == null:
		return 0
	# N visuel = nombre de cartes visibles + 1 (le gap où atterrirait le drop).
	# La carte tenue (si la main est l'origine) n'est pas dans les visibles.
	var n_visual: int = _hand.get_visible_cards().size() + 1
	if n_visual <= 1:
		return 0
	var pivot_global_x: float = _hand_pivot.global_position.x
	var best_index: int = 0
	var best_dist: float = INF
	for i: int in n_visual:
		var t: Dictionary = _compute_card_transform(i, n_visual)
		var slot_global_x: float = pivot_global_x + t["position"].x
		var dist: float = absf(mouse_global.x - slot_global_x)
		if dist < best_dist:
			best_dist = dist
			best_index = i
	return best_index
#endregion


#region ============================== Callbacks ==============================
func _on_hand_card_added(card: Card) -> void:
	if not _card_buttons.has(card.name):
		_create_card_button(card)
	_layout_all()
	_update_counter()


func _on_hand_card_removed(card: Card) -> void:
	if _hovered_card != null and _hovered_card.name == card.name:
		_hovered_card = null
		_cancel_preview_timer()
		_hide_preview()
	_kill_card_flash_tween(card.name)
	var btn: CardButton = _card_buttons.get(card.name)
	if btn != null:
		var tween: Tween = _layout_tweens.get(card.name)
		if tween != null and tween.is_running():
			tween.kill()
		_layout_tweens.erase(card.name)
		btn.queue_free()
		_card_buttons.erase(card.name)
	_layout_all()
	_update_counter()


# Couvre les cas où une carte présente change (level up, duplicat ré-ajouté…)
# sans ajout ni retrait de slot.
func _on_hand_changed() -> void:
	if _hand == null:
		return
	for card: Card in _hand.get_visible_cards():
		var btn: CardButton = _card_buttons.get(card.name)
		if btn != null:
			btn.update_visual(card)


# La carte vient d'être marquée comme tenue : on free son bouton du fan (le
# visuel vit maintenant dans la HoveringCard), on nettoie le hover si elle était
# survolée. Les données restent en main.
func _on_hand_card_held(card: Card) -> void:
	if _hovered_card != null and _hovered_card.name == card.name:
		_hovered_card = null
		_cancel_preview_timer()
		_hide_preview()
	_kill_card_flash_tween(card.name)
	var btn: CardButton = _card_buttons.get(card.name)
	if btn != null:
		var tween: Tween = _layout_tweens.get(card.name)
		if tween != null and tween.is_running():
			tween.kill()
		_layout_tweens.erase(card.name)
		btn.queue_free()
		_card_buttons.erase(card.name)
	_layout_all()


# La carte tenue est rendue au fan : on s'assure qu'un bouton existe (le
# positionnement/atterrissage est géré par return_to_origin).
func _on_hand_card_released(card: Card) -> void:
	if card == null:
		return
	if not _card_buttons.has(card.name):
		_create_card_button(card)
	_layout_all()


func _on_card_button_mouse_entered(card: Card) -> void:
	if _drag_active:
		return
	if card == null:
		return
	# Carte fraîchement droppée sous le curseur : on ignore le hover automatique.
	# Le flag se nettoie au prochain mouse_exited (l'utilisateur a bougé hors).
	if card.name == _just_dropped_card_name:
		return
	_hovered_card = card
	_start_preview_timer(card)
	_layout_all(_hover_layout_duration)


func _on_card_button_mouse_exited(card: Card) -> void:
	if _drag_active:
		return
	# Première sortie sur la carte fraîchement droppée : on lève le flag pour
	# que les futurs hovers (entrée délibérée) fonctionnent normalement.
	if card.name == _just_dropped_card_name:
		_just_dropped_card_name = &""
		return
	if _hovered_card == null or _hovered_card.name != card.name:
		return
	_hovered_card = null
	_cancel_preview_timer()
	_hide_preview()
	_layout_all(_hover_layout_duration)


func _on_card_button_drag_requested(_button: CardButton, card: Card) -> void:
	_begin_drag_from_hand(card)


func _on_preview_timer_timeout(card: Card, epoch: int) -> void:
	if epoch != _preview_epoch:
		return
	if _hovered_card == null or _hovered_card.name != card.name:
		return
	_show_preview(card)


func _on_drop_landing_finished(dropped_btn: CardButton) -> void:
	if is_instance_valid(dropped_btn):
		dropped_btn.z_index = 0


func _on_insufficient_gold() -> void:
	_show_not_enough_gold_warning()


func _on_hand_card_addition_refused(card: Card, reason: Hand.RefusalReason) -> void:
	match reason:
		Hand.RefusalReason.CARD_ALREADY_MAXED_OUT:
			AudioManager.play_ui("error_01")
			_flash_card_red(card)
		Hand.RefusalReason.HAND_IS_FULL:
			AudioManager.play_ui("error_02")
			_flash_counter_red()
			_show_hand_full_warning()


func _on_events_shop_opened() -> void:
	_shop_open = true
	if _auto_peek_enabled:
		_update_auto_peek()


func _on_events_shop_closed() -> void:
	_shop_open = false
	if _auto_peek_enabled:
		_update_auto_peek()


# Flash rouge → blanc sur le bouton de la carte refusée. Tracker par-carte
# pour que spammer sur plusieurs cartes ne kill pas les flashs en cours sur
# les autres (et qu'elles ne restent pas figées en rouge).
func _flash_card_red(card: Card) -> void:
	var btn: CardButton = _card_buttons.get(card.name)
	if btn == null:
		return
	var existing: Tween = _card_flash_tweens.get(card.name)
	if existing != null and existing.is_valid():
		existing.kill()
	# Reset explicite à blanc avant de relancer, sinon un kill au milieu d'un
	# fade-out laisserait la carte à mi-rouge.
	btn.modulate = Color.WHITE
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(btn, "modulate", Color.RED, 0.15)
	tween.tween_property(btn, "modulate", Color.WHITE, 0.15)
	_card_flash_tweens[card.name] = tween


func _flash_counter_red() -> void:
	if _counter_flash_tween != null and _counter_flash_tween.is_valid():
		_counter_flash_tween.kill()
	_card_counter_label.modulate = Color.WHITE
	_counter_flash_tween = create_tween()
	_counter_flash_tween.tween_property(_card_counter_label, "modulate", Color.RED, 0.1)
	_counter_flash_tween.tween_property(_card_counter_label, "modulate", Color.WHITE, 0.1)
	_counter_flash_tween.tween_property(_card_counter_label, "modulate", Color.RED, 0.1)
	_counter_flash_tween.tween_property(_card_counter_label, "modulate", Color.WHITE, 0.1)


func _show_hand_full_warning() -> void:
	if _warning_hand_full_label == null:
		return
	if _hand_full_warning_tween != null and _hand_full_warning_tween.is_valid():
		_hand_full_warning_tween.kill()
	# Reset explicite : si on était à mi-fade-out, on repart proprement de 0
	# transparent (la callback `visible = false` peut ne pas avoir fire si
	# le tween précédent a été tué).
	_warning_hand_full_label.visible = true
	_warning_hand_full_label.modulate.a = 0.0
	_hand_full_warning_tween = create_tween()
	_hand_full_warning_tween.tween_property(_warning_hand_full_label, "modulate:a", 1.0, 0.2)
	_hand_full_warning_tween.tween_interval(2.0)
	_hand_full_warning_tween.tween_property(_warning_hand_full_label, "modulate:a", 0.0, 0.3)
	_hand_full_warning_tween.tween_callback(_hide_hand_full_warning)


func _hide_hand_full_warning() -> void:
	if _warning_hand_full_label != null:
		_warning_hand_full_label.visible = false


# Avertissement « pas assez d'or » (émis par le shop via Events.insufficient_gold).
# Slot dédié, empilé au-dessus du warning « main pleine » : les deux peuvent
# s'afficher en même temps sans se recouvrir.
func _show_not_enough_gold_warning() -> void:
	if _warning_not_enough_gold_label == null:
		return
	if _not_enough_gold_warning_tween != null and _not_enough_gold_warning_tween.is_valid():
		_not_enough_gold_warning_tween.kill()
	_warning_not_enough_gold_label.visible = true
	_warning_not_enough_gold_label.modulate.a = 0.0
	_not_enough_gold_warning_tween = create_tween()
	_not_enough_gold_warning_tween.tween_property(_warning_not_enough_gold_label, "modulate:a", 1.0, 0.2)
	_not_enough_gold_warning_tween.tween_interval(2.0)
	_not_enough_gold_warning_tween.tween_property(_warning_not_enough_gold_label, "modulate:a", 0.0, 0.3)
	_not_enough_gold_warning_tween.tween_callback(_hide_not_enough_gold_warning)


func _hide_not_enough_gold_warning() -> void:
	if _warning_not_enough_gold_label != null:
		_warning_not_enough_gold_label.visible = false
#endregion


#region ============================== Hide / Show ==============================
## Position verticale de la main :
## - SHOWN  : déployée (position de base).
## - PEEK   : repliée mais le haut des cartes du milieu reste visible (tavern, souris hors zone).
## - HIDDEN : entièrement hors écran (combat / hors tavern).
enum DeckPos { SHOWN, PEEK, HIDDEN }

var _hide_show_tween: Tween
var _deck_pos: DeckPos = DeckPos.SHOWN
# Mode auto (tavern) : la main se replie/déploie selon la souris et l'état du
# shop. Désactivé en combat → main entièrement masquée (HIDDEN), sans peek.
var _auto_peek_enabled: bool = false
var _shop_open: bool = false


func _process(_delta: float) -> void:
	if _auto_peek_enabled:
		_update_auto_peek()


# Active le mode auto (tavern) : la main démarre repliée puis suit la souris.
# Le désactiver (combat) masque entièrement la main et fige cet état.
func set_auto_peek_enabled(enabled: bool) -> void:
	_auto_peek_enabled = enabled
	if enabled:
		_shop_open = false
		_set_deck_pos(DeckPos.PEEK)
	else:
		_set_deck_pos(DeckPos.HIDDEN)


# Masque entièrement la main (combat / hors tavern) et coupe le mode auto.
func hide_deck() -> void:
	set_auto_peek_enabled(false)


# Règle de visibilité auto (tavern) :
# - shop ouvert (ou drag en cours) → main forcée déployée ;
# - sinon hystérésis souris : reste déployée tant que la souris est dans la zone
#   de drop, se replie (peek) dès qu'elle en sort, se redéploie quand elle entre
#   dans la ShowHandZone.
func _update_auto_peek() -> void:
	if _shop_open or _drag_active:
		_set_deck_pos(DeckPos.SHOWN)
		return
	var mouse: Vector2 = get_global_mouse_position()
	if _deck_pos == DeckPos.SHOWN:
		if not _zone_contains(_drop_zone, mouse):
			_set_deck_pos(DeckPos.PEEK)
	elif _zone_contains(_show_hand_zone, mouse):
		_set_deck_pos(DeckPos.SHOWN)


func _zone_contains(zone: DropZone, global_pos: Vector2) -> bool:
	return zone != null and zone.contains_global(global_pos)


func _set_deck_pos(pos: DeckPos) -> void:
	if pos == _deck_pos:
		return
	_deck_pos = pos
	if _hide_show_tween != null and _hide_show_tween.is_valid():
		_hide_show_tween.kill()
	var target: Vector2 = _hand_pivot_starting_position
	match pos:
		DeckPos.PEEK:
			target += Vector2(0.0, _peek_offset_y)
		DeckPos.HIDDEN:
			target += Vector2(0.0, _hide_offset_y)
	_hide_show_tween = create_tween()
	_hide_show_tween.set_trans(Tween.TRANS_EXPO)
	_hide_show_tween.set_ease(Tween.EASE_OUT)
	_hide_show_tween.tween_property(_hand_pivot, "position", target, _hide_show_duration)


func _update_counter() -> void:
	if _hand == null:
		Verbose.error("Can't update counter, no ref to a hand !", Verbose.Category.CARD)
		return
	_card_counter_label.text = str(_hand.get_unique_card_count()) + "/" + str(_hand.max_slots)
#endregion
