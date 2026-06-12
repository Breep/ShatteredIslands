class_name SE_Bonk
extends SkillEffect

@export var _attack_number: int = 3
@export var _hpmax_percent: float = 5

var _aa_count = 0

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	
	var mod := AutoAttackModifier.new()
	mod.id = &"BigGameHunter"
	mod.is_one_time_effect = false
	mod.damage_modifier_callback = func(cb_vars: Dictionary) -> void:
		_aa_count += 1
		if _aa_count % _attack_number != 0: return
		var target: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(target): return
		var damage_inc: float = target.stats.health_max * _hpmax_percent / 100.0
		if cb_vars.has(AutoAttackModifier.VarType.DAMAGE_ADD):
			cb_vars[AutoAttackModifier.VarType.DAMAGE_ADD] += damage_inc
		else:
			cb_vars[AutoAttackModifier.VarType.DAMAGE_ADD] = damage_inc
		AudioManager.play_3d("thud", target.position)
	_owner.auto_attack_modifier_registry.register_modifier(mod)


func get_description() -> String:
	return "Toutes les " + _value(_attack_number) + " auto-attaques, inflige " \
		+ _value(_hpmax_percent) + "% des PV max de la cible en [[PHYSICAL_DAMAGE]] bonus."
