class_name FireManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _fire_stats: FamilyFireStats # Ref to the owner fire stats

# ============================== Spells scenes ==============================

@onready var _healing_fire_area_scene: PackedScene = preload("res://SpellsAndProjectiles/Spells/HealingFire/healing_fire_area.tscn")
@onready var _meteor_scene: PackedScene = preload("res://SpellsAndProjectiles/Spells/Meteor/meteor.tscn")
@onready var _fire_trail_scene: PackedScene = preload("res://SpellsAndProjectiles/Spells/FireTrail/fire_trail.tscn")

# ============================== Node base functions ==============================

func _ready() -> void:
	_fire_stats = _owner.families_stats.fire

# ============================== Public functions ==============================

func start() -> void:
	_create_optional_timers()
	_lanch_optional_spells()
	
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.queue_free()
	_optional_timers.clear()
	for spell in _optional_spells:
		spell.queue_free()


func get_reduced_damage(damage: int, damage_type: Utils.DamageType) -> int:
	return damage

# Storm of fire
func get_increased_damage(damage: float, damage_type: Utils.DamageType) -> float:
	return damage

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	pass


func _lanch_optional_spells() -> void:
	pass

# ============================== Callbacks functions ==============================

func _on_firebolt_timer_timeout() -> void:
	pass

func _on_nuke_timer_timeout() -> void:
	pass

func _on_meteor_timer_timeout() -> void:
	pass














 
