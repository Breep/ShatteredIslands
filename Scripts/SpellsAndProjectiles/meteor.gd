class_name Meteor
extends Node3D

var _characters_inside: Array[Character] # Array of all character inside the area

var _source: Character # Owner of this healing fire area
var _damage_percent: int # Meteor damage (in % of enemy current hp)
var _deploy_time: float # Time for the metor to fall on the ground (in s)
var _radius: float # Range of the meteor impact (in m)

@onready var _effect_timer: Timer = %DeployTimer
@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var _impact_effect_area_visual: MeshInstance3D = %ImpactEffectAreaVisual
@onready var _meteor_visual: MeshInstance3D = %MeteorVisual

func init(source: Character, damage_percent: float, deploy_time: float, radius: float) -> void:
	_source = source
	_damage_percent = damage_percent
	_deploy_time = deploy_time
	_radius = radius


func _ready() -> void:
	if _source == null:
		printerr("HealingFireArea: No source character assigned to")

	(_collision_shape_3d.shape as CylinderShape3D).radius = _radius
	(_impact_effect_area_visual.mesh as CylinderMesh).top_radius = _radius
	(_impact_effect_area_visual.mesh as CylinderMesh).bottom_radius = _radius
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
			_source.attack_percent(character, _damage_percent, Utils.DamageType.MAGIC, Utils.PercentModifier.MAX_HP)
	queue_free()
