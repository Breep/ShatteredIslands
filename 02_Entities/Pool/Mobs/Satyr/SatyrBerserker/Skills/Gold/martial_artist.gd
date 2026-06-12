class_name SE_MartialArtist
extends SkillEffect

@export var _attack_number: int = 3

var _aa_count = 0
var _aa_boosted: bool = false

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	
	var mod2 := StatModifier.new()
	mod2.id = &"MartialArtist"
	mod2.calc_type = StatModifier.CalcType.MULT
	mod2.stat_type = EntityStats.StatType.AS
	mod2.value = 2
	
	
	var mod := AutoAttackModifier.new()
	mod.id = &"MartialArtist"
	mod.is_one_time_effect = false
	mod.damage_modifier_callback = func(cb_vars: Dictionary) -> void:
		_aa_count += 1
		if _aa_count >= (_attack_number-1) and not _aa_boosted:
			_owner.stat_modifiers_registry.register_modifier(mod2)
			_aa_boosted = true
			_aa_count = 0
		elif _aa_count >= (_attack_number-1) and _aa_boosted:
			_owner.stat_modifiers_registry.unregister_modifier(mod2)
			_aa_boosted = false
			_aa_count = 0
			
			
			
	_owner.auto_attack_modifier_registry.register_modifier(mod)


func get_description() -> String:
	return "Toutes les " + _value(_attack_number - 1) + " auto-attaques, double sa " \
		+ "vitesse d'attaque (×" + _value(2) + ") puis la réinitialise, en alternance."
	
