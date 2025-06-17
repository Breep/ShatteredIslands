class_name PoisonManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _poison_stats: CharacterPoisonStats # Ref to the owner poison stats

# ============================== Spells scenes ==============================

@onready var _poison_cloud_area_scene: PackedScene = preload("res://SpellsAndProjectiles/Spells/PoisonCloud/poison_cloud_area.tscn")

# ============================== Local scenes ==============================

@onready var _poison_tick_timer:Timer = %PoisonTickTimer

# ============================== Public functions ==============================

func _ready() -> void:
	_poison_stats = source.stats.poison


func start() -> void:
	print("STARTING POISON MANAGER")
	_lanch_optional_spells()
	_create_optional_timers()
	_poison_tick_timer.start()


func stop() -> void:
	print("PoisonManager: STOP")
	for spell in _optional_spells:
		spell.queue_free()
	_poison_stats.poison_stacks = 0
	_poison_tick_timer.stop()
	_clear_optional_timers()


func get_reduced_damage(damage: int) -> int:
	return (damage - damage * _poison_stats.poison_resist / 100.0) as int

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	print("PoisonManager: CREATING OPTIONAL TIMERS")
	# [PERIODICA AGARICUS]
	if _poison_stats.periodica_agaricus_activated:
		print("PoisonManager: CREATING PERIODICA AGARICUS TIMER")
		_optional_timers.append(Utils.create_perpetual_timer(self, _poison_stats.periodica_agaricus_period, _on_periodica_agaricus_timer_timeout, true))


func _clear_optional_timers() -> void:
	for timer in _optional_timers:
		timer.queue_free()


func _lanch_optional_spells() -> void:
	# [Poison cloud]
	if _poison_stats.poison_cloud_activated:
		var poison_cloud_area: PoisonCloudArea = _poison_cloud_area_scene.instantiate()
		poison_cloud_area.init(source, _poison_stats.poison_cloud_stacks_number, _poison_stats.poison_cloud_stacks_period, _poison_stats.poison_cloud_range)
		source.add_child(poison_cloud_area)
		poison_cloud_area.position = Vector3.ZERO
		_optional_spells.append(poison_cloud_area)

# ============================== Callbacks functions ==============================

# Handle poison stacks and damage on source
func _on_poison_tick_timer_timeout() -> void:
	if _poison_stats.poison_stacks > 0:
		source.take_damage(get_reduced_damage(_poison_stats.poison_stacks), Utils.DamageType.POISON, false)


func _on_periodica_agaricus_timer_timeout() -> void:
	var target = source.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	var poison_stacks = _poison_stats.periodica_agaricus_stacks
	_action_module.inflict_condition_stacks(target, poison_stacks, Utils.StackType.POISON)
