extends Node3D

const LATERAL_RANGE: float = 20.0
const VERTICAL_RANGE: float = 0.3

@onready var _meteor_3d: Node3D = %MeteorVisual3D
@onready var hit_marker_scene = preload("res://SpellsAndProjectiles/Spells/Meteor/Visual/VFX_Explosion_B.tscn")

var _deploy_time: float = 2 #time to hit ground
	
func _ready() -> void:
	_init_pos()
	var tween = create_tween()
	tween.tween_property(_meteor_3d, "position", Vector3.ZERO, _deploy_time)\
		 .set_trans(Tween.TRANS_QUAD)\
		 .set_ease(Tween.EASE_IN)
		
	tween.tween_callback(_on_deploy_timer_timeout)

func _init_pos() -> void:
	_meteor_3d.position.x = randf_range(-LATERAL_RANGE, LATERAL_RANGE)
	_meteor_3d.position.z = randf_range(-LATERAL_RANGE, LATERAL_RANGE)
	_meteor_3d.position.y += randf_range(-VERTICAL_RANGE, VERTICAL_RANGE)
	_meteor_3d.look_at(global_position)
	
func _on_deploy_timer_timeout() -> void:
	var hit_marker : Node3D = hit_marker_scene.instantiate()
	get_tree().current_scene.add_child(hit_marker)
	hit_marker.global_position = global_position
	var anim_player: AnimationPlayer = hit_marker.get_node("AnimationPlayer")
	if anim_player:
		anim_player.play("Init")
