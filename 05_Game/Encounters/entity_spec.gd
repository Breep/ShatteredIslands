class_name EntitySpec
extends Resource

enum Role {
	ANTAGONIST,
	ACOLYTE,
	BUILDING,
	NPC,           # taverne
	DISRUPTOR,     # taverne
	DECOR          # taverne, non-Entity
}

# === Quoi spawner ===
@export var entity_scene: PackedScene
@export var role: Role = Role.ACOLYTE
@export var team: int = 1
@export var display_label: String = ""  # "ChickenLord_R1_buffed" pour debug

# === Où ===
@export_group("Placement (Fighting)")
@export var hex_coord: Vector2i = Vector2i.ZERO   # axial coords (q, r), utilisé en Fighting
@export_group("Placement (Tavern)")
@export var free_position: Vector3 = Vector3.ZERO # utilisé en Tavern
@export_group("Placement (commun)")
@export var rotation_y: float = 0.0

# === Quoi modifier ===
@export_group("Overrides")
@export var stats_override: EntityStats = null
@export var custom_data: Dictionary = {}  # ex: {"aggro_radius": 8.0, "ai_profile": "passive"}
