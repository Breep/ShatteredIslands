class_name FireManager
extends FamilyManager

# ============================== Signals ==============================

# ============================== Private variables ==============================

var _fire_stats: CharacterFireStats # Ref to the owner fire stats

# ============================== Spells scenes ==============================

@onready var _healing_fire_area_scene: PackedScene = preload("res://Scenes/SpellsAndProjectiles/healing_fire_area.tscn")
@onready var _meteor_scene: PackedScene = preload("res://Scenes/SpellsAndProjectiles/meteor.tscn")
@onready var _fire_trail_scene: PackedScene = preload("res://Scenes/SpellsAndProjectiles/fire_trail.tscn")

# ============================== Public functions ==============================

func _specific_init() -> void:
	_fire_stats = _source.stats.fire
	_create_optional_timers()


func start() -> void:
	_lanch_optional_spells()
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()
	for spell in _optional_spells:
		spell.queue_free()


func get_reduced_damage(damage: int, damage_type: Utils.DamageType) -> int:
	if damage_type != Utils.DamageType.MAGICAL:
		return damage
	
	var damage_reduced = damage - damage * _fire_stats.magic_resist_percent / 100.0
	return damage_reduced


# Storm of fire
func get_increased_damage(damage: float, damage_type: Utils.DamageType) -> float:
	if damage_type != Utils.DamageType.MAGICAL:
		return damage
	
	if not _fire_stats.damage_increase_on_low_life_enemy_activated:
		return damage
	
	var health_ratio_percent: float = (_source.stats.health as float / _source.stats.health_max as float) * 100.0
	if health_ratio_percent >= _fire_stats.damage_increase_on_low_life_enemy_threshold:
		return damage
	
	return damage + damage * _fire_stats.damage_increase_on_low_life_enemy_percent / 100.0

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# [Fire dagger bolt]
	if _fire_stats.firebolt_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _fire_stats.firebolt_period, _on_firebolt_timer_timeout))
	
	# [Explosion]
	if _fire_stats.nuke_activated:
		_on_nuke_timer_timeout()
		_optional_timers.append(Utils.create_perpetual_timer(self, _fire_stats.nuke_period, _on_nuke_timer_timeout))
	
	# [Meteor]
	if _fire_stats.meteor_activated:
		var meteor_period = _fire_stats.meteor_deploy_time + _fire_stats.meteor_cooldown
		_optional_timers.append(Utils.create_perpetual_timer(self, meteor_period, _on_meteor_timer_timeout))


func _lanch_optional_spells() -> void:
	# [Ring of fire healing]
	if _fire_stats.healing_fire_area_activated:
		var healing_fire_area: HealingFireArea = _healing_fire_area_scene.instantiate()
		healing_fire_area.init(_source, _fire_stats.healing_fire_area_damage, _fire_stats.healing_fire_area_heal, 
				_fire_stats.healing_fire_area_period, _fire_stats.healing_fire_area_range)
		_source.add_child(healing_fire_area)
		healing_fire_area.position = Vector3.ZERO
	
	# [Fire trail]
	if _fire_stats.trail_activated:
		var fire_trail: FireTrail = _fire_trail_scene.instantiate()
		fire_trail.init(_source, _fire_stats.trail_damage_percent, _fire_stats.trail_period, _fire_stats.trail_life_time)
		_source.add_child(fire_trail)
		fire_trail.position = Vector3.ZERO

# ============================== Callbacks functions ==============================

func _on_firebolt_timer_timeout() -> void:
	var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
	if target == null:
		return
	
	_action_module.direct_attack_percent(target, _fire_stats.firebolt_damage, Utils.DamageType.MAGICAL, Utils.PercentModifier.CURRENT_HP)


func _on_nuke_timer_timeout() -> void:
	var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
	if target == null:
		return
	
	_action_module.direct_attack_percent(target, _fire_stats.nuke_damage, Utils.DamageType.MAGICAL, Utils.PercentModifier.MAX_HP)


func _on_meteor_timer_timeout() -> void:
	var target = _source.target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
	if target == null:
		return
	
	var meteor: Meteor = _meteor_scene.instantiate()
	meteor.init(_source, _fire_stats.meteor_damage, _fire_stats.meteor_deploy_time, _fire_stats.meteor_area_range)
	get_tree().current_scene.add_child(meteor)
	meteor.position = target.position















 
