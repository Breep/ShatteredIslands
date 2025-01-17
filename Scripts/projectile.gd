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
	_stats.isCritic = _is_randomize_modifier_active(playerStats.auto_attack.critical_chance)
	if _stats.isCritic:
		_isCritic = true
		var criticalMultiplierNormalized = remap(playerStats.auto_attack.critical_multiplier, 0, 100, 1, 2) as int
		_stats.damage *= criticalMultiplierNormalized
		scale *= criticalMultiplierNormalized
