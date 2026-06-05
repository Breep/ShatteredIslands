class_name SE_DefensiveStacking
extends SkillEffect

## Talent 1 "Empilement défensif": à chaque projectile subi, _gain_chance_percent %
## de chances de gagner _thorn_gain stack(s) de Thorn.
##
## NOTE: il n'existe pas (encore) de tag "projectile" distinct au niveau des dégâts —
## une attaque à distance arrive comme DAMAGE_PHYSICAL/&"auto_attack". On l'identifie
## donc via la source (auto-attaque RANGED). À challenger si on veut couvrir aussi les
## projectiles de sorts.

@export var _gain_chance_percent: float = 50.0
@export var _thorn_gain: float = 1.0


func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity

	_owner.action_received.connect(func(source: Entity, action_type: Utils.ActionType, action_id: StringName, _value: float, _is_critical: bool) -> void:
		if action_id != &"auto_attack": return
		if action_type != Utils.ActionType.DAMAGE_PHYSICAL: return
		if not is_instance_valid(source): return
		if source.stats.auto_attack_type != EntityStats.AutoAttackType.RANGED: return
		if not Utils.is_randomize_modifier_active(_gain_chance_percent, _owner.battle_id): return
		_owner.alterations.add_stack(Alteration.Type.THORN, _thorn_gain)
	)
