class_name Hero
extends Resource

# ============================== Enum ==============================

enum HeroId {
	UNDEF,
	ANCIENT_TREE,
	CYBORG,
	DR_BOOM,
	LAURENT_KROFT,
	MR_KRUMB,
	SIR_REGINALD,
	TONY_LE_BARDE,
	RHINO,
	DARK_KNIGHT,
	ROCKY
}

# ============================== Export ==============================

@export var name: String
@export var id: HeroId
@export var portrait: CompressedTexture2D
@export var description: String
@export var stats: Dictionary[int, HeroStats]
@export var aa_projectile_type: Projectile.ProjectileType
@export var model: PackedScene

@export var passive_name: String
@export var passive_description: String

@export var ultimate_name: String
@export var ultimate_description: String

@export var skill1A: Skill
@export var skill1B: Skill
@export var skill2A: Skill
@export var skill2B: Skill
@export var skill3A: Skill
@export var skill3B: Skill

# ============================== Public functions ==============================
