class_name PoisonPoisonFlask
extends HeroUpgrade

@export var _poison_stacks: Array[int]
@export var _period: Array[float]

var _poison_flask_stack: int

func apply(_stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Poison Flask: Wrong cardlvl: ", cardlvl)
		return
	
	_poison_flask_stack = _poison_stacks[cardlvl - 1]
	periodic_callback_wait_time = _period[cardlvl - 1]
	
	periodic_callback = _throw_poison_flask


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Poison Flask: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Inflict " + str(_poison_stacks[cardlvl - 1]) + " [[POISON_STACK]], every " + str(_period[cardlvl - 1]) + "s"


func _throw_poison_flask(data: Dictionary) -> void:
	Verbose.debug("Poison Flask: _throw_poison_flask", Verbose.Category.CARD)
	if not data.has(VarType.HERO_OWNER):
		printerr("Poison Flask: Missing VarType.HERO_OWNER")
		return
	
	var hero_owner: Hero = data[VarType.HERO_OWNER]
	var target: Entity = hero_owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if target == null: return
	var projectile_stats: ProjectileStats = _create_poison_flask_projectile()
	hero_owner.projectile_attack(target, Projectile.Type.POISON_FLASK, hero_owner, projectile_stats)


func _create_poison_flask_projectile() -> ProjectileStats:
	var projectile_stats := ProjectileStats.new()
	projectile_stats.on_hit_callbacks.append(_on_hit_poison_flask_callback)
	return projectile_stats


func _on_hit_poison_flask_callback(data: Dictionary) -> void:
	Verbose.debug("Poison Flask: _on_hit_poison_flask_callback 1", Verbose.Category.CARD)
	var target: Entity = data.get(AutoAttackModifier.VarType.TARGET, null)
	var source: Hero = data.get(AutoAttackModifier.VarType.SOURCE, null)
	
	Verbose.debug("Poison Flask: _on_hit_poison_flask_callback 2", Verbose.Category.CARD)
	if target == null: return
	source.inflict_condition_stacks(target, _poison_flask_stack, Utils.StackType.POISON, "Poison Flask")
