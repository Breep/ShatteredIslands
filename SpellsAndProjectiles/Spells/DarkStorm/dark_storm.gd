class_name DarkStorm
extends Node3D

# =====================================================================================
# === This is the dark storm area from the ultimate [DarkStorm] from The DarkKnight ===
# =====================================================================================

# ============================== Constant ==============================

const MAX_RANDOM_XY: float = 1.5

# ============================== Private variables ==============================

var _damage: int = -1 # Damage done to all enemies inside each tick
var _period: float = -1.0 # Time between each tick
var _lifespan: float = -1.0 # Lifespan of the spell
var _is_init: bool = false
var _pain_percent: float = 1.0

var _entities_inside: Array[Entity] # Array of all entities inside the area

var _source: Entity # Caster
var _target: Entity # Target (used for location)

# ============================== Local nodes ==============================

@onready var _damage_tick_timer: Timer = %DamageTickTimer
@onready var _lifespan_timer: Timer = %LifespanTimer

# ============================== Node base functions ==============================

func _ready() -> void:
	if not _is_init:
		printerr("DarkStorm: Adding a non init DarkStorm to the scene [", get_path(), "]")
		queue_free()
		return
	
	var a: float = Utils.rng.randf_range(0, 1)
	var b: float = Utils.rng.randf_range(-1, 1)
	var d: float = Utils.rng.randf_range(-MAX_RANDOM_XY, MAX_RANDOM_XY)
	var vec := Vector3(a, 0, b).normalized()
	global_position = _target.global_position + d * vec
	
	_damage_tick_timer.wait_time = _period
	_damage_tick_timer.start()
	
	_lifespan_timer.wait_time = _lifespan
	_lifespan_timer.start()

# ============================== Public functions ==============================

func init(target: Entity, damage: int, period: float, lifespan: float, source: Entity, pain_percent: float = 0.0) -> void:
	_target = target
	_damage = damage
	_period = period
	_lifespan = lifespan
	_source = source
	_is_init = true
	_pain_percent = pain_percent

# ============================== Callbacks ==============================

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body is Entity: return
	_entities_inside.append(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if not body is Entity: return
	_entities_inside.erase(body)


func _on_damage_tick_timer_timeout() -> void:
	for entity in _entities_inside:
		if _source != null and entity.team != _source.team:
			var damage: float = _damage
			if _pain_percent > 0.0:
				damage = damage * (1.0 + entity.conditions.get_total_stacks() * _pain_percent / 100.0)
			_source.direct_damage(entity, int(round(damage)), Utils.ActionType.DAMAGE_PHYSICAL, "Dark Storm")


func _on_lifespan_timer_timeout() -> void:
	queue_free()
