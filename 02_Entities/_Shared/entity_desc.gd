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

# Scène entité runtime — JAMAIS posée en éditeur (cycle de dépendance : la scene
# embarque un script qui référence ce desc). Résolue via Shared.HERO_SCENES /
# Shared.ACOLYTE_SCENES par EntityDesc.resolve_scene(). Le seul cas où ce champ
# est posé directement est une desc transient construite à la volée (cf.
# FightingFormation._make_transient_entry) — le resolver la respecte en priorité.
var scene: PackedScene
## Lightweight visual-only scene (mesh + AnimationPlayer, no Entity logic) used
## by selection/presentation screens.
@export var preview_scene: PackedScene
@export var default_category: Entity.Category = Entity.Category.MOB
@export var starting_companions: Array[EntityDesc]

@export var stats: Dictionary[int, EntityStats]
@export var skills: Dictionary[Skill.Type, Skill]

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


# Résout la PackedScene à instancier pour une desc. Priorité au champ runtime
# (cas transient FightingFormation), sinon lookup Shared : HERO_SCENES par
# HeroId pour les héros, ACOLYTE_SCENES par desc Resource pour le reste.
# Retourne null si non résolu (l'appelant doit gérer / warn).
static func resolve_scene(desc: EntityDesc) -> PackedScene:
	if desc == null:
		return null
	if desc.scene != null:
		return desc.scene
	if desc is HeroDesc:
		return Shared.HERO_SCENES.get((desc as HeroDesc).id)
	return Shared.ACOLYTE_SCENES.get(desc)
