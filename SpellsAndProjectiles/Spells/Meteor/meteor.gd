class_name Meteor
extends Node3D

var _characters_inside: Array[Character] # Array of all character inside the area

var _source: Character # Owner of this healing fire area
var _action_module: ActionModule # Owner ActionModule ref (needed to deal damages accordingly to owner upgrades) # TODO probably rework this shit
var _damage_percent: float # Meteor damage (in % of enemy current hp)
var _deploy_time: float # Time for the metor to fall on the ground (in s)
var _radius: float # Range of the meteor impact (in m)

@onready var _effect_timer: Timer = %DeployTimer
@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var _impact_effect_area_visual: MeshInstance3D = %ImpactEffectAreaVisualBackground
@onready var _meteor_visual: Node3D = %MeteorVisual
@onready var anim_player = %AnimationPlayer
@onready var hit_marker_scene = preload("res://VFX/VFX_3D/Hit_marker/vfx_hit_meteor.tscn")

func init(source: Character, damage_percent: float, deploy_time: float, radius: float) -> void:
	_source = source
	_damage_percent = damage_percent
	_deploy_time = deploy_time
	_radius = radius
	var action_modules = _source.find_children("", "ActionModule", true, false)
	if action_modules.is_empty():
		printerr("Meteor: An ActionModule is mandatory on the owner")
		return
	_action_module = action_modules[0]


func _ready() -> void:
	if _source == null:
		printerr("HealingFireArea: No source character assigned to")

	(_collision_shape_3d.shape as CylinderShape3D).radius = _radius
	(_impact_effect_area_visual.mesh as CylinderMesh).top_radius = _radius 
	(_impact_effect_area_visual.mesh as CylinderMesh).bottom_radius = _radius
	var anim : Animation = anim_player.get_animation("Area")
	var track_index = anim.find_track("ImpactEffectAreaVisualBackground:mesh:bottom_radius", Animation.TYPE_VALUE)
	anim.track_set_key_value(track_index, 1, _radius)
	print(_radius)
	_meteor_visual.position.z = randf_range(-5,5)
	_meteor_visual.position.x = randf_range(-5,5)
	_meteor_visual.position.y += randf_range(0,3)
	_effect_timer.one_shot = true
	_effect_timer.wait_time = _deploy_time
	_effect_timer.start()
	var tween = get_tree().create_tween()
	tween.tween_property(_meteor_visual, "position", Vector3.ZERO, _deploy_time)


func _on_impact_effect_area_body_entered(body: Node3D) -> void:
	if body is Character:
		_characters_inside.append(body)


func _on_impact_effect_area_body_exited(body: Node3D) -> void:
	if body is Character:
		_characters_inside.erase(body)


func _on_deploy_timer_timeout() -> void:
	for character in _characters_inside:
		if character.team != _source.team:
			_action_module.direct_attack_percent(character, _damage_percent, Utils.DamageType.MAGICAL, Utils.PercentModifier.MAX_HP)
	
	var hit_marker : Node3D = hit_marker_scene.instantiate()
	get_tree().current_scene.add_child(hit_marker)
	hit_marker.global_position = global_position
	queue_free()
