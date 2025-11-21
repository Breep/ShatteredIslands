class_name Meteor
extends Node3D

var _entities_inside: Array[Entity] # Array of all character inside the area

var _owner: Entity # Owner of this healing fire area
var _target: Entity
var _ignite_stacks: int
var _damage_per_stacks: int

@export_group("Configuration")
@export var _deploy_time: float # Time for the metor to fall on the ground (in s)
#@export var _radius: float = 3.0 # Range of the meteor impact (in m)

@onready var _effect_timer: Timer = %DeployTimer
@onready var _meteor_visual: Node3D = %MeteorVisual
@onready var hit_marker_scene = preload("res://VFX/VFX_3D/Explosion/Scenes/VFX_Explosion_B.tscn")
@onready var audio_player = $AudioStreamPlayer3D


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
		return
	
	global_position = _target.global_position
	var lateral_range = 2.0   
	var vertical_range = 0.3 
	_meteor_visual.position.x = randf_range(-lateral_range, lateral_range)
	_meteor_visual.position.z = randf_range(-lateral_range, lateral_range)
	_meteor_visual.position.y += randf_range(-vertical_range, vertical_range)
	var dir: Vector3 = (_meteor_visual.global_position - global_position).normalized()
	var tilt_x = clamp(dir.x * 1.0, -1.0, 1.0) 
	var tilt_z = clamp(dir.z * 1.0, -1.0, 1.0) 
	_meteor_visual.rotation_degrees = Vector3(180.0, 0.0, 0.0)
	_meteor_visual.rotate_x(deg_to_rad(tilt_x * 45.0)) 
	_meteor_visual.rotate_z(deg_to_rad(tilt_z * 45.0)) 
	_effect_timer.one_shot = true
	_effect_timer.wait_time = _deploy_time
	_effect_timer.start()
	var tween = create_tween()
	var wait_ratio = randf_range(0.8, 0.95)
	tween.tween_interval(_deploy_time * wait_ratio)
	tween.tween_property(_meteor_visual, "position", Vector3.ZERO, _deploy_time * (1.0 - wait_ratio))\
		 .set_trans(Tween.TRANS_QUAD)\
		 .set_ease(Tween.EASE_IN)


func _on_impact_effect_area_body_entered(body: Node3D) -> void:
	if body is Character:
		_entities_inside.append(body)


func _on_impact_effect_area_body_exited(body: Node3D) -> void:
	if body is Character:
		_entities_inside.erase(body)


func _on_deploy_timer_timeout() -> void:
	if _owner == null or _owner.is_queued_for_deletion(): return
	#var hit_marker : Node3D = hit_marker_scene.instantiate()
	#get_tree().current_scene.add_child(hit_marker)
	#hit_marker.global_position = global_position
	#var anim_player: AnimationPlayer = hit_marker.get_node("AnimationPlayer")
	#if anim_player:
		#anim_player.play("Init")
	#print("DEBUG -- SHOULD BEING DESTROYED")
	queue_free()
	if not multiplayer.is_server(): return
	
	for entity in _entities_inside:
		if entity == null or entity.is_queued_for_deletion(): pass
		elif entity.team != _owner.team:
			if _owner != null:
				_owner.inflict_condition_stacks(entity, _ignite_stacks, Utils.StackType.IGNITE)
				_owner.direct_attack(entity, entity.stats.ignite_stacks * _damage_per_stacks, Utils.DamageType.MAGICAL)
			else:
				entity.take_condition_stacks(_ignite_stacks, Utils.StackType.IGNITE, false)
				entity.take_damage(entity.stats.ignite_stacks * _damage_per_stacks, Utils.DamageType.MAGICAL)


func play_impact_sound():
	return
	# On détache le nœud audio de son parent actuel (la scène Meteor)
	# Il ne sera donc plus détruit quand on appellera queue_free() sur le météore.
	#remove_child(audio_player)
	#get_tree().get_root().add_child(audio_player)
	#audio_player.volume_db = randf_range(-9, -5)
	#audio_player.pitch_scale = randf_range(0.6, 1.4)
	#audio_player.play()
	#audio_player.finished.connect(audio_player.queue_free)
