class_name AutoAttackPeriodicModule
extends Module

# ============================== Signals ==============================

signal target_changed(new_target: Entity)

# ============================== Private variables ==============================

var _attack_speed: float = 1.0
var attack_speed: float:
	get: return _attack_speed
	set(value):
		if _attack_speed == value: return
		_attack_speed = value
		_set_auto_attack_speed(_attack_speed)

var _paused_time_left: float = -1.0

var _attack_strategy: TargetModule.TargettingStrategy = TargetModule.TargettingStrategy.RANDOM_ENEMY

var _current_target: Entity
var current_target: Entity:
	get: return _current_target
	set(value):
		if current_target != value:
			target_changed.emit(value)
			_current_target = value

# Module references
var _auto_attack_module: ActionSenderAutoAttackModule = null

# ============================== Local scene nodes ==============================

@onready var _auto_attack_timer: Timer = Timer.new()

# ============================== Node base function ==============================

func _ready() -> void:
	if _owner == null:
		Verbose.error("AutoAttackPeriodicManager needs an owner (Entity)", Verbose.Category.ENTITY_MODULE)
		return
	
	# Setup timer
	add_child(_auto_attack_timer)
	_auto_attack_timer.one_shot = true
	_auto_attack_timer.timeout.connect(_on_auto_attack_timer_timeout)
	
	# Connect signals
	_owner.stats.attack_speed_changed.connect(_on_owner_stats_attack_speed_changed)
	_owner.died.connect(_on_owner_died)
	_owner.auto_attack_completed.connect(_on_owner_auto_attack_completed)
	
	if _owner.status_module != null:
		_owner.status_module.stunned_changed.connect(_on_owner_stunned_changed)


func connect_modules(auto_attack_module: ActionSenderAutoAttackModule) -> void:
	_auto_attack_module = auto_attack_module


# ============================== Public functions ==============================

func start() -> void:
	Verbose.debug("AutoAttackPeriodicManager started for " + _owner.entity_name, Verbose.Category.ENTITY_MODULE)
	attack_speed = _owner.stats.attack_speed
	_auto_attack_timer.start()


func stop() -> void:
	Verbose.debug("AutoAttackPeriodicManager stopped for " + _owner.entity_name, Verbose.Category.ENTITY_MODULE)
	_auto_attack_timer.stop()
	if _auto_attack_module != null:
		_auto_attack_module.stop_approaching()


# ============================== Private functions ==============================

func _set_auto_attack_speed(new_attack_speed: float) -> void:
	if new_attack_speed <= 0:
		Verbose.error("Attack speed is <= 0", Verbose.Category.ENTITY_MODULE)
		_auto_attack_timer.wait_time = 1.0
	else:
		_auto_attack_timer.wait_time = 1.0 / new_attack_speed


func _process(_delta: float) -> void:
	# Check distance during approach
	if _auto_attack_module == null:
		return
	
	if _auto_attack_module.is_approaching() and _auto_attack_module.get_approach_target() != null:
		var approach_target: Entity = _auto_attack_module.get_approach_target()
		
		# Check if target still valid
		if not is_instance_valid(approach_target) or approach_target.is_dead():
			_auto_attack_module.stop_approaching()
			_auto_attack_timer.start()
			return
		
		# Check if now in range (or infinite range)
		var distance: float = _owner.global_position.distance_to(approach_target.global_position)
		if _owner.stats.attack_range <= 0 or distance <= _owner.stats.attack_range:
			# In range! Stop approach and attack
			var target_to_attack: Entity = approach_target
			_auto_attack_module.stop_approaching()
			_auto_attack_module.execute_auto_attack(target_to_attack)
			_auto_attack_timer.start()


# ============================== Callbacks ==============================

func _on_auto_attack_timer_timeout() -> void:
	if not is_instance_valid(_owner):
		return
	
	if _auto_attack_module == null:
		return
	
	var target: Entity = _owner.target_module.get_target(_attack_strategy)
	if target == null:
		return
	
	current_target = target
	_auto_attack_module.execute_auto_attack(target)


func _on_owner_stats_attack_speed_changed(new_attack_speed: float) -> void:
	attack_speed = new_attack_speed


func _on_owner_died(_unused) -> void:
	stop()


func _on_owner_auto_attack_completed(_entity: Entity) -> void:
	print("DEBUG AutoAttackPeriodicModule: _on_owner_auto_attack_completed")
	_auto_attack_timer.start()


func _on_owner_stunned_changed(is_active: bool, _duration: float, _infinite: bool) -> void:
	if is_active:
		_auto_attack_timer.stop()
	else:
		_auto_attack_timer.start()
