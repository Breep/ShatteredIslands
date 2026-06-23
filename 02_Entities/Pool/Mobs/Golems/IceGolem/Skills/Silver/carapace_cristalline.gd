class_name SE_CarapaceCristalline
extends SkillEffect

# Talent "Carapace cristalline": à chaque auto-attaque reçue, _chance_percent % de chance
# d'appliquer STUN _stun_duration s à l'attaquant.

@export var _chance_percent: float = 50.0
@export var _stun_duration: float = 1.0


func apply(ctx: SkillContext) -> void:
	var golem: Entity = ctx.entity
	golem.action_received.connect(func(source: Entity, _action_type: Utils.ActionType, action_id: StringName, _value: float, _is_critical: bool) -> void:
		if action_id != &"auto_attack":
			return
		if not is_instance_valid(source):
			return
		if not Utils.is_randomize_modifier_active(_chance_percent, golem.battle_id):
			return
		golem.alterations.direct_status(source, Alteration.Type.STUN, _stun_duration, &"Carapace cristalline")
	)


func get_description() -> String:
	return "Chaque auto-attaque subie a " + _value(_chance_percent) + "% de chance " \
		+ "d'infliger [[STUN]] " + _value(_stun_duration) + " s à l'attaquant."
