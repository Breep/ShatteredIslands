# Carte « flottante » qui suit la souris pendant un drag-and-drop depuis UIHand.
# Encapsule à la fois le visuel (CardButton désactivé, mouse_filter IGNORE pour
# ne pas intercepter la souris) et la donnée (cartes source niveau 1 prélevées
# de la main + la carte agrégée affichée). UIHand pilote le press/release.
class_name HoveringCard
extends Control

#region ============================== Export ==============================
## Scale appliqué au CardButton enfant (ex: 0.55 = ~10 % de plus que les cartes
## en main quand UIHand._card_scale = 0.5).
@export var _scale: float = 0.55
## Vitesse de poursuite de la souris : plus haut = plus snappy. 0 = snap dur.
@export var _follow_smoothness: float = 5.0
#endregion


#region ============================== Private vars ==============================
var _merged_card: Card
var _source_cards: Array[Card]
# Offset cursor → root au moment du grab : on conserve cet écart pour que la
# carte reste accrochée à l'endroit cliqué, peu importe où la souris bouge.
var _grab_offset: Vector2
var _card_button: CardButton
#endregion


#region ============================== Public functions ==============================
func init(card_button: CardButton, merged_card: Card, source_cards: Array[Card], grab_offset: Vector2) -> void:
	_card_button = card_button
	_merged_card = merged_card
	_source_cards = source_cards
	_grab_offset = grab_offset
	add_child(_card_button)
	_card_button.update_visual(_merged_card)
	_card_button.set_hover_enabled(false)
	_card_button.set_hover_audio_enabled(false)
	_card_button.remove_shader()
	_card_button.scale = Vector2(_scale, _scale)
	_disable_mouse_recursive(_card_button)


func get_merged_card() -> Card:
	return _merged_card


func get_source_cards() -> Array[Card]:
	return _source_cards


func get_card_button() -> CardButton:
	return _card_button
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	global_position = get_global_mouse_position() + _grab_offset


func _process(delta: float) -> void:
	var target: Vector2 = get_global_mouse_position() + _grab_offset
	if _follow_smoothness <= 0.0:
		global_position = target
	else:
		global_position = global_position.lerp(target, clampf(10.0 * delta, 0.0, 1.0))
#endregion


#region ============================== Private functions ==============================
func _disable_mouse_recursive(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child: Node in node.get_children():
		_disable_mouse_recursive(child)
#endregion
