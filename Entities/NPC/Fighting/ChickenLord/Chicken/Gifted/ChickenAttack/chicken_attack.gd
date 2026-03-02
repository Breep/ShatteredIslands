class_name ChickenAttack
extends ChickenGifted

var _attack_damage: float
var _attack_speed: float

func init(attack_damage: float, attack_speed: float) -> Summon:
	_attack_damage = attack_damage
	_attack_speed = attack_speed
	
	
	
	return self

func _ready() -> void:
	super._ready()
	var mod := StatModifier.new()
	mod.id = &"Chicken_Attack_ad"
	mod.stat_type = EntityStats.StatType.AD
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _attack_damage
	mod.tags = []
	stat_modifiers_registry.register_modifier(mod)
	
	var mod2 := StatModifier.new()
	mod2.id = &"Chicken_Attack_as"
	mod2.stat_type = EntityStats.StatType.AS
	mod2.calc_type = StatModifier.CalcType.ADD
	mod2.value = _attack_speed
	mod2.tags = []
	stat_modifiers_registry.register_modifier(mod2)
