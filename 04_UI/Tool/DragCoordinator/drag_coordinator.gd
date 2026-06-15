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
# En-deçà de cette durée de drag, le relâchement d'un fournisseur (shop) est
# traité comme un clic court : la carte est routée vers son receveur naturel (la
# main) au lieu d'un drop spatial sous le curseur.
const _CLICK_MAX_DURATION: float = 0.2
#endregion


#region ============================== Private vars ==============================
var _containers: Array = []
var _hover_layer: CanvasLayer
var _hovering: HoveringCard
var _payload: CardPayload
var _origin: Object
var _drag_start_msec: int = 0
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
		# Le drag possède son relâchement : on le consomme pour qu'il ne retombe
		# pas en _unhandled_input (ex : fermeture du panneau shop au drop).
		get_viewport().set_input_as_handled()
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
	_drag_start_msec = Time.get_ticks_msec()
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
	var elapsed: float = float(Time.get_ticks_msec() - _drag_start_msec) / 1000.0

	# Reset l'état AVANT les callbacks de transfert (qui peuvent relancer un drag
	# ou lancer des animations).
	_hovering = null
	_payload = null
	_origin = null
	set_process(false)
	set_process_input(false)

	# Clic court depuis un fournisseur (le shop) : on ignore la position du curseur
	# et on route vers le premier receveur capable d'accueillir la carte (la main).
	# Le transfert passe par le flux normal → la carte atterrit avec l'animation de
	# la main, comme un vrai drop. Sinon : drop spatial sous le curseur.
	var is_quick_supply: bool = elapsed < _CLICK_MAX_DURATION and origin.has_method("can_supply")
	var target: Object = _find_receiver(payload, origin) if is_quick_supply else _find_target(get_viewport().get_mouse_position())

	if target == null or target == origin:
		origin.return_to_origin(payload, hovering)
	elif target.can_receive(payload):
		# Autorisation awaitée avant l'atterrissage : pour un achat, on attend la
		# réponse autoritaire de l'origine (serveur) ; la HoveringCard flotte le
		# temps de la réponse, puis atterrit (succès) ou revient (refus).
		var supplied: bool = await _authorize_supply(origin, payload)
		if supplied and target.receive(payload, hovering):
			origin.commit_removal(payload)
		else:
			origin.return_to_origin(payload, hovering)
	else:
		origin.return_to_origin(payload, hovering)

	# Feedback clear en dernier : la main qui vient d'accueillir / réordonner a
	# déjà préparé son layout, ce clear le finalise (retire les gaps résiduels).
	for container: Object in _containers:
		container.on_drag_ended()


# Si l'origine sait fournir (achat), on attend sa réponse autoritaire avant
# d'autoriser le transfert. Une origine sans commit_supply (reorder dans la main,
# vente vers le shop) est autorisée d'office.
func _authorize_supply(origin: Object, payload: CardPayload) -> bool:
	if origin != null and origin.has_method("commit_supply"):
		return await origin.commit_supply(payload)
	return true


func _find_target(mouse_global: Vector2) -> Object:
	for container: Object in _containers:
		var zone: DropZone = container.get_drop_zone()
		if zone != null and zone.contains_global(mouse_global):
			return container
	return null


# Premier conteneur (hors origine) capable d'accueillir le payload. Utilisé pour
# router un clic court vers sa destination naturelle (la main, pour un achat).
func _find_receiver(payload: CardPayload, origin: Object) -> Object:
	for container: Object in _containers:
		if container != origin and container.can_receive(payload):
			return container
	return null
#endregion
