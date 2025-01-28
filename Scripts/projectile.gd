class_name Projectile
extends Area2D

# ============================== Enums ==============================

enum ProjectileEffect {
	POISON,
	VULNERABILTY,
	CRITIC,
	BOUNCE
}

#TODO Rajouter un projectile_visual

# ============================== Constants ==============================

const _SPEED_MIN: float = 0.3
const _DAMMAGE_MIN: int = 1

# ============================== Public ==============================

var target: Character:
	get:
		return _target
	set(value):
		if value == null:
			printerr("Trying to instantiate a projectile with no target !")
		else:
			_target = value

var source: Character:
	get:
		return _source
	set(value):
		if value == null:
			printerr("Trying to instantiate a projectile with no source !")
		else:
			_source = value

var stats: AutoAttackProjectileStats:
	get:
		return _stats
	set(value):
		if value == null:
			printerr("Trying to set a projectile stats to null")
		else:
			_stats = value

# ============================== Private ==============================

var _source: Character
var _target: Character
var _isCritic: bool

var _stats: AutoAttackProjectileStats

# ============================== Node base functions ==============================

func _ready() -> void:
	if (_stats == null):
		_stats = AutoAttackProjectileStats.new()


func _process(delta: float) -> void:
	_move_toward_target(delta)


func _on_body_entered(body: Node2D) -> void:
	if body is Character and body == _target:
		if _target != null:
			_target.hit_by_auto_attack(_source, _stats)
		
		queue_free()

# ============================== Private functions ==============================

func _move_toward_target(delta: float):
	if _target == null:
		printerr("Projectile [", name, "] is alive but with no target")
		return
	
	var direction: Vector2 = (_target.global_position - global_position).normalized()
	position += direction * _stats.speed * delta
	look_at(_target.global_position)
	
func _is_randomize_modifier_active(chance: float) -> bool:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf_range(0, 100) <= chance

# ============================== Public functions ==============================

func set_stats_from_character_stats(character_stats: CharacterStats) -> void:
	if _stats == null:
		_stats = AutoAttackProjectileStats.new()
	
	_stats.speed = 150
	_stats.damage = character_stats.auto_attack.damage
	
	var effects = get_effects_from_randomization(character_stats)
	_stats.isBouncing = true
	
	for effect_name in effects.keys():
		if effects[effect_name]["is_active"]:
			match effect_name:
				ProjectileEffect.POISON:
					_stats.poison_stacks += effects[effect_name]["stacks"]
					_stats.poison_duration = 15 # TODO Specify this duration thanks to the family lvl
				ProjectileEffect.VULNERABILTY:
					_stats.vulnerability_stacks += effects[effect_name]["stacks"]
					_stats.vulnerability_duration = 5 # TODO Should be a global constant
				ProjectileEffect.CRITIC:
					_stats.isCritic = true
					_stats.damage *= effects[effect_name]["multiplier"]
					scale *= 2
				ProjectileEffect.BOUNCE:
					_stats.isBouncing = true


func get_effects_from_randomization(character_stats: CharacterStats) -> Dictionary:
	var effects: Dictionary = {
		ProjectileEffect.POISON: {
			"is_active": false,
			"stacks": character_stats.auto_attack.poison_stacks_amount,
			"chance": character_stats.auto_attack.poison_stacks_chance,
		},
		ProjectileEffect.VULNERABILTY: {
			"is_active": false,
			"stacks": character_stats.auto_attack.vulnerability_stacks_amount,
			"chance": character_stats.auto_attack.vulnerability_stacks_chance,
		},
		ProjectileEffect.CRITIC: {
			"is_active": false,
			"multiplier": character_stats.auto_attack.critical_multiplier,
			"chance": character_stats.auto_attack.critical_chance,
		},
		ProjectileEffect.BOUNCE: {
			"is_active": false,
			"chance": character_stats.auto_attack.bounce_chance,
		},
	}
	
	for effect_name in effects.keys():
		effects[effect_name]["is_active"] = _is_randomize_modifier_active(effects[effect_name]["chance"])
	
	return effects
