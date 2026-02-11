class_name HeroDesc
extends Resource

# ============================== Enum ==============================

enum HeroId {
	UNDEF,
	DARK_KNIGHT,
}

# ============================== Export ==============================

@export var name: String
@export var id: HeroId
@export var portrait: CompressedTexture2D
@export_multiline var description: String
@export var stats: Dictionary[int, HeroStats]
@export var aa_projectile_type: Projectile.Type
@export var skills: Dictionary[Skill.SkillID, Skill]

# ============================== Public functions ==============================
