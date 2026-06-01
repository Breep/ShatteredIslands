# Médiateur de drag-and-drop de cartes. Découple totalement les conteneurs
# (main, shop, coffre) : aucun ne référence les autres. Chaque conteneur
# s'enregistre ici ; au release, le coordinator trouve la zone de drop sous le
# curseur et oriente le transfert. Il possède la HoveringCard pendant le drag
# (dans son propre CanvasLayer haut, pour qu'elle passe au-dessus de tout) et
# diffuse l'état de survol à tous les conteneurs (feedback : gap dans la main,
# panneau de vente du shop…).
#
# Contrat attendu d'un conteneur (duck-typed) :
#   get_drop_zone() -> DropZone
#   on_drag_started(payload, origin)            # un drag commence quelque part
#   on_drag_motion(payload, mouse_global)       # appelé chaque frame du drag
#   on_drag_ended()                             # le drag est résolu, clear feedback
#   can_receive(payload) -> bool                # cible : peut accueillir ?
#   receive(payload, hovering) -> bool          # cible : encaisse + possède hovering
#   return_to_origin(payload, hovering)         # origine : reprend la carte
#   commit_removal(payload)                     # origine : retire après transfert réussi
#
# La HoveringCard finit toujours possédée soit par la cible (receive) soit par
# l'origine (return_to_origin) : c'est ce propriétaire qui la free après anim.
class_name DragCoordinator
extends Node

#region ============================== Constants ==============================
const _HOVER_LAYER: int = 128
const _HOVER_Z_INDEX: int = 200
#endregion


#region ============================== Private vars ==============================
var _containers: Array = []
var _hover_layer: CanvasLayer
var _hovering: HoveringCard
var _payload: CardPayload
var _origin: Object
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	_hover_layer = CanvasLayer.new()
	_hover_layer.layer = _HOVER_LAYER
	add_child(_hover_layer)
	set_process(false)
	set_process_input(false)


func _process(_delta: float) -> void:
	if _hovering == null:
		return
	var mouse: Vector2 = get_viewport().get_mouse_position()
	for container: Object in _containers:
		container.on_drag_motion(_payload, mouse)


func _input(event: InputEvent) -> void:
	if _hovering == null:
		return
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_resolve_drop()
#endregion


#region ============================== Public functions ==============================
func register_container(container: Object) -> void:
	if not _containers.has(container):
		_containers.append(container)


func unregister_container(container: Object) -> void:
	_containers.erase(container)


func is_dragging() -> bool:
	return _hovering != null


# Démarre un drag. L'origine fournit le payload + un CardButton déjà configuré
# pour le visuel flottant + l'offset curseur→carte. Le coordinator crée la
# HoveringCard, la parente dans son CanvasLayer haut, et prend la main.
func begin_drag(origin: Object, payload: CardPayload, visual_button: CardButton, grab_offset: Vector2) -> HoveringCard:
	if _hovering != null:
		return null
	var hovering: HoveringCard = HoveringCard.new()
	_hover_layer.add_child(hovering)
	hovering.init(visual_button, payload.merged_card, grab_offset)
	hovering.z_index = _HOVER_Z_INDEX
	_origin = origin
	_payload = payload
	_hovering = hovering
	set_process(true)
	set_process_input(true)
	for container: Object in _containers:
		container.on_drag_started(payload, origin)
	return hovering
#endregion


#region ============================== Private functions ==============================
func _resolve_drop() -> void:
	var hovering: HoveringCard = _hovering
	var payload: CardPayload = _payload
	var origin: Object = _origin
	var mouse: Vector2 = get_viewport().get_mouse_position()
	var target: Object = _find_target(mouse)

	# Reset l'état AVANT les callbacks de transfert (qui peuvent relancer un drag
	# ou lancer des animations).
	_hovering = null
	_payload = null
	_origin = null
	set_process(false)
	set_process_input(false)

	if target == null or target == origin:
		origin.return_to_origin(payload, hovering)
	elif target.can_receive(payload) and target.receive(payload, hovering):
		origin.commit_removal(payload)
	else:
		origin.return_to_origin(payload, hovering)

	# Feedback clear en dernier : la main qui vient d'accueillir / réordonner a
	# déjà préparé son layout, ce clear le finalise (retire les gaps résiduels).
	for container: Object in _containers:
		container.on_drag_ended()


func _find_target(mouse_global: Vector2) -> Object:
	for container: Object in _containers:
		var zone: DropZone = container.get_drop_zone()
		if zone != null and zone.contains_global(mouse_global):
			return container
	return null
#endregion
