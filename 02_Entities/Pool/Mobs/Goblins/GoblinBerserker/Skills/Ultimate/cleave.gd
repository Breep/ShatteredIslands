class_name SE_Cleave
extends SkillEffect

@export var _damage_self_ad_percent: float = 200.0
@export var _damage_target_hpmax_percent: float = 10.0

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	_owner.spell.cast_spell(_owner, Spell.Type.CLEAVE, {
		Cleave.Modifier.AD: _damage_self_ad_percent,
		Cleave.Modifier.HPMAX: _damage_target_hpmax_percent
	})
