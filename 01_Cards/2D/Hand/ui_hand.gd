# UI de la main du joueur : affiche les cartes d'une Hand sous forme d'éventail
# façon Hearthstone. Sous _straight_threshold cartes elles restent droites et
# alignées ; au-delà, elles s'arrangent sur un arc dont l'écartement angulaire
# croît légèrement avec le nombre de cartes (spread = base + a*sqrt(N)). Au
# survol d'une carte : la carte se redresse + grossit + monte, les voisines
# s'écartent (décroissance exponentielle), et un preview agrandi apparaît près
# du curseur après un délai. Au clic gauche sur une carte : la carte sort de la
# main et flotte sous la souris (HoveringCard) ; le release la replace soit dans
# la main à l'index visé (Rect2 drop zone), soit en fin (hors zone).
class_name UIHand
extends Control

#region ============================== Signals ==============================
signal card_clicked(card: Card)
#endregion


#region ============================== Export ==============================
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
## Zone (en coords écran) considérée comme « dans la main » : un release dedans
## insère la carte à l'index calculé, dehors la carte revient en fin de main.
@export var _drop_zone_rect: Rect2 = Rect2(0.0, 680.0, 1920.0, 400.0)
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
@export var _hide_show_button: Button

@export_group("HideShow")
@export var _hide_show_duration: float = 0.5
@export var _hide_offset_y: float = 350.0
#endregion

#region ============================== Internals ==============================
@onready var _card_counter_label: RichTextLabel = %CardCounterLabel
@onready var _warning_hand_full_label: RichTextLabel = %WarningHandFullLabel

#region ============================== Private vars ==============================
var _hand: Hand
var _card_buttons: Dictionary[StringName, CardButton] = {}
var _layout_tweens: Dictionary[StringName, Tween] = {}

var _hovered_card: Card
# Epoch incrémenté à chaque démarrage de timer de preview ; les timeouts
# obsolètes (mouse a quitté la carte avant la fin) sont ignorés via cette valeur.
var _preview_epoch: int = 0
var _preview_instance: CardButton

var _dragging: HoveringCard
# Index visuel du gap pendant un drag : -1 = hors zone (pas de gap, layout
# normal sur N-1 cartes) ; sinon position cible (0..N) dans un layout N visuel.
var _drop_index: int = -1
# Quand true, _layout_all() est court-circuité. Utilisé pour grouper plusieurs
# mutations de la main (re-add + reorder au drop) sans déclencher de layouts
# intermédiaires : un seul layout final part de la position courante des boutons.
var _batch_mode: bool = false

var _hand_pivot_starting_position: Vector2
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	set_process(false)
	if _editor_preview_root != null:
		_editor_preview_root.queue_free()
		_editor_preview_root = null
	_hand_pivot_starting_position = _hand_pivot.position


func _process(_delta: float) -> void:
	if _dragging == null:
		return
	var mouse: Vector2 = get_global_mouse_position()
	var new_index: int = -1
	if _drop_zone_rect.has_point(mouse):
		new_index = _compute_drop_index(mouse)
	if new_index != _drop_index:
		_drop_index = new_index
		_layout_all(_hover_layout_duration)


func _input(event: InputEvent) -> void:
	if _dragging == null:
		return
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_finalize_drag()
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
	_hide_preview()
	_cancel_drag()
	_clear_all_card_buttons()
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
	btn.card_selected.connect(_on_card_button_selected)
	_card_buttons[card.name] = btn
	return btn


# `duration < 0` => utilise _layout_tween_duration. Les callbacks de hover passent
# _hover_layout_duration pour une réaction plus snappy.
func _layout_all(duration: float = -1.0) -> void:
	if _batch_mode:
		return
	if _hand == null:
		return
	_sync_child_order()
	var effective_duration: float = duration if duration >= 0.0 else _layout_tween_duration
	# La carte tenue (drag en cours) est exclue : get_visible_cards filtre.
	var cards: Array[Card] = _hand.get_visible_cards()
	var n_real: int = cards.size()
	var dragging: bool = _dragging != null
	var has_gap: bool = dragging and _drop_index >= 0
	var n_visual: int = n_real + (1 if has_gap else 0)
	# Hover suspendu pendant un drag : pas de lift + scale, pas de spread.
	var hovered_index: int = -1 if dragging else _find_hovered_index(cards)

	var visual_index: int = 0
	for i: int in n_real:
		if has_gap and visual_index == _drop_index:
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
	# Itère sur les cartes visibles uniquement : la tenue (drag) n'a pas de
	# bouton dans _hand_pivot — son visuel vit dans la HoveringCard.
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


