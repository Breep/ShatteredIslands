class_name LifeManager
extends FamilyManager

# ============================== Signals ==============================

signal revived(life_after_revive: int)

# ============================== Private variables ==============================

var _life_stats: FamilyLifeStats # Ref to the owner life stats

var _revive_timer: Timer

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func _ready() -> void:
	_life_stats = _owner.families_stats.life


func start() -> void:
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func get_increased_damage_taken_from_lost_hp(damage: float, _damage_type: Utils.DamageType) -> float:
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
	pass


func _on_fire_damage_timer_timeout() -> void:
	var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null: return
	var damage = _owner.stats.health_max * _life_stats.fire_damage_percent / 100.0
	_action_module.direct_attack(target, damage, Utils.DamageType.MAGICAL)


func _on_revive_timer_timeout() -> void:
	print("REVIVE")
	print("Spawn revive bomb here")
	var life_after_revive: int = ((_life_stats.revive_after_death_percentage_life * _owner.stats.health_max) / 100.0) as int
	revived.emit(life_after_revive)
