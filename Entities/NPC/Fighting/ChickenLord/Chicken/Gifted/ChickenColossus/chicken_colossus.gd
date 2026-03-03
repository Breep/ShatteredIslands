class_name ChickenColossus
extends ChickenGifted

var _health_max_ratio: float

func init(health_max_ratio: float) -> Summon:
	_health_max_ratio = health_max_ratio
	return self

func _ready() -> void:
	var mod := StatModifier.new()
	mod.id = &"Chicken_Colossus_HPMAX"
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _health_max_ratio
	mod.tags = []
	stat_modifiers_registry.register_modifier(mod)
	
	stats.health = stats.health_max
	
	inflict_status(self, Status.Type.TAUNT, 60, "Chicken")
	super._ready()