func _start_drag(card: Card) -> void:
	if _dragging != null or card == null:
		return
	var btn: CardButton = _card_buttons.get(card.name)
	if btn == null:
		return

	# Capture l'offset cursor→centre visuel AVANT hold (le bouton sera freed
	# par _on_hand_card_held).
	var grab_offset: Vector2 = btn.global_position - get_global_mouse_position()

	# L'index initial = position d'origine de la carte dans le dict complet.
	# Le gap apparaîtra à cet index, et un release sans déplacement remettra
	# la carte exactement où elle était.
	var cards: Array[Card] = _hand.get_cards_raw()
	var original_index: int = -1
	for i: int in cards.size():
		if cards[i].name == card.name:
			original_index = i
			break
	if original_index < 0:
		return

	# La carte n'est PAS retirée de la main : on la marque comme « tenue ».
	# Données préservées (level, sources, position dans le dict). Seul le
	# visuel quitte le fan vers la HoveringCard.
	if not _hand.hold_card(card):
		return

	# Le hover et le bouton sont nettoyés par _on_hand_card_held.
	var visual_button: CardButton = _card_button_scene.instantiate()
	var hovering: HoveringCard = HoveringCard.new()
	add_child(hovering)
	hovering.init(visual_button, card, grab_offset)
	hovering.z_index = 200
	_dragging = hovering
	_drop_index = original_index
	set_process(true)
	_layout_all(_hover_layout_duration)


func _finalize_drag() -> void:
	if _dragging == null:
		return
	var merged_card: Card = _dragging.get_merged_card()
	var final_drop_index: int = _drop_index
	# Capture la position globale + scale de la HoveringCard pour que la carte
	# droppée parte exactement de là (au lieu de pop à la position par défaut
	# du _hand_pivot puis de tween).
	var drop_origin_global: Vector2 = _dragging.global_position
	var drop_origin_scale: Vector2 = _dragging.get_card_button().scale

	_dragging.queue_free()
	_dragging = null
	_drop_index = -1
	set_process(false)

	if merged_card == null:
		_layout_all()
		return

	# Pré-crée le bouton à la position courante de la HoveringCard. Le futur
	# _on_hand_card_released verra que _card_buttons contient déjà ce nom et
	# n'en créera pas un nouveau au default.
	_batch_mode = true
	var dropped_btn: CardButton = _create_card_button(merged_card)
	dropped_btn.global_position = drop_origin_global
	dropped_btn.scale = drop_origin_scale
	# Pendant l'atterrissage, on garde la carte au-dessus pour qu'elle reste
	# visible quel que soit sa place finale dans le z-order du fan.
	dropped_btn.z_index = _drop_landing_z_index

	# La carte n'a jamais quitté la main côté données. On reorder si on est
	# dans la drop zone (sinon elle reprend simplement sa position d'origine),
	# puis on lâche le hold.
	if final_drop_index >= 0:
		_hand.reorder_card(merged_card.name, final_drop_index)
	_hand.release_held_card()

	_batch_mode = false
	_layout_all()

	# Reset du z_index à la fin du tween. On utilise un Timer plutôt que
	# tween.finished : un nouveau layout (ex: hover) pourrait kill le tween
	# avant son terme, dans ce cas finished ne firera jamais.
	get_tree().create_timer(_layout_tween_duration).timeout.connect(
		_on_drop_landing_finished.bind(dropped_btn)
	)


func _cancel_drag() -> void:
	if _dragging == null:
		return
	_dragging.queue_free()
	_dragging = null
	_drop_index = -1
	set_process(false)


func _compute_drop_index(mouse_global: Vector2) -> int:
	if _hand == null:
		return 0
	# N visuel = nombre de cartes visibles + 1 (le gap où atterrirait le drop).
	# La tenue n'est pas comptée puisqu'elle n'est pas dans le fan.
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
	# Si la carte retirée était en cours de drag (vente / coffre déclenché
	# pendant le drag plus tard), on cancel le drag pour éviter une
	# HoveringCard orpheline.
	if _dragging != null:
		var merged: Card = _dragging.get_merged_card()
		if merged != null and merged.name == card.name:
			_cancel_drag()
	if _hovered_card != null and _hovered_card.name == card.name:
		_hovered_card = null
		_cancel_preview_timer()
		_hide_preview()
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
# sans ajout ni retrait de slot. Itère les cartes visibles + rafraîchit le
# visuel de la HoveringCard si on est en plein drag (la carte tenue peut
# avoir changé de level pendant le drag).
func _on_hand_changed() -> void:
	if _hand == null:
		return
	for card: Card in _hand.get_visible_cards():
		var btn: CardButton = _card_buttons.get(card.name)
		if btn != null:
			btn.update_visual(card)
	if _dragging != null:
		var held: Card = _hand.get_held_card()
		if held != null:
			_dragging.get_card_button().update_visual(held)


