# Spécialisation Hero d'EntityDesc : ajoute l'ID Hero (utilisé pour résoudre les
# scènes/resources via Shared.HEROES / Shared.HERO_SCENES) et la table des skills
# par tier (Bronze/Silver/Gold).
class_name HeroDesc
extends EntityDesc


# ============================== Enum ==============================

enum HeroId {
	UNDEF,
	DARK_KNIGHT,
	TANK,
	ASSASSIN,
	MAGE,
	LATIKA,
}


# ============================== Export ==============================

@export var id: HeroId
@export var skills: Dictionary[Skill.SkillID, Skill]
