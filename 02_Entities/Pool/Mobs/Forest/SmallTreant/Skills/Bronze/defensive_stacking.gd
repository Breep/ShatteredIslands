class_name SE_DefensiveStacking
extends SkillEffect

## Talent 1 "Empilement défensif": à chaque auto-attaque subie (melee ou range),
## _gain_chance_percent % de chances de gagner _thorn_gain stack(s) de Thorn.
##
## NOTE: faute de tag "projectile" distinct dans le pipeline de dégâts, on couvre toutes
## les auto-attaques (id &"auto_attack"). Les projectiles de sorts ne sont pas couverts.

@export var _gain_chance_percent: float = 50.0
@export var _thorn_gain: float = 1.0


func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity

	_owner.action_received.connect(func(_source: Entity, action_type: Utils.ActionType, action_id: StringName, _value: float, _is_critical: bool) -> void:
		if action_id != &"auto_attack": return
		if action_type != Utils.ActionType.DAMAGE_PHYSICAL: return
		if not Utils.is_randomize_modifier_active(_gain_chance_percent, _owner.battle_id): return
		_owner.alterations.add_stack(Alteration.Type.THORN, _thorn_gain)
	)
