class_name SE_PredatorArrow
extends SkillEffect

# Ultimate "Flèche du Prédateur" : libère un trait perçant en ligne droite vers
# l'ennemi le plus proche, traversant tous les ennemis sur son chemin pour des dégâts
# physiques égaux à un ratio de l'AD du lanceur (cf. PredatorArrow).

@export var _damage_ratio: float = 5.0


func apply(ctx: SkillContext) -> void:
	var latika: Entity = ctx.entity
	if latika == null:
		Verbose.error("SE_PredatorArrow: null owner", Verbose.Category.ENTITY_MODULE)
		return

	var aim: Entity = latika.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	if not is_instance_valid(aim):
		return

	var damage: float = latika.stats.get_stat(EntityStats.StatType.AD) * _damage_ratio
	latika.spell.cast_spell(aim, Spell.Type.PREDATOR_ARROW, {
		PredatorArrow.Modifier.DAMAGE: damage,
	})


func get_description() -> String:
	return "Décoche un trait perçant vers l'ennemi le plus proche, traversant tous les " \
		+ "ennemis sur sa trajectoire, infligeant " + _value(_damage_ratio * 100.0) \
		+ "% de ses dégâts d'attaque en [[PHYSICAL_DAMAGE]]."
