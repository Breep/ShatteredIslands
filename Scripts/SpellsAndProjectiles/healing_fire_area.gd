class_name HealingFireArea
extends Area3D

# ==========================================================================
# === This is the healing fire area from the card "Ring of fire healing" ===
# ==========================================================================

var _source: Character # Owner of this healing fire area
var _action_module: ActionModule # Owner ActionModule ref
var _characters_inside: Array[Character] # Array of all character inside the area
var _damage_percent: float = 0 # Damage done to enemies in percent of current hp
var _heal_percent: float = 0 # heal done to allies in percent of max hp
var _wait_time: float # period between two ticks of the healing fire area (in seconds)
var _radius: float # Radius of the healing fire area (in m)

@onready var _effect_timer: Timer = %EffectTimer
@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape2D
@onready var tmp_debug_mesh: MeshInstance3D = %HealingFireVisual

func init(source: Character, damage: float, heal: float, period: float, radius: float) -> void:
	_source = source
	_damage_percent = damage
	_heal_percent = heal
	_wait_time = period
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
	(tmp_debug_mesh.mesh as CylinderMesh).top_radius = _radius
	(tmp_debug_mesh.mesh as CylinderMesh).bottom_radius = _radius
	_effect_timer.wait_time = _wait_time
	_effect_timer.start()


func _on_body_entered(body: Node3D) -> void:
	if body is Character:
		_characters_inside.append(body)


func _on_body_exited(body: Node3D) -> void:
	if body is Character:
		_characters_inside.erase(body)


func _on_effect_timer_timeout() -> void:
	for character in _characters_inside:
		if character.team == _source.team:
			_action_module.heal_percent(character, _heal_percent, Utils.PercentModifier.MAX_HP)
		else:
			_action_module.direct_attack_percent(character, _damage_percent, Utils.DamageType.MAGICAL, Utils.PercentModifier.CURRENT_HP)
