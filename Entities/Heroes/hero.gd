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

@export var stats: CharacterStats

@export var aa_projectile_type: Projectile.ProjectileType
@export var model: PackedScene

# ============================== Public functions ==============================
