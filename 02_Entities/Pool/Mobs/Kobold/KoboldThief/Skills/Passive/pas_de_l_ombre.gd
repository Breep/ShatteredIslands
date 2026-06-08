class_name SE_PasDeLOmbre
extends SkillEffect

# Passif "Pas de l'ombre": au début du combat, devient Invisible (UNTARGETABLE) jusqu'à sa
# première attaque ou son premier ultimate (la rupture est gérée par KoboldThief).


func apply(ctx: SkillContext) -> void:
	var thief: Entity = ctx.entity
	thief.battle_callback_registry.register_battle_start(&"PasDeLOmbre", func() -> void:
		if thief.has_method("enter_stealth"):
			thief.enter_stealth()
	)
