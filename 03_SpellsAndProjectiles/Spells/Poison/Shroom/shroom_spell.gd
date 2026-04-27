class_name Shroom
extends Spell

var _source: Entity
var _target: Entity

var _enemies: Array[Entity]

var _life_time: float
var _radius: float
var _damage: int

const FIGHTING_AREA_SIZE := Vector2(20, 10)

@onready var _shroom_visual: Node3D = %ShroomVisual
@onready var _area_of_effect_collision_shape_3d: CollisionShape3D = %AreaOfEffectCollisionShape3D

func init(source: Entity, target: Entity, damage: int, radius: float, life_time: float) -> void:
	_source = source
	_target = target
	_damage = damage
	_radius = radius
	_life_time = life_time


func _ready() -> void:
	_spawn_at_random_spot()
	var cyl := _area_of_effect_collision_shape_3d.shape as CylinderShape3D
	if cyl: cyl.radius = _radius
	_shroom_visual.scale = Vector3.ONE * 0.05
	_animate()


func _spawn_at_random_spot() -> void:
	var center := Vector3(0, 0, 0)
	var half_w := FIGHTING_AREA_SIZE.x * 0.5
	var half_d := FIGHTING_AREA_SIZE.y * 0.5

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var dx := rng.randf_range(-half_w, half_w)
	var dz := rng.randf_range(-half_d, half_d)

	position = Vector3(center.x + dx, center.y, center.z + dz)


func _animate() -> void:
	var tween := create_tween()
	tween.tween_property(_shroom_visual, "scale", Vector3.ONE, _life_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_explode)


func _explode() -> void:
	var pop := create_tween()
	pop.tween_property(_shroom_visual, "scale", Vector3.ONE * 1.25, 0.08)
	pop.tween_property(_shroom_visual, "scale", Vector3.ZERO, 0.08)
	for enemy in _enemies:
		if enemy == null or enemy.is_queued_for_deletion(): continue
		_source.damage.direct(enemy, _damage, Utils.ActionType.DAMAGE_POISON, "Shroom")
	_add_temporary_cylinder_and_kill_self()


func _add_temporary_cylinder_and_kill_self() -> void:
	var radius_mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = _radius
	cylinder.bottom_radius = _radius
	cylinder.height = 0.2
	radius_mesh.mesh = cylinder
	radius_mesh.material_override = StandardMaterial3D.new()
	radius_mesh.material_override.albedo_color = Color(0.2, 1.0, 0.2, 0.4)
	radius_mesh.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	add_child(radius_mesh)
	radius_mesh.global_position = global_position + Vector3(0, 0.1, 0)

	# Fade out the cylinder mesh quickly, then free everything
	var fade := create_tween()
	fade.tween_property(radius_mesh.material_override, "albedo_color:a", 0.0, 0.4)
	fade.finished.connect(func():
		queue_free()
	)


func _on_area_of_effect_body_entered(body: Node3D) -> void:
	if not body is Entity or body.is_queued_for_deletion(): return
	var entity: Entity = body
	if entity.team != _source.team and not _enemies.has(entity):
		_enemies.append(entity)


func _on_area_of_effect_body_exited(body: Node3D) -> void:
	if not body is Entity or body.is_queued_for_deletion(): return
	var entity: Entity = body
	if _enemies.has(entity):
		_enemies.erase(entity)
