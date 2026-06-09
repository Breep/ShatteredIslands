class_name SE_Eclipse
extends SkillEffect

# Ultimate Éclipse: déclenche le passif Lame d'Ombre en rafale (5 fois de base,
# +META_ULT_EXTRA via le talent Tempête d'Éclipse). Déclenchements forcés: aucun
# jet de chance, chaque rafale passe par SE_LameDOmbre.perform_trigger et bénéficie
# donc des talents (shield, weakness, vuln).

@export var _base_triggers: int = 5


func apply(ctx: SkillContext) -> void:
	var dk: Entity = ctx.entity
	if dk == null:
		Verbose.error("SE_Eclipse: null owner", Verbose.Category.ENTITY_MODULE)
		return

	var target: Entity = dk.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	if not is_instance_valid(target):
		return

	var triggers: int = _base_triggers + int(dk.get_meta(SE_LameDOmbre.META_ULT_EXTRA, 0))
	for i: int in triggers:
		SE_LameDOmbre.perform_trigger(dk, target)
