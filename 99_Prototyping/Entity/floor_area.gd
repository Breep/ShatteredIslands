class_name FloorArea
extends Area3D

# Surface "sol" cliquable du proto. Émet Events.floor_clicked(position) au right-click
# et affiche un marqueur visuel temporaire à l'emplacement (feedback "ordre reçu").
# Le PlayerController écoute ce signal pour déclencher un move_to sur l'entité contrôlée.

#region ============================== Constants ==============================
const CLICK_INDICATOR_DURATION_S: float = 1.0
const CLICK_INDICATOR_RADIUS: float = 0.25
const CLICK_INDICATOR_HEIGHT: float = 0.05
const CLICK_INDICATOR_COLOR: Color = Color(1.0, 0.85, 0.2, 1.0)
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
#endregion


#region ============================== Callbacks ==============================
func _on_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton): return
	var mb := event as InputEventMouseButton
	if not mb.pressed: return
	if mb.button_index != MOUSE_BUTTON_RIGHT: return

	Events.floor_clicked.emit(event_position)
	_spawn_click_indicator(event_position)
	Verbose.debug("FloorArea: floor_clicked @ " + str(event_position), Verbose.Category.ENTITY)


func _on_mouse_entered() -> void:
	# TODO debug visual : suivi curseur au survol du sol
	pass


func _on_mouse_exited() -> void:
	# TODO debug visual : retirer suivi curseur
	pass
#endregion


#region ============================== Private functions ==============================
# Cylindre plat à l'emplacement du clic, auto-détruit après CLICK_INDICATOR_DURATION_S.
func _spawn_click_indicator(world_position: Vector3) -> void:
	var indicator := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = CLICK_INDICATOR_RADIUS
	mesh.bottom_radius = CLICK_INDICATOR_RADIUS
	mesh.height = CLICK_INDICATOR_HEIGHT
	indicator.mesh = mesh

	var mat := StandardMaterial3D.new()
	mat.albedo_color = CLICK_INDICATOR_COLOR
	mat.emission_enabled = true
	mat.emission = CLICK_INDICATOR_COLOR
	mat.emission_energy_multiplier = 1.5
	indicator.material_override = mat

	add_child(indicator)
	indicator.global_position = world_position + Vector3(0, CLICK_INDICATOR_HEIGHT * 0.5, 0)

	get_tree().create_timer(CLICK_INDICATOR_DURATION_S).timeout.connect(indicator.queue_free)
#endregion
