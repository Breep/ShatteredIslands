class_name FireGround
extends Spell

## Zone de sol enflammé : inflige périodiquement des stacks d'ignite aux ennemis
## présents dans la zone, pendant une durée limitée. Calquée sur Shroom (Area3D
## qui suit les corps entrants/sortants) + ticks via Timer.

var _source: Entity
var _spawn_pos: Vector3
var _radius: float
var _duration: float
var _ignite_per_tick: float
var _tick_period: float

var _enemies: Array[Entity] = []

@onready var _area_collision: CollisionShape3D = %AreaOfEffectCollisionShape3D
@onready var _visual: Node3D = %FireVisual

func init(source: Entity, spawn_pos: Vector3, radius: float, duration: float, ignite_per_tick: float, tick_period: float) -> void:
	_source = source
	_spawn_pos = spawn_pos
	_radius = radius
	_duration = duration
	_ignite_per_tick = ignite_per_tick
	_tick_period = tick_period


func _ready() -> void:
	# La position d'impact du projectile peut être à hauteur du corps touché : on
	# plaque la zone au sol pour qu'elle ne flotte pas au-dessus des monstres.
	_spawn_pos.y = 0.0
	global_position = _spawn_pos

	# Rayon de la zone (duplique la shape pour ne pas contaminer les autres instances).
	if _area_collision != null and _area_collision.shape is CylinderShape3D:
		var cyl: CylinderShape3D = _area_collision.shape.duplicate()
		cyl.radius = _radius
		_area_collision.shape = cyl

	if _visual != null:
		_visual.scale = Vector3(_radius, 1.0, _radius)

	var tick := Timer.new()
	tick.wait_time = _tick_period
	tick.one_shot = false
	tick.autostart = true
	tick.timeout.connect(_on_tick)
	add_child(tick)

	var life := Timer.new()
	life.wait_time = _duration
	life.one_shot = true
	life.autostart = true
	life.timeout.connect(queue_free)
	add_child(life)


func _on_tick() -> void:
	if _source == null or not is_instance_valid(_source):
		return
	for enemy in _enemies:
		if enemy == null or not is_instance_valid(enemy) or enemy.is_queued_for_deletion(): continue
		_source.alterations.inflict_condition_stacks(enemy, _ignite_per_tick, Alteration.Type.IGNITE, &"Fire Ground")


func _on_area_of_effect_body_entered(body: Node3D) -> void:
	if not body is Entity or body.is_queued_for_deletion(): return
	var entity: Entity = body
	if _source != null and entity.team != _source.team and not _enemies.has(entity):
		_enemies.append(entity)


func _on_area_of_effect_body_exited(body: Node3D) -> void:
	if not body is Entity: return
	_enemies.erase(body)
