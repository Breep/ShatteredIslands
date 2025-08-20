class_name Meteor
extends Node3D

var _entities_inside: Array[Entity] # Array of all character inside the area

var _owner: Entity # Owner of this healing fire area
var _target: Entity
var _ignite_stacks: int
var _damage_per_stacks: int

@export_group("Configuration")
@export var _deploy_time: float # Time for the metor to fall on the ground (in s)
@export var _radius: float # Range of the meteor impact (in m)

@onready var _effect_timer: Timer = %DeployTimer
@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var _impact_effect_area_visual: MeshInstance3D = %ImpactEffectAreaVisualBackground
@onready var _meteor_visual: Node3D = %MeteorVisual
@onready var anim_player = %AnimationPlayer
@onready var hit_marker_scene = preload("res://VFX/VFX_3D/Explosion/Scenes/VFX_Explosion_B.tscn")

#target, source, ignite_stacks, damage_per_stacks, radius
func init(target: Entity, ignite_stacks: int, damage_per_stacks: int, source: Entity = null) -> void:
	_owner = source
	_target = target
	_ignite_stacks = ignite_stacks
	_damage_per_stacks = damage_per_stacks


func _ready() -> void:
	if _target == null:
		printerr("Meteor: No target assigned to [", get_path(), "]")
		queue_free()
	
	global_position = _target.global_position
	
	(_collision_shape_3d.shape as CylinderShape3D).radius = _radius
	(_impact_effect_area_visual.mesh as CylinderMesh).top_radius = _radius 
	(_impact_effect_area_visual.mesh as CylinderMesh).bottom_radius = _radius
	var anim : Animation = anim_player.get_animation("Area")
	var track_index = anim.find_track("ImpactEffectAreaVisualBackground:mesh:bottom_radius", Animation.TYPE_VALUE)
	anim.track_set_key_value(track_index, 1, _radius)
	_meteor_visual.position.z = randf_range(-0.2,0.2)
	_meteor_visual.position.x = randf_range(-0.2,0.2)
	_meteor_visual.position.y += randf_range(-2,2)
	_effect_timer.one_shot = true
	_effect_timer.wait_time = _deploy_time
	_effect_timer.start()
	var tween = get_tree().create_tween()
	tween.tween_property(_meteor_visual, "position", Vector3.ZERO, _deploy_time)


func _on_impact_effect_area_body_entered(body: Node3D) -> void:
	if body is Character:
		_entities_inside.append(body)


func _on_impact_effect_area_body_exited(body: Node3D) -> void:
	if body is Character:
		_entities_inside.erase(body)


func _on_deploy_timer_timeout() -> void:
	var hit_marker : Node3D = hit_marker_scene.instantiate()
	get_tree().current_scene.add_child(hit_marker)
	hit_marker.global_position = global_position
	var anim_player: AnimationPlayer = hit_marker.get_node("AnimationPlayer")
	if anim_player:
		anim_player.play("Init")
	queue_free()
	if not multiplayer.is_server(): return
	
	for entity in _entities_inside:
		if entity.team != _owner.team:
			if _owner != null:
				_owner.inflict_condition_stacks(entity, _ignite_stacks, Utils.StackType.IGNITE)
				_owner.direct_attack(entity, entity.stats.ignite_stacks * _damage_per_stacks, Utils.DamageType.MAGICAL)
			else:
				entity.take_condition_stacks(_ignite_stacks, Utils.StackType.IGNITE)
				entity.take_damage(entity.stats.ignite_stacks * _damage_per_stacks, Utils.DamageType.MAGICAL)
