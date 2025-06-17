class_name SerenityManager
extends FamilyManager

# ============================== Constant ==============================

const PACIFY_DAMAGE_REDUCTION_PERCENT: float = 50 # Percentage of damage reduction when pacified

# ============================== Private variables ==============================

var _heal_stats: CharacterHealStats # Ref to the owner heal stats

# ============================== Spells scenes ==============================

# ============================== Public functions ==============================

func _ready() -> void:
	_heal_stats = source.stats.heal
	_create_optional_timers()


func start() -> void:
	for timer in _optional_timers:
		timer.start()


func stop() -> void:
	for timer in _optional_timers:
		timer.stop()


func notify_heal() -> void:
	# [Magic heal]
	if _heal_stats.heal_projectile_activated and Utils.is_randomize_modifier_active(_heal_stats.heal_projectile_chance):
		var target: Character = source.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
		if target == null:
			return
		source.attack(target, _heal_stats.heal_projectile_damage, Utils.DamageType.MAGICAL)
	
	
	# [Panda-cify]
	if _heal_stats.pacify_enemy_activated and Utils.is_randomize_modifier_active(_heal_stats.pacify_enemy_chance):
		var target: Character = source.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
		if target == null:
			return
		target.stats.heal.pacified = true
		if multiplayer.get_unique_id() == 1:
			print("PACIFY MY ENEMY")


func get_reduced_damage_dealed_from_pacify(damage: float) -> float:
	if not _heal_stats.pacified:
		return damage
	
	_heal_stats.pacified = false
	var damage_reduction = damage * PACIFY_DAMAGE_REDUCTION_PERCENT / 100.0
	return damage - damage_reduction

# ============================== Private functions ==============================

func _create_optional_timers() -> void:
	# [Flash heal]
	if _heal_stats.periodic_heal_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _heal_stats.periodic_heal_period, _on_periodic_heal_timer_timeout))
	
	# [Survivor]
	if _heal_stats.lost_hp_regen_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _heal_stats.lost_hp_regen_period, _on_lost_hp_regen_timer_timeout))

	# [Pacific wave]
	if _heal_stats.epic_heal_area_activated:
		_optional_timers.append(Utils.create_perpetual_timer(self, _heal_stats.epic_heal_area_period, _on_epic_heal_area_timer_timeout))

# ============================== Callbacks functions ==============================

func _on_periodic_heal_timer_timeout() -> void:
	var target = source.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
	_action_module.heal(target, _heal_stats.periodic_heal_amount)


func _on_lost_hp_regen_timer_timeout() -> void:
	_action_module.heal_percent(source, _heal_stats.lost_hp_regen_percentage, Utils.PercentModifier.LOST_HP)


func _on_epic_heal_area_timer_timeout() -> void:
	var targets = source.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
	if targets.is_empty():
		return
	for target in targets:
		_action_module.heal_percent(target, _heal_stats.epic_heal_area_percentage, Utils.PercentModifier.MAX_HP)
