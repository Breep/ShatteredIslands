class_name HeroDesc
extends Resource

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

@export var name: String
@export var id: HeroId
@export var portrait: CompressedTexture2D
@export_multiline var description: String
@export var stats: Dictionary[int, HeroStats]
@export var aa_projectile_type: Projectile.Type
@export var skills: Dictionary[Skill.SkillID, Skill]

@export_group("Auto-Attack timing")
## Fraction of the AA cycle (1/AS) occupied by the attack animation.
## The remainder is idle/recovery. Lower = more idle between AAs.
@export_range(0.05, 1.0, 0.01) var aa_anim_ratio: float = 0.8
## Position within the attack animation (0..1) at which the hit/projectile fires.
## Generic for melee and ranged. Independent from the absolute animation length.
@export_range(0.0, 1.0, 0.01) var aa_release_normalized: float = 0.5
## Cap on the animation speed_scale. Beyond this, the animation no longer accelerates
## with AS (visual desync at very high AS is preferable to unreadable hyper-speed).
@export_range(1.0, 20.0, 0.1) var aa_anim_max_speed_scale: float = 4.0

# ============================== Public functions ==============================
