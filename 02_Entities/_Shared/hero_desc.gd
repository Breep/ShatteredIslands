# Spécialisation Hero d'EntityDesc : ajoute l'ID Hero (utilisé pour résoudre les
# scènes/resources via Shared.HEROES / Shared.HERO_SCENES), un libellé de catégorie
# (archétype/rôle affiché dans les UIs de présentation) et la table des skills par
# slot fin (BRONZE1/BRONZE2/...) indispensable pour les écrans de sélection.
class_name HeroDesc
extends EntityDesc


# ============================== Enum ==============================

enum HeroId {
	UNDEF = 0,
	DARK_KNIGHT = 1,
	LATIKA = 2,
}


# ============================== Export ==============================

@export var id: HeroId
@export var category: String
@export var hero_skills: Dictionary[Skill.SkillID, Skill]
