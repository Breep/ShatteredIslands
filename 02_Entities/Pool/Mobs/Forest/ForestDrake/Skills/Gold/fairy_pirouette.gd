class_name SE_FairyPirouette
extends SkillEffect

@export var _cd: float = 8.0
@export var _duration: float = 1.0
var _can_do_pirouette: bool = true

func apply(ctx: SkillContext) -> void:
	var _owner = ctx.entity
	
	_owner.damage_taken.connect(func(_a, _b, _c, _d) -> void:
		if not _can_do_pirouette: return
		_owner.alterations.direct_status(_owner, Alteration.Type.UNTARGETABLE, _duration, &"Fairy Pirouette")
		_can_do_pirouette = false
		
		_owner.battle_callback_registry.register_oneshot(_cd, func()-> void:
			_owner.alterations.cancel_state(Alteration.Type.UNTARGETABLE)
			_can_do_pirouette = true
		)
	)


func get_description() -> String:
	return "Quand il subit des dégâts, devient inciblable pendant " + _value(_duration) \
		+ " s, puis [[COOLDOWN]] de " + _value(_cd) + " s."
	
	
