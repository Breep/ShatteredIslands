class_name FireManager
extends Node

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _source: Character # Ref to character owner
var _fire_stats: CharacterFireStats # Ref to the owner fire stats

var _optional_timers: Array[Timer]

# ============================== Spells scenes ==============================

@onready var _healing_fire_area_scene: PackedScene = preload("res://Scenes/SpellsAndProjectiles/healing_fire_area.tscn")

# ============================== Public functions ==============================

func start(source: Character, fire_stats: CharacterFireStats) -> void:
	print("FireManager: Starting")
	if source == null:
		printerr("FireManager: source undef")
		return
	if fire_stats == null:
		printerr("FireManager: fire_stats undef")
		return
	
	_source = source
	_fire_stats = fire_stats
	_create_optional_timers()
	_lanch_optional_spells()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func get_reduced_damage_taken_from(_damage_source: Character, damage: int, damage_type: Utils.DamageType) -> int:
	if damage_type != Utils.DamageType.MAGIC:
		return damage
	
	var damage_reduced = damage - damage * _fire_stats.magic_resist_percent / 100.0
	return damage_reduced

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Fire dagger bolt
	if _fire_stats.firebolt_activated:
		_optional_timers.append(Utils.create_optional_timer(self, _fire_stats.firebolt_period, _on_firebolt_timer_timeout))


func _lanch_optional_spells() -> void:
	# Ring of fire healing
	if _fire_stats.healing_fire_area_activated:
		var healing_fire_area: HealingFireArea = _healing_fire_area_scene.instantiate()
		healing_fire_area.init(_source, _fire_stats.healing_fire_area_damage, _fire_stats.healing_fire_area_heal, 
				_fire_stats.healing_fire_area_period, _fire_stats.healing_fire_area_range)
		_source.add_child(healing_fire_area)
		healing_fire_area.position = Vector3.ZERO

# ============================== Callbacks functions ==============================

func _on_firebolt_timer_timeout() -> void:
	print("FireManager: FIREBOLT")
	var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
	target.take_damage_percent(_source, _fire_stats.firebolt_damage, Utils.DamageType.MAGIC)
