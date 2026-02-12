class_name FamilyAttackStats
extends FamilyStats

## Attack family stats — per-card fields removed.
## Card logic is now self-contained in each HeroUpgrade via CardContext registries.

# --- Legacy fields (read by auto-attack module, not via manager) ---

# [TITAN AXE]
var titan_axe_activated: bool
var titan_axe_attack_number: int
var titan_axe_damage_percent: float

# [DOUBLE EDGE SWORD]
var double_edge_sword_activated: bool
var double_edge_sword_damage_percent: int
var double_edge_sword_attacks_number: int
