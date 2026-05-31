# UI de la main du joueur : affiche les cartes d'une Hand sous forme d'éventail
# façon Hearthstone. Sous _straight_threshold cartes elles restent droites et
# alignées ; au-delà, elles s'arrangent sur un arc dont l'écartement angulaire
# croît légèrement avec le nombre de cartes (spread = base + a*sqrt(N)).
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
@export var _max_cards: int = 15
@export var _card_scale: float = 0.5
@export var _card_button_scene: PackedScene

@export_group("Anim")
@export var _layout_tween_duration: float = 0.25

@export_group("Internal")
@export var _hand_pivot: Control
@export var _editor_preview_root: Control
#endregion


#region ============================== Private vars ==============================
var _hand: Hand
var _card_buttons: Dictionary[StringName, CardButton] = {}
var _layout_tweens: Dictionary[StringName, Tween] = {}
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	if _editor_preview_root != null:
		_editor_preview_root.queue_free()
		_editor_preview_root = null
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
	_hand.has_changed.connect(_on_hand_changed)
	_rebuild_all()


func unbind() -> void:
	if _hand == null:
		return
	_hand.card_added.disconnect(_on_hand_card_added)
	_hand.card_removed.disconnect(_on_hand_card_removed)
	_hand.has_changed.disconnect(_on_hand_changed)
	_hand = null
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
	btn.remove_shader()
	_card_buttons[card.name] = btn
	return btn


func _layout_all() -> void:
	if _hand == null:
		return
	var cards: Array[Card] = _hand.get_cards_raw()
	var n: int = cards.size()
	for i: int in n:
		var card: Card = cards[i]
		var btn: CardButton = _card_buttons.get(card.name)
		if btn == null:
			continue
		var t: Dictionary = _compute_card_transform(i, n)
		_tween_card_to(card.name, btn, t["position"], t["rotation"])


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


func _tween_card_to(card_name: StringName, btn: CardButton, target_pos: Vector2, target_rot: float) -> void:
	var existing: Tween = _layout_tweens.get(card_name)
	if existing != null and existing.is_running():
		existing.kill()
	var tween: Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(btn, "position", target_pos, _layout_tween_duration)
	tween.tween_property(btn, "rotation", target_rot, _layout_tween_duration)
	_layout_tweens[card_name] = tween
#endregion


#region ============================== Callbacks ==============================
func _on_hand_card_added(card: Card) -> void:
	if not _card_buttons.has(card.name):
		_create_card_button(card)
	_layout_all()


func _on_hand_card_removed(card: Card) -> void:
	var btn: CardButton = _card_buttons.get(card.name)
	if btn != null:
		var tween: Tween = _layout_tweens.get(card.name)
		if tween != null and tween.is_running():
			tween.kill()
		_layout_tweens.erase(card.name)
		btn.queue_free()
		_card_buttons.erase(card.name)
	_layout_all()


# Couvre les cas où une carte présente change (level up, duplicat ré-ajouté…)
# sans ajout ni retrait de slot.
func _on_hand_changed() -> void:
	if _hand == null:
		return
	for card: Card in _hand.get_cards_raw():
		var btn: CardButton = _card_buttons.get(card.name)
		if btn != null:
			btn.update_visual(card)
#endregion
