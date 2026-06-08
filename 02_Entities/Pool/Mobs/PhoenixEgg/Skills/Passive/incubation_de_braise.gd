class_name SE_IncubationDeBraise
extends SkillEffect

# Passif "Incubation de braise": l'œuf est ciblable, immobile et ne peut pas attaquer.
# L'immobilité/non-attaque est surtout structurelle (la scène ne charge ni MOVEMENT ni
# AUTO_ATTACK) ; on neutralise ici par sécurité si ces modules existaient quand même.


func apply(ctx: SkillContext) -> void:
	var egg: Entity = ctx.entity
	if egg.movement != null:
		egg.movement.stop()
	if egg.auto_attack != null:
		egg.auto_attack.clear_target()
