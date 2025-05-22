class_name LifeManager
extends FamilyManager

# ============================== Signals ==============================

signal revived(life_after_revive: int)

# ============================== Private variables ==============================

var _life_stats: CharacterLifeStats # Ref to the owner life stats

var _revive_timer: Timer

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func _ready() -> void:
	_life_stats = source.stats.life
	_create_optional_timers()


func start() -> void:
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func get_increased_damage_taken_from_lost_hp(damage: float, damage_type: Utils.DamageType) -> float:
	return damage
	#if not source.stats.hp.damage_increased_by_hp_lost_activated:
		#return damage
	#
	#var lost_hp: int = source.stats.health_max - source.stats.health
	#var damage_inc_percent: int = source.stats.hp.damage_increased_by_hp_lost_percentage
	#var lost_hp_stacks: int = lost_hp / source.stats.hp.damage_increased_by_hp_lost_hp_number
	#var damage_multiplier: float = remap(damage_inc_percent * lost_hp_stacks, 0, 100, 1, 2)
#
	#return damage * damage_multiplier
	
func get_reduced_damage(damage: int) -> int:
	if not _life_stats.damage_taken_reduced_below_treshold_activated:
		return damage
	
	var life_ratio: float = (source.stats.health as float / source.stats.health_max as float) * 100.0
	if life_ratio <= _life_stats.damage_taken_reduced_below_treshold_threshold:
		var damage_reduction = (damage as float) * _life_stats.damage_taken_reduced_below_treshold_percentage / 100.0
		return damage - damage_reduction
	
	return damage


# [Revive]
func source_is_dead() -> void:
	if not _life_stats.revive_after_death_activated or _life_stats.revive_after_death_triggered:
		return
	
	_life_stats.revive_after_death_triggered = true
	_revive_timer.start()

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# Poisonous hearth
	if _life_stats.poison_by_lost_hp_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _life_stats.poison_by_lost_hp_period, _on_poison_by_lost_hp_timer_timeout))
	
	# Hearth of fire
	if _life_stats.fire_damage_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _life_stats.fire_damage_period, _on_fire_damage_timer_timeout))
	
	if _life_stats.revive_after_death_activated:
		_revive_timer = Timer.new()
		_revive_timer.wait_time = _life_stats.revive_after_death_time
		_revive_timer.one_shot = true
		_revive_timer.timeout.connect(_on_revive_timer_timeout)
		add_child(_revive_timer)

# ============================== Callbacks functions ==============================

func _on_poison_by_lost_hp_timer_timeout() -> void:
	var target = source.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	var lost_hp: int = source.stats.health_max - source.stats.health
	var stack_multiplier: int = _life_stats.poison_by_lost_hp_stacks
	var poison_stacks: int = (lost_hp / _life_stats.poison_by_lost_hp_hp_number) * stack_multiplier
	_action_module.inflict_condition_stacks(target, poison_stacks, Utils.StackType.POISON)


func _on_fire_damage_timer_timeout() -> void:
	var target = source.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null: return
	var damage = source.stats.health_max * _life_stats.fire_damage_percent / 100.0
	_action_module.direct_attack(target, damage, Utils.DamageType.MAGICAL)


func _on_revive_timer_timeout() -> void:
	print("REVIVE")
	print("Spawn revive bomb here")
	var life_after_revive: int = ((_life_stats.revive_after_death_percentage_life * source.stats.health_max) / 100.0) as int
	revived.emit(life_after_revive)
