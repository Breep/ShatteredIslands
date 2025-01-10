extends Area2D
class_name Projectile

# ============================== Private ==============================

var _target: Player
var _speed: float = 50
const _SPEED_MIN: float = 0.3
var _dammage: int
const _DAMMAGE_MIN: int = 1

var _isCritic: bool

# ============================== Public ==============================

var speed: float:
	get:
		return _speed
	set(value):
		if value < _SPEED_MIN:
			_speed = _SPEED_MIN
		else:
			_speed = value

var target: Player:
	get:
		return _target
	set(value):
		if value == null:
			printerr("Trying to instantiate a projectile with no target !")
		else:
			_target = value

var damage: int:
	get:
		return _dammage
	set(value):
		if value < _DAMMAGE_MIN:
			_dammage = _DAMMAGE_MIN
		else:
			_dammage = value

# ============================== Node base functions ==============================

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	_moveTowardTarget(delta)

# ============================== Private functions ==============================

func _moveTowardTarget(delta: float):
	if _target == null:
		printerr("Projectile [", name, "] is alive but with no target")
		return
	
	var direction: Vector2 = (_target.global_position - global_position).normalized()
	position += direction * _speed * delta
	look_at(_target.global_position)

func _isRandomizeModifierActive(chance: float) -> bool:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf_range(0, 100) <= chance

# ============================== public functions ==============================

func setStatFromPlayerStats(playerStats: CharacterStats) -> void:
	damage = playerStats.autoAttack.damage
	_isCritic = _isRandomizeModifierActive(playerStats.autoAttack.critical_chance)
	if _isCritic:
		var criticalMultiplierNormalized = remap(playerStats.autoAttack.critical_multiplier, 0, 100, 1, 2)
		damage *= criticalMultiplierNormalized
		scale *= criticalMultiplierNormalized

# ============================== Collision functions ==============================

func _on_body_entered(body: Node2D) -> void:
	if body is Player and body == _target:
		queue_free()