# La carte vient d'être marquée comme tenue : on free son bouton du fan
# (le visuel vit maintenant dans la HoveringCard), on nettoie le hover si
# elle était survolée. Les données restent en main.
func _on_hand_card_held(card: Card) -> void:
	if _hovered_card != null and _hovered_card.name == card.name:
		_hovered_card = null
		_cancel_preview_timer()
		_hide_preview()
	var btn: CardButton = _card_buttons.get(card.name)
	if btn != null:
		var tween: Tween = _layout_tweens.get(card.name)
		if tween != null and tween.is_running():
			tween.kill()
		_layout_tweens.erase(card.name)
		btn.queue_free()
		_card_buttons.erase(card.name)
	_layout_all()


# La carte tenue est rendue au fan. Si _finalize_drag a déjà pré-créé le
# bouton (cas standard), rien à faire d'autre. Sinon (release externe), on
# crée le bouton au default ; _layout_all positionnera.
func _on_hand_card_released(card: Card) -> void:
	if card == null:
		return
	if not _card_buttons.has(card.name) and _dragging == null:
		_create_card_button(card)
	_layout_all()


func _on_card_button_mouse_entered(card: Card) -> void:
	if _dragging != null:
		return
	if card == null:
		return
	_hovered_card = card
	_start_preview_timer(card)
	_layout_all(_hover_layout_duration)


func _on_card_button_mouse_exited(card: Card) -> void:
	if _dragging != null:
		return
	if _hovered_card == null or _hovered_card.name != card.name:
		return
	_hovered_card = null
	_cancel_preview_timer()
	_hide_preview()
	_layout_all(_hover_layout_duration)


func _on_card_button_selected(_button: CardButton, card: Card) -> void:
	if _dragging != null:
		return
	_start_drag(card)


func _on_preview_timer_timeout(card: Card, epoch: int) -> void:
	if epoch != _preview_epoch:
		return
	if _hovered_card == null or _hovered_card.name != card.name:
		return
	_show_preview(card)


func _on_drop_landing_finished(dropped_btn: CardButton) -> void:
	if is_instance_valid(dropped_btn):
		dropped_btn.z_index = 0


var _warning_tween: Tween
func _on_hand_card_addition_refused(card: Card, reason: Hand.RefusalReason) -> void:
	match reason:
		Hand.RefusalReason.CARD_ALREADY_MAXED_OUT:
			AudioManager.play_ui("error_01")
			var btn: CardButton = _card_buttons.get(card.name)
			if btn != null:
				if _warning_tween != null and _warning_tween.is_valid():
					_warning_tween.kill()
				_warning_tween = create_tween()
				_warning_tween.tween_property(btn, "modulate", Color.RED, 0.15).set_trans(Tween.TRANS_SINE)
				_warning_tween.tween_property(btn, "modulate", Color.WHITE, 0.15).set_trans(Tween.TRANS_SINE)
		Hand.RefusalReason.HAND_IS_FULL:
			AudioManager.play_ui("error_02")
			var counter_tween: Tween = create_tween()
			counter_tween.tween_property(_card_counter_label, "modulate", Color.RED, 0.1)
			counter_tween.tween_property(_card_counter_label, "modulate", Color.WHITE, 0.1)
			counter_tween.tween_property(_card_counter_label, "modulate", Color.RED, 0.1)
			counter_tween.tween_property(_card_counter_label, "modulate", Color.WHITE, 0.1)
			if _warning_hand_full_label != null:
				if _warning_tween != null and _warning_tween.is_valid():
					_warning_tween.kill()
				_warning_tween = create_tween()
				_warning_hand_full_label.visible = true
				_warning_hand_full_label.modulate.a = 0.0 # Départ transparent
				_warning_tween.tween_property(_warning_hand_full_label, "modulate:a", 1.0, 0.2)
				_warning_tween.tween_interval(2.0)
				_warning_tween.tween_property(_warning_hand_full_label, "modulate:a", 0.0, 0.3)
				_warning_tween.tween_callback(func() -> void: _warning_hand_full_label.visible = false)
#endregion


var _hide_show_tween: Tween
var _is_visible: bool = true
func _on_hide_show_button_pressed() -> void:
	if _hide_show_tween != null and _hide_show_tween.is_valid():
		_hide_show_tween.kill()
	_hide_show_tween = create_tween()
	_hide_show_tween.set_trans(Tween.TRANS_EXPO)
	_hide_show_tween.set_ease(Tween.EASE_OUT)
	if _is_visible:
		var hidden_position = _hand_pivot_starting_position + Vector2(0, _hide_offset_y)
		_hide_show_tween.tween_property(_hand_pivot, "position", hidden_position, _hide_show_duration)
		_hide_show_button.text = "Afficher Deck"
		_is_visible = false
	else:
		_hide_show_tween.tween_property(_hand_pivot, "position", _hand_pivot_starting_position, _hide_show_duration)
		_hide_show_button.text = "Masquer Deck"
		_is_visible = true


func _update_counter() -> void:
	if _hand == null:
		Verbose.error("Can't update counter, no ref to a hand !", Verbose.Category.CARD)
		return
	_card_counter_label.text = str(_hand.get_unique_card_count()) + "/" + str(_hand.max_slots)
