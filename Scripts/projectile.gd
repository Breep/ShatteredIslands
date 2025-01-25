class_name Projectile
extends Area2D

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

func set_stats_from_player_stats(playerStats: CharacterStats) -> void:
	if _stats == null:
		_stats = AutoAttackProjectileStats.new()
	_stats.speed = 50
	_stats.damage = playerStats.auto_attack.damage
	

#=================================== TEST 1 ================================
#
#
	var applied_effects = apply_effects_from_randomization(playerStats)
	for effect_name in applied_effects.keys():
		if applied_effects[effect_name]:
			match effect_name:
				"is_poison": _stats.poison_stacks += 1
				"is_vulnerability": _stats.vulnerability_stacks += 1
				"is_crit": _stats.isCritic = true
				"is_double_attack": _stats.double_attack = true
				
				"is_bounce": _stats.bounce += 1
			print(applied_effects)


func apply_effects_from_randomization(player_stats: CharacterStats) -> Dictionary:
	var effects: Dictionary = {
		"is_poison": false,
		"is_static_charge": false,
		"is_vulnerability": false,
		"is_necrosis": false,
		"is_ignite": false,
		"is_crit": false,
		"is_double_attack": false,
		"is_stun": false,
		"is_pacify": false
		}
	
	#var effect_mapping: Dictionary = {
		#"is_poison": player_stats.auto_attack.poison_chance,
		#"is_static_charge": player_stats.auto_attack.static_charge_chance,
		#"is_vulnerability": player_stats.auto_attack.vulnerability_chance,
		#"is_ignite": player_stats.auto_attack.ignite_chance,
		#"is_crit": player_stats.auto_attack.critical_chance,
		#"is_double_attack": player_stats.auto_attack.double_attack_chance,
		#"is_stun": player_stats.auto_attack.stun_chance,
		#"is_pacify": player_stats.auto_attack.pacify_chance
		#}
		
	#for effect_name in effect_mapping.keys():
		#effects[effect_name] = _is_randomize_modifier_active(effect_mapping[effect_name])
	return effects
