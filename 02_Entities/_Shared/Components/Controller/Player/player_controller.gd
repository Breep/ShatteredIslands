class_name PlayerController
extends EntityController

# Controller piloté par l'input joueur. Right-click → raycast caméra :
# - hit une entité (autre que soi) → set_target sur AutoAttack
# - hit autre chose (sol, décor) → clear target + move_to la position du hit
# Pas auto-loadé : créé dynamiquement par le proto (mode MANUAL en Phase 4)
# ou dropé en éditeur pour overrider l'AIController par défaut.

#region ============================== Constants ==============================
const RAYCAST_DISTANCE: float = 1000.0
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	super._ready()
	if _owner == null or _owner.controller != self:
		return
	# Désactivé par défaut — enable() le réveille (appelé par Entity._connect_module_dependencies
	# pour les controllers auto-loadés, ou explicitement par le code qui le crée à la volée).
	set_process_unhandled_input(false)


func _exit_tree() -> void:
	# Si évincé (par AIController qui reprend la main par ex.), on coupe l'input.
	if _active:
		disable()


func _unhandled_input(event: InputEvent) -> void:
	if not _active: return
	if not (event is InputEventMouseButton): return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_RIGHT or not mb.pressed:
		return
	_handle_right_click(mb.position)
	get_viewport().set_input_as_handled()
#endregion


#region ============================== Public API ==============================
func enable() -> void:
	if _active: return
	super.enable()
	set_process_unhandled_input(true)


func disable() -> void:
	if not _active: return
	super.disable()
	set_process_unhandled_input(false)
#endregion


#region ============================== Private functions ==============================
func _handle_right_click(mouse_position: Vector2) -> void:
	var viewport: Viewport = _owner.get_viewport()
	if viewport == null:
		return
	var camera: Camera3D = viewport.get_camera_3d()
	if camera == null:
		return

	var from: Vector3 = camera.project_ray_origin(mouse_position)
	var dir: Vector3 = camera.project_ray_normal(mouse_position)
	var to: Vector3 = from + dir * RAYCAST_DISTANCE

	var space_state := _owner.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	# Exclure self : on ne veut pas cibler l'entité qu'on contrôle
	query.exclude = [_owner.get_rid()]

	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return

	var collider = result.get("collider")
	var hit_point: Vector3 = result.get("position", Vector3.ZERO)

	if collider is Entity:
		var hit_entity: Entity = collider
		if _owner.auto_attack != null:
			_owner.auto_attack.set_target(hit_entity)
			Verbose.debug("PlayerController: set_target → " + hit_entity.entity_name, Verbose.Category.ENTITY_MODULE)
	else:
		# Sol ou décor : on libère la cible et on demande un déplacement libre.
		if _owner.auto_attack != null:
			_owner.auto_attack.clear_target()
		if _owner.movement != null:
			_owner.movement.set_target_position(hit_point)
			Verbose.debug("PlayerController: move_to " + str(hit_point), Verbose.Category.ENTITY_MODULE)
#endregion
