class_name ChickenColossus
extends ChickenGifted

var _health_max: float

func init(health_max: float) -> Summon:
	_health_max = health_max
	return self

func _ready() -> void:
	var mod := StatModifier.new()
	mod.id = &"Chicken_Colossus_HPMAX"
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _health_max
	mod.tags = []
	stat_modifiers_registry.register_modifier(mod)
	
	
	alterations.inflict_status(self, Alteration.Type.TAUNT, 60, "Chicken")
	super._ready()
