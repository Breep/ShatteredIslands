class_name DarkStorm
extends Node3D

# =====================================================================================
# === This is the dark storm area from the ultimate [DarkStorm] from The DarkKnight ===
# =====================================================================================

# ============================== Private variables ==============================

var _team: int = -1 # Team of the caster
var _damage: int = -1 # Damage done to all enemies inside each tick
var _period: float = -1.0 # Time between each tick
var _lifespan: float = -1.0 # Lifespan of the spell
var _is_init: bool = false

var _entities_inside: Array[Entity] # Array of all entities inside the area

# ============================== Local nodes ==============================

@onready var _damage_tick_timer: Timer = %DamageTickTimer
@onready var _lifespan_timer: Timer = %LifespanTimer

# ============================== Node base functions ==============================

func _ready() -> void:
	if not _is_init:
		printerr("DarkStorm: Adding a non init DarkStorm to the scene [", get_path(), "]")
		queue_free()
		return
	
	_damage_tick_timer.wait_time = _period
	_damage_tick_timer.start()
	
	_lifespan_timer.wait_time = _lifespan
	_lifespan_timer.start()

# ============================== Public functions ==============================

func init(team: int, damage: int, period: float, lifespan: float) -> void:
	_team = team
	_damage = damage
	_period = period
	_lifespan = lifespan
	_is_init = true

# ============================== Callbacks ==============================

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body is Entity: return
	_entities_inside.append(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if not body is Entity: return
	_entities_inside.erase(body)


func _on_damage_tick_timer_timeout() -> void:
	for entity in _entities_inside:
		if entity.team != _team:
			entity.take_damage(_damage, Utils.DamageType.PHYSICAL)


func _on_lifespan_timer_timeout() -> void:
	queue_free()
