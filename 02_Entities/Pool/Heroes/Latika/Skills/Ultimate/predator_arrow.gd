class_name SE_PredatorArrow
extends SkillEffect

# Ultimate "Flèche du Prédateur" : libère un trait perçant en ligne droite vers
# l'ennemi le plus proche, traversant tous les ennemis sur son chemin pour _damage
# dégâts physiques. Sort autonome (cf. PredatorArrow) — aucun lien avec l'auto-attaque.

@export var _damage: float = 50.0


func apply(ctx: SkillContext) -> void:
	var latika: Entity = ctx.entity
	if latika == null:
		Verbose.error("SE_PredatorArrow: null owner", Verbose.Category.ENTITY_MODULE)
		return

	var aim: Entity = latika.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	if not is_instance_valid(aim):
		return

	latika.spell.cast_spell(aim, Spell.Type.PREDATOR_ARROW, {
		PredatorArrow.Modifier.DAMAGE: _damage,
	})
