class_name DeathFog
extends Node3D

var _grow_speed: float           # world-units per second (applied to BoxShape3D.size.x)
var _tick_period: float          # seconds between poison ticks
var _damage_multiplier: float    # stacks = floor(exposure_seconds * multiplier)
var _source: Entity

@onready var _collision_shape_left: CollisionShape3D  = %CollisionShapeLeft
@onready var _collision_shape_right: CollisionShape3D = %CollisionShapeRight
@onready var _visual: Node3D = %DeathSmokeVisual
@onready var _tick_timer: Timer = %TickTimer

var _exposure_seconds: Dictionary[Entity, float] = {}
var _stopped: bool = false

const FIGHTING_AREA_SIZE := Vector2(20, 10) # x=width, y=depth(Z)

func init(source: Entity, grow_speed: float, tick_period: float, damage_multiplier: float) -> void:
	_source = source
	_grow_speed = grow_speed
	_tick_period = tick_period
	_damage_multiplier = damage_multiplier

func _ready() -> void:
	var half_width := FIGHTING_AREA_SIZE.x * 0.5

	# Ensure shapes are BoxShape3D
	var left_box  : BoxShape3D = _collision_shape_left.shape  as BoxShape3D
	var right_box : BoxShape3D = _collision_shape_right.shape as BoxShape3D
	if left_box == null or right_box == null:
		push_error("DeathFog requires BoxShape3D on both CollisionShape3D nodes.")
		set_process(false)
		return

	# Initialize: width=0, full Z depth, anchored at borders
	left_box.size  = Vector3(0.0, left_box.size.y,  FIGHTING_AREA_SIZE.y)
	right_box.size = Vector3(0.0, right_box.size.y, FIGHTING_AREA_SIZE.y)

	_collision_shape_left.position  = Vector3(-half_width, _collision_shape_left.position.y,  0.0)
	_collision_shape_right.position = Vector3(+half_width, _collision_shape_right.position.y, 0.0)

	# Start ticking
	_tick_timer.one_shot = false
	_tick_timer.wait_time = max(0.05, _tick_period)
	_tick_timer.start()

	# Kick visual sync once
	_update_visual()

	# === Tween growth to the center ===
	var target_extent := half_width               # each side will cover half the arena
	var duration = max(0.001, target_extent / max(0.001, _grow_speed))

	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Left side: grow extent 0 -> half_width
	tween.tween_method(_set_left_extent, 0.0, target_extent, duration)

	# Right side: grow extent 0 -> half_width (run in parallel)
	tween.parallel().tween_method(_set_right_extent, 0.0, target_extent, duration)

	tween.finished.connect(_on_growth_finished)

func _process(delta: float) -> void:
	# Exposure accumulation (growth is handled by tween)
	for entity: Entity in _exposure_seconds.keys():
		if entity == null or not is_instance_valid(entity) or entity.is_queued_for_deletion():
			continue
		_exposure_seconds[entity] += delta

# --- Tweened setters (extent = BoxShape3D.size.x) ----------------------

func _set_left_extent(extent: float) -> void:
	var half_width := FIGHTING_AREA_SIZE.x * 0.5
	var box: BoxShape3D = _collision_shape_left.shape as BoxShape3D
	if box == null: return

	# Update box size (X grows, Z fixed to full depth)
	box.size = Vector3(max(0.0, extent), box.size.y, FIGHTING_AREA_SIZE.y)
	# Anchor to left border: x = -half_width + extent/2
	_collision_shape_left.position.x = -half_width + (box.size.x * 0.5)

	_update_visual()

func _set_right_extent(extent: float) -> void:
	var half_width := FIGHTING_AREA_SIZE.x * 0.5
	var box: BoxShape3D = _collision_shape_right.shape as BoxShape3D
	if box == null: return

	box.size = Vector3(max(0.0, extent), box.size.y, FIGHTING_AREA_SIZE.y)
	# Anchor to right border: x = +half_width - extent/2
	_collision_shape_right.position.x = +half_width - (box.size.x * 0.5)

	_update_visual()

func _on_growth_finished() -> void:
	_stopped = true
	# Snap precisely to center to avoid epsilon gaps
	_collision_shape_left.position.x = 0.0
	_collision_shape_right.position.x = 0.0
	# Ensure final extents are exactly half the arena width
	var half_width := FIGHTING_AREA_SIZE.x * 0.5
	var left_box  : BoxShape3D = _collision_shape_left.shape  as BoxShape3D
	var right_box : BoxShape3D = _collision_shape_right.shape as BoxShape3D
	if left_box:  left_box.size.x  = half_width
	if right_box: right_box.size.x = half_width
	_update_visual()

# --- Tick & stacks -----------------------------------------------------

func _on_tick_timer_timeout() -> void:
	var to_remove: Array = []
	for entity: Entity in _exposure_seconds.keys():
		if entity == null or not is_instance_valid(entity) or entity.is_queued_for_deletion():
			to_remove.append(entity)
			continue
		var exposure: float = _exposure_seconds[entity]
		var poison_stacks: int = int(floor(exposure * _damage_multiplier))
		if _source != null:
			_source.inflict_condition_stacks(entity, poison_stacks, Utils.StackType.POISON)
		else:
			entity.take_condition_stacks(poison_stacks, Utils.StackType.POISON, false)
	for e in to_remove:
		_exposure_seconds.erase(e)

# --- Visual sync -------------------------------------------------------

func _update_visual() -> void:
	if _visual and _visual.has_method("mirror_from_collision_shapes"):
		_visual.mirror_from_collision_shapes(_collision_shape_left, _collision_shape_right)

# --- Entity tracking ---------------------------------------------------

func _on_scanner_area_body_entered(body: Node3D) -> void:
	if not (body is Entity): return
	var entity: Entity = body
	if entity.is_queued_for_deletion(): return
	if _source != null and entity.team == _source.team: return
	if not _exposure_seconds.has(entity):
		_exposure_seconds[entity] = 0.0

func _on_scanner_area_body_exited(body: Node3D) -> void:
	if not (body is Entity): return
	var ent: Entity = body
	_exposure_seconds.erase(ent)
