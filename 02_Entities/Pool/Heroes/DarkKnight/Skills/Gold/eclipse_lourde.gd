class_name SE_EclipseLourde
extends SkillEffect

# Gold Éclipse Lourde: Lame d'Ombre tire des BIG_PROJECTILE au lieu de SMALL.
# Pose la meta size lue par SE_LameDOmbre.perform_trigger. Aucune variante BIG de
# Nuit Noire n'est fournie : si le deck du joueur ne contient aucun projectile BIG,
# le filtre du pool est vide et le passif ne tire rien — pénalité assumée. Le talent
# n'a de valeur que pour un joueur ayant bâti une stratégie autour de projectiles BIG.


func apply(ctx: SkillContext) -> void:
	if ctx.entity == null:
		return
	ctx.entity.set_meta(SE_LameDOmbre.META_PROJ_SIZE, Projectile.Size.BIG)
