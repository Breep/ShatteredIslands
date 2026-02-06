class_name UnkillableDummy
extends Entity

## Dummy entity that cannot be killed - automatically heals when damaged

# ============================== Configuration ==============================

## Heal delay after taking damage (in seconds)
@export var heal_delay: float = 0.5

## Heal amount per tick
@export var heal_per_tick: float = 100.0

## Heal interval (how often to heal)
@export var heal_interval: float = 0.1

# ============================== Private variables ==============================

var _heal_timer: Timer
var _is_healing: bool = false
var _target_health: float = 0.0

# ============================== Modules ==============================

# ============================== Node base functions ==============================

func _ready() -> void:
	# Store initial max health as target
	_target_health = stats.health_max
	
	# Connect to health changes
	stats.health_changed.connect(_on_health_changed)
	
	# Create heal timer
	_heal_timer = Timer.new()
	_heal_timer.wait_time = heal_interval
	_heal_timer.timeout.connect(_on_heal_timer_timeout)
	add_child(_heal_timer)
	
	Verbose.debug("UnkillableDummy ready - Max HP: " + str(stats.health_max), Verbose.Category.ENTITY)


# ============================== Interaction ==============================

func take_damage(damage: float, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	var damage_taken := _interact_module.take_damage(damage, damage_type, is_critical, action_id, source)
	
	# Start healing after a delay if not already healing
	if damage_taken > 0 and not _is_healing:
		_start_healing_after_delay()
	
	return damage_taken


func take_damage_percent(percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> void:
	_interact_module.take_damage_percent(percent, percent_modifier, damage_type, is_critical, action_id, source)
	
	# Start healing after a delay if not already healing
	if not _is_healing:
		_start_healing_after_delay()


func take_condition_stacks(stacks_number: float, stack_type: Utils.StackType, is_critical: bool, action_id: StringName, source: Entity = null, duration: float = 5.0) -> float:
	return _interact_module.take_condition_stacks(stacks_number, stack_type, is_critical, action_id, source, duration)


func take_heal(heal_amount: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_heal(heal_amount, is_critical, action_id, source)


func take_cleanse(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_cleanse(value, is_critical, action_id, source)


func take_dispell(value: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	return _interact_module.take_dispell(value, is_critical, action_id, source)


# ============================== Private functions ==============================

func _start_healing_after_delay() -> void:
	# Wait for heal_delay, then start healing
	await get_tree().create_timer(heal_delay).timeout
	
	if stats.health < _target_health:
		_is_healing = true
		_heal_timer.start()
		Verbose.debug("UnkillableDummy started healing - Current: " + str(stats.health) + " / Target: " + str(_target_health), Verbose.Category.ENTITY)


func _on_heal_timer_timeout() -> void:
	if stats.health >= _target_health:
		# Fully healed, stop timer
		_heal_timer.stop()
		_is_healing = false
		Verbose.debug("UnkillableDummy fully healed - HP: " + str(stats.health), Verbose.Category.ENTITY)
		return
	
	# Heal a bit
	var heal_amount := minf(heal_per_tick, _target_health - stats.health)
	stats.health += heal_amount


func _on_health_changed(new_health: float) -> void:
	# Prevent death
	if new_health <= 0:
		stats.health = 1.0  # Keep at least 1 HP
		Verbose.debug("UnkillableDummy prevented death - HP set to 1", Verbose.Category.ENTITY)
		
		# Make sure healing is active
		if not _is_healing:
			_start_healing_after_delay()
