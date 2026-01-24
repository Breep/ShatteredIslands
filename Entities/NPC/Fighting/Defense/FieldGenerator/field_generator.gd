class_name FieldGenerator
extends Entity

@onready var _interact_module: InteractModule = %InteractModule
@onready var _action_module: ActionModule = %ActionModule
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
	stats.shield_stacks = _initial_shield
	stats.health_changed.connect(_on_stats_health_changed)
	
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

func _on_stats_health_changed(new_health: int) -> void:
	if new_health <= 0:
		signal_death()
		queue_free()

const GENERATOR_BEAM_SCENE: PackedScene = preload("res://Entities/NPC/Fighting/Defense/FieldGenerator/field_generator_beam.tscn")

var _current_targets: Array[Entity] = []
var _beams: Dictionary = {} # { entity_id (int) : FieldGeneratorBeam }

func _process(delta: float) -> void:
	for target in _current_targets:
		if target == null or not is_instance_valid(target) or target.is_dead:
			continue
			
		if not _beams.has(target.id):
			var beam = GENERATOR_BEAM_SCENE.instantiate()
			add_child(beam)
			_beams[target.id] = beam
			
		var beam_instance = _beams[target.id]
		# Start from slightly above center to target center (or slightly above)
		var start = global_position + Vector3(0, 1.0, 0)
		var end = target.global_position + Vector3(0, 0.5, 0) # Approx center/chest
		beam_instance.update_beam(start, end)
		
	# Cleanup beams for lost targets
	var targets_ids = []
	for t in _current_targets:
		if t and is_instance_valid(t):
			targets_ids.append(t.id)
			
	var ids_to_remove = []
	for id in _beams:
		if not id in targets_ids:
			ids_to_remove.append(id)
			
	for id in ids_to_remove:
		if is_instance_valid(_beams[id]):
			_beams[id].queue_free()
		_beams.erase(id)


func _on_shield_timer_timeout() -> void:
	# Shield closest allies
	var allies: Array[Entity] = target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
	
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
		_action_module.inflict_condition_stacks(ally, _shield_amount, Utils.StackType.SHIELD, "Field Generator")
		_current_targets.append(ally)
		count += 1

#region ===== Action / Interaction Delegation
func inflict_condition_stacks(target: Entity, stacks_number: float, stack_type: Utils.StackType, action_id: StringName, duration: float = 5.0) -> void:
	_action_module.inflict_condition_stacks(target, stacks_number, stack_type, action_id, duration)

func take_damage(damage: float, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_damage(damage, damage_type, is_critical, action_id, source)

func take_damage_percent(percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> void:
	_interact_module.take_damage_percent(percent, percent_modifier, damage_type, is_critical, action_id, source)

func take_condition_stacks(stacks_number: float, stack_type: Utils.StackType, is_critical: bool, action_id: StringName, source: Entity = null, duration: float = 5.0) -> float:
	return _interact_module.take_condition_stacks(stacks_number, stack_type, is_critical, action_id, source, duration)

func take_heal(heal_amount: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_heal(heal_amount, is_critical, action_id, source)

func take_cleanse(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_cleanse(value, is_critical, action_id, source)

func take_dispell(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_dispell(value, is_critical, action_id, source)
#endregion

func connect_to_fighting_area(fighting_area: FightingArea) -> void:
	_action_module.connect_to_spawn_manager(fighting_area.spawn_manager)
