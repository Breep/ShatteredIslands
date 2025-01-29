class_name Projectile
extends Area2D

# ============================== Enums ==============================

enum ProjectileEffect {
	POISON,       # Add poinson stacks
	VULNERABILTY, # Add vulnerability stacks
	CRITIC,       # Do more physical damage
	BOUNCE,       # Will bounce to an other target keeping all current stats
	FIRE          # Do more damage bases on target current hp
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


# ============================== Public functions ==============================

func set_stats_from_character_aa_stats(aa_stats: CharacterAutoAttackStats) -> void:
	if _stats == null:
		_stats = AutoAttackProjectileStats.new()
	
	_stats.speed = 150
	_stats.damage = aa_stats.damage
	
	var effects = _get_effects_from_randomization(aa_stats)
	_stats.is_bouncing = true
	
	for effect_name in effects.keys():
		if effects[effect_name]["is_active"]:
			match effect_name:
				ProjectileEffect.POISON:
					_stats.poison_stacks += effects[ProjectileEffect.POISON]["stacks"]
					_stats.poison_duration = 15 # TODO Specify this duration thanks to the family lvl
				ProjectileEffect.VULNERABILTY:
					_stats.vulnerability_stacks += effects[ProjectileEffect.VULNERABILTY]["stacks"]
				ProjectileEffect.CRITIC:
					_stats.isCritic = true
					_stats.damage *= effects[effect_name]["multiplier"]
					scale *= 2
				ProjectileEffect.BOUNCE:
					_stats.is_bouncing = true
				ProjectileEffect.FIRE:
					_stats.fire_active = true
					_stats.fire_damage = effects[ProjectileEffect.FIRE]["damage"]


# TODO Trouver un meilleur endroit pour la fonction de calcul d'augmentation de chance de critic en fonction des stacks de vulnerabilitée
func get_crit_inc_from_vuln_stacks(vuln_stacks: int) -> float:
	var tau: float = 100
	return 100 * (1 - exp(- vuln_stacks / tau))

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


func _get_effects_from_randomization(aa_stats: CharacterAutoAttackStats) -> Dictionary:
	# Adapt critical chance with target vulnerability stacks
	var critical_chance : float = aa_stats.critical_multiplier
	critical_chance += get_crit_inc_from_vuln_stacks(_target.stats.vulnerability_stacks)
	critical_chance = clampf(critical_chance, 0, 100)
	
	print("CRIT CHANCE: ", critical_chance, " | Target vuln stacks: ", _target.stats.vulnerability_stacks)
	
	var effects: Dictionary = {
		ProjectileEffect.POISON: {
			"is_active": false,
			"stacks": aa_stats.poison_stacks_amount,
			"chance": aa_stats.poison_stacks_chance,
		},
		ProjectileEffect.VULNERABILTY: {
			"is_active": false,
			"stacks": aa_stats.vulnerability_stacks_amount,
			"chance": aa_stats.vulnerability_stacks_chance,
		},
		ProjectileEffect.CRITIC: {
			"is_active": false,
			"multiplier": aa_stats.critical_multiplier,
			"chance": critical_chance,
		},
		ProjectileEffect.BOUNCE: {
			"is_active": false,
			"chance": aa_stats.bounce_chance,
		},
		ProjectileEffect.FIRE: {
			"is_active": aa_stats.fire_attack_triggered,
			"damage": aa_stats.fire_attack_damage,
		},
	}
	
	for effect_name in effects.keys():
		if effects[effect_name].has("chance"):
			effects[effect_name]["is_active"] = _is_randomize_modifier_active(effects[effect_name]["chance"])
	
	return effects
