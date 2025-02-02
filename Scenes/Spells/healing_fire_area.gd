class_name HealingFireArea
extends Area2D

# ==========================================================================
# === This is the healing fire area from the card "Ring of fire healing" ===
# ==========================================================================

var _characters_inside: Array[Character] # Array of all character inside the area
var _damage_percent: float = 0 # Damage done to enemies in percent of current hp
var _heal_percent: float = 0 # heal done to allies in percent of max hp
var _source: Character # Owner of this healing fire area
var _wait_time: float # period between two ticks of the healing fire area (in seconds)
var _radius: float # Radius of the healing fire area (in m)

@onready var _effect_timer: Timer = %EffectTimer
@onready var _collision_shape_2d: CollisionShape2D = %CollisionShape2D

func init(source: Character, damage: float, heal: float, period: float, radius: float) -> void:
	print("HealingFireArea: Init")
	_source = source
	_damage_percent = damage
	_heal_percent = heal
	_wait_time = period
	_radius = radius * 20


func _enter_tree() -> void:
	print("HealingFireArea: Enter Tree")


func _ready() -> void:
	print("HealingFireArea: Ready")
	if _source == null:
		printerr("HealingFireArea: No source character assigned to")

	(_collision_shape_2d.shape as CircleShape2D).radius = _radius
	_effect_timer.wait_time = _wait_time
	_effect_timer.start()


func _on_body_entered(body: Node2D) -> void:
	if body is Character:
		print("DEBUG - ", body.player.name, " entered the healing fire area")
		_characters_inside.append(body)


func _on_body_exited(body: Node2D) -> void:
	if body is Character:
		print("DEBUG - ", body.player.name, " left the healing fire area")
		_characters_inside.erase(body)


func _on_effect_timer_timeout() -> void:
	print("HEAL AND FIRE TRIGGERED")
	for character in _characters_inside:
		if character.team == _source.team:
			#character.heal_percent(_source, _heal_percent)
			print("HEAL ", character.player.name)
		else:
			character.take_damage_percent(_source, _damage_percent, Utils.DamageType.MAGIC)
			print("DAMAGE ", character.player.name)
