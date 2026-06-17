## Liste des unités du roaster du joueur, affichée en phase de placement.
## Les unités non placées sont listées en premier et cliquables ; cliquer ramène
## l'unité (spawnée hors-écran) à la souris et lance son drag. Un drop sur la zone
## d'équipe valide la pose (entry.placed) ; un drop hors zone la renvoie hors-écran.
class_name UIRoasterList
extends Control

# ============================== Signals ==============================

# Émis quand une unité est posée ou renvoyée (pour réévaluer le gating du combat).
signal placement_changed

# ============================== Constants ==============================

const PORTRAIT_BUTTON_SCENE: PackedScene = preload("res://04_UI/InGame/RoasterList/EntityPortraitButton/ui_entity_portrait_button.tscn")
const _SLIDE_DURATION: float = 0.3
# Marge ajoutée à la largeur du panneau pour le sortir complètement à gauche.
const _HIDDEN_MARGIN: float = 50.0

# ============================== Local nodes ==============================

@onready var _list: VBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer
@onready var _panel: PanelContainer = $PanelContainer

# ============================== Private variables ==============================

var _roaster: Roaster
var _fighting_area: FightingArea

# Position de repos du panneau (capturée au 1er open/close, avant tout slide).
var _shown_x: float
var _shown_x_captured: bool = false
var _slide_tween: Tween

# ============================== Public functions ==============================

# Lie la liste à un roaster et à la fighting area courante (pour retrouver les
# entités spawnées et la caméra). Reconstruit l'affichage.
func setup(roaster: Roaster, fighting_area: FightingArea) -> void:
	_disconnect_roaster()
	_roaster = roaster
	_fighting_area = fighting_area
	_connect_roaster()
	_rebuild()


func has_unplaced() -> bool:
	if _roaster == null:
		return false
	for entry: RoasterEntry in _roaster.all_entries():
		if entry != null and not entry.placed:
			return true
	return false


# Affiche la liste en la faisant glisser depuis la gauche jusqu'à sa place.
func open() -> void:
	_capture_shown_x()
	_kill_slide()
	_panel.position.x = _hidden_x()
	show()
	_slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_slide_tween.tween_property(_panel, "position:x", _shown_x, _SLIDE_DURATION)


# Fait glisser la liste hors écran vers la gauche puis la masque.
func close() -> void:
	_capture_shown_x()
	_kill_slide()
	_slide_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_slide_tween.tween_property(_panel, "position:x", _hidden_x(), _SLIDE_DURATION)
	_slide_tween.tween_callback(hide)

# ============================== Private functions ==============================

func _capture_shown_x() -> void:
	if _shown_x_captured:
		return
	_shown_x = _panel.position.x
	_shown_x_captured = true


func _hidden_x() -> float:
	var width: float = maxf(_panel.size.x, _panel.custom_minimum_size.x)
	return _shown_x - width - _HIDDEN_MARGIN


func _kill_slide() -> void:
	if _slide_tween != null and _slide_tween.is_valid():
		_slide_tween.kill()

func _rebuild() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	if _roaster == null:
		return
	for entry: RoasterEntry in _sorted_entries():
		var button: UIEntityPortraitButton = PORTRAIT_BUTTON_SCENE.instantiate()
		_list.add_child(button)
		button.setup(entry)
		button.pressed_down.connect(_on_entry_pressed)
		button.released.connect(_on_entry_released)


# Non placées d'abord, ordre du roaster préservé dans chaque groupe.
func _sorted_entries() -> Array[RoasterEntry]:
	var unplaced: Array[RoasterEntry] = []
	var placed: Array[RoasterEntry] = []
	for entry: RoasterEntry in _roaster.all_entries():
		if entry == null:
			continue
		if entry.placed:
			placed.append(entry)
		else:
			unplaced.append(entry)
	var result: Array[RoasterEntry] = []
	result.append_array(unplaced)
	result.append_array(placed)
	return result


func _find_entity(entry: RoasterEntry) -> Entity:
	if _fighting_area == null or _fighting_area.spawn_manager == null:
		return null
	for entity: Entity in _fighting_area.spawn_manager.get_entities():
		if entity != null and entity.entry == entry:
			return entity
	return null


# Projette la souris sur le plan du sol (y=0) pour poser l'entité dessous.
func _mouse_ground_position() -> Vector3:
	var viewport: Viewport = get_viewport()
	var camera: Camera3D = viewport.get_camera_3d() if viewport != null else null
	if camera == null:
		return Vector3.ZERO
	var mouse_pos: Vector2 = viewport.get_mouse_position()
	var plane := Plane(Vector3.UP, 0.0)
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var dir: Vector3 = camera.project_ray_normal(mouse_pos)
	var hit: Variant = plane.intersects_ray(from, dir)
	return hit if hit != null else Vector3.ZERO


func _connect_roaster() -> void:
	if _roaster == null:
		return
	if not _roaster.entry_added.is_connected(_on_roaster_changed):
		_roaster.entry_added.connect(_on_roaster_changed)
	if not _roaster.entry_removed.is_connected(_on_roaster_changed):
		_roaster.entry_removed.connect(_on_roaster_changed)


func _disconnect_roaster() -> void:
	if _roaster == null:
		return
	if _roaster.entry_added.is_connected(_on_roaster_changed):
		_roaster.entry_added.disconnect(_on_roaster_changed)
	if _roaster.entry_removed.is_connected(_on_roaster_changed):
		_roaster.entry_removed.disconnect(_on_roaster_changed)

# ============================== Callbacks ==============================

# Appui sur le portrait : ramène l'entité sous la souris et démarre son drag.
func _on_entry_pressed(entry: RoasterEntry) -> void:
	if entry == null or entry.placed:
		return
	var entity: Entity = _find_entity(entry)
	if entity == null:
		Verbose.warn("UIRoasterList: pas d'entité spawnée pour l'entry sélectionnée", Verbose.Category.GAME)
		return
	if entity.draggable == null:
		Verbose.warn("UIRoasterList: entité sans DraggableComponent [" + entity.entity_name + "]", Verbose.Category.GAME)
		return
	entity.draggable.drop_committed.connect(_on_drop_committed.bind(entry), CONNECT_ONE_SHOT)
	entity.draggable.begin_drag_at(_mouse_ground_position())


# Relâchement du bouton : on lâche le drag en cours (drop). Le placement final est
# résolu par _on_drop_committed (via drop_committed émis dans le stop du drag).
func _on_entry_released(entry: RoasterEntry) -> void:
	if entry == null:
		return
	var entity: Entity = _find_entity(entry)
	if entity != null and entity.draggable != null and entity.draggable.is_dragging():
		entity.draggable.end_drag()


func _on_drop_committed(on_valid_zone: bool, entry: RoasterEntry) -> void:
	if on_valid_zone:
		entry.placed = true
	else:
		var entity: Entity = _find_entity(entry)
		if entity != null:
			entity.global_position = FightingArea.OFF_SCREEN_SPAWN_POSITION
	_rebuild()
	placement_changed.emit()


func _on_roaster_changed(_entry: RoasterEntry) -> void:
	_rebuild()
	placement_changed.emit()
