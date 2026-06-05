class_name SE_Napalm
extends SkillEffect

# Talent "Napalm": augmente fortement la zone du lance-flamme (~+400%).
# Élargit le cône de particules du node "fire" (spread) et redimensionne la hitbox des
# flammes. Effet runtime : on duplique les sous-ressources par instance pour ne pas
# impacter les autres tourelles qui partagent la VFX.

@export var _fire_node_name: StringName = &"fire"
@export var _spread: float = 40.0

@export var _flame_area_name: StringName = &"Area3D"
@export var _flame_collision_size: Vector3 = Vector3(3.3, 3.8, 3.631958)


func apply(ctx: SkillContext) -> void:
	var turret: TurretFireThrower = ctx.entity as TurretFireThrower
	if turret == null:
		Verbose.error("SE_Napalm: owner is not a TurretFireThrower", Verbose.Category.ENTITY_MODULE)
		return
	_widen_fire_cone(turret)
	_resize_flame_hitbox(turret)


func _widen_fire_cone(turret: TurretFireThrower) -> void:
	var fire := turret.find_child(String(_fire_node_name), true, false) as GPUParticles3D
	if fire == null:
		Verbose.warn("SE_Napalm: node de particules introuvable: " + String(_fire_node_name), Verbose.Category.ENTITY_MODULE)
		return

	var process_material := fire.process_material as ParticleProcessMaterial
	if process_material == null:
		return
	# Dupliqué pour rester local à cette instance (la VFX partage la sous-ressource).
	var scaled: ParticleProcessMaterial = process_material.duplicate()
	scaled.spread = _spread
	fire.process_material = scaled


func _resize_flame_hitbox(turret: TurretFireThrower) -> void:
	# On passe par l'Area3D des flammes pour ne pas toucher la collision du corps.
	var area := turret.find_child(String(_flame_area_name), true, false) as Area3D
	if area == null:
		Verbose.warn("SE_Napalm: zone de flammes introuvable: " + String(_flame_area_name), Verbose.Category.ENTITY_MODULE)
		return
	var collision := area.find_child("CollisionShape3D", true, false) as CollisionShape3D
	if collision == null or not (collision.shape is BoxShape3D):
		Verbose.warn("SE_Napalm: BoxShape3D de la zone de flammes introuvable", Verbose.Category.ENTITY_MODULE)
		return
	var box: BoxShape3D = collision.shape.duplicate()
	box.size = _flame_collision_size
	collision.shape = box
