# Configuration universelle d'une entité : stats par niveau, méta-données visuelles
# et timings auto-attack. Spécialisations par type d'entité (HeroDesc, et plus tard
# SummonDesc, AntagonistDesc, ...) étendent cette classe pour ajouter leurs champs
# spécifiques (id, skills, ...).
class_name EntityDesc
extends Resource


# ============================== Export ==============================
@export var name: String
@export var portrait: CompressedTexture2D
@export_multiline var description: String

@export var stats: Dictionary[int, EntityStats]

@export_group("Auto-Attack timing")
## Fraction of the AA cycle (1/AS) occupied by the attack animation.
## The remainder is idle/recovery. Lower = more idle between AAs.
@export_range(0.05, 1.0, 0.01) var aa_anim_ratio: float = 0.8
## Position within the attack animation (0..1) at which the hit/projectile fires.
## Generic for melee and ranged. Independent from the absolute animation length.
@export_range(0.0, 1.0, 0.01) var aa_1_release_normalized: float = 0.5
@export_range(0.0, 1.0, 0.01) var aa_2_release_normalized: float = 0.5
@export_range(0.0, 1.0, 0.01) var aa_3_release_normalized: float = 0.5

@export var aa_1_anim_base_duration: float = 3.26
@export var aa_2_anim_base_duration: float = 3.26
@export var aa_3_anim_base_duration: float = 3.26
