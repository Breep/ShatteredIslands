class_name FieldGenerator
extends Entity

enum Modifier {
	MAX_HEALTH,
	SHIELD_AMOUNT,
	SHIELD_INTERVAL,
	INITIAL_SHIELD,
	TARGET_COUNT
}

@onready var _visual: Node3D = %Visual

var _max_health: int = 1
var _shield_amount: int = 150
var _shield_interval: float = 1.0
#var _duration: float = 10.0 # Default fallback, though logic might be in manager or here.

var _target_count: int = 2
var _initial_shield: int = 150

var _shield_timer: Timer

func init(max_health: int, shield_amount: int, shield_interval: float, initial_shield: int, target_count: int) -> void:
	_max_health = max_health
	_shield_amount = shield_amount
	_shield_interval = shield_interval
	_initial_shield = initial_shield
	_target_count = target_count

func _ready() -> void:
	_visual.scale = Vector3.ZERO
	stats.health_max = _max_health
	stats.health = stats.health_max
	alterations.add_stack(Alteration.Type.SHIELD, _shield_amount, self, "Field Generator")
	
	# Visual pop
	var pop := create_tween()
	pop.tween_property(_visual, "scale", Vector3.ONE * 1.25, 0.08)
	pop.tween_property(_visual, "scale", Vector3.ONE * 1, 0.08)
	
	# Shield Timer
	if multiplayer.is_server():
		_shield_timer = Timer.new()
		_shield_timer.wait_time = _shield_interval
		_shield_timer.one_shot = false
		_shield_timer.timeout.connect(_on_shield_timer_timeout)
		add_child(_shield_timer)
		_shield_timer.start()

const GENERATOR_BEAM_SCENE: PackedScene = preload("res://02_Entities/Summons/Engineer/FieldGenerator/field_generator_beam.tscn")

var _current_targets: Array[Entity] = []
var _beams: Dictionary = {} # { entity_id (int) : FieldGeneratorBeam }

func _process(_delta: float) -> void:
	for target in _current_targets:
		if target == null or not is_instance_valid(target) or target.is_dead:
			continue
			
		if not _beams.has(target.id):
			var beam = GENERATOR_BEAM_SCENE.instantiate()
			add_child(beam)
			_beams[target.uid] = beam
			
		var beam_instance = _beams[target.uid]
		# Start from slightly above center to target center (or slightly above)
		var start = global_position + Vector3(0, 1.0, 0)
		var end = target.global_position + Vector3(0, 0.5, 0) # Approx center/chest
		beam_instance.update_beam(start, end)
		
	# Cleanup beams for lost targets
	var targets_ids = []
	for t in _current_targets:
		if t and is_instance_valid(t):
			targets_ids.append(t.uid)
			
	var ids_to_remove = []
	for target_id in _beams:
		if not target_id in targets_ids:
			ids_to_remove.append(uid)
			
	for target_id in ids_to_remove:
		if is_instance_valid(_beams[target_id]):
			_beams[target_id].queue_free()
		_beams.erase(target_id)


func _on_shield_timer_timeout() -> void:
	# Shield closest allies
	var allies: Array[Entity] = target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES)
	
	# Filter out self and sort by distance
	var valid_allies: Array[Entity] = []
	for ally in allies:
		if ally != self and is_instance_valid(ally) and not ally.is_dead:
			valid_allies.append(ally)
			
	valid_allies.sort_custom(func(a, b):
		return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
	)
	
	_current_targets.clear()
	var count = 0
	for ally in valid_allies:
		if count >= _target_count: break
		inflict_condition_stacks(ally, _shield_amount, Alteration.Type.SHIELD, "Field Generator")
		_current_targets.append(ally)
		count += 1
