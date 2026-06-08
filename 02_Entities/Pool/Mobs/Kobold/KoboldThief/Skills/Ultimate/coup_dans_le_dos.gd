class_name SE_CoupDansLeDos
extends SkillEffect

# Ultimate "Coup dans le dos": se téléporte derrière sa cible et inflige une attaque critique
# garantie (AD x _crit_multiplier, qui représente le crit + 100% crit damage). Avec "Dos
# exposé" (T2), +bonus si la cible est sous 50% PV. Si "Disparition" (T3) est actif et que la
# cible meurt, le KoboldThief redevient invisible et regagne son mana.

@export var _crit_multiplier: float = 3.0
@export var _teleport_offset: float = 1.2


func apply(ctx: SkillContext) -> void:
	var thief: Entity = ctx.entity
	var target: Entity = thief.auto_attack.get_current_target() if thief.auto_attack != null else null
	if not is_instance_valid(target):
		target = thief.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	if not is_instance_valid(target):
		return

	if thief.has_method("reveal"):
		thief.reveal()

	# Se téléporte derrière la cible.
	thief.global_position = target.global_position + target.global_transform.basis.z * _teleport_offset

	var damage: float = thief.stats.get_stat(EntityStats.StatType.AD) * _crit_multiplier
	# T2 "Dos exposé" : +bonus si la cible est sous 50% PV.
	if target.stats.health_max > 0.0 and (target.stats.health / target.stats.health_max) < 0.5:
		damage *= 1.0 + thief.get_meta(KoboldThief.DOS_EXPOSE_META, 0.0)

	thief.damage.direct(target, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"Coup dans le dos")

	if target.is_dead() and thief.has_method("notify_kill"):
		thief.notify_kill()
