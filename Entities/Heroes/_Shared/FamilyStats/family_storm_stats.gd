class_name FamilyStormStats
extends FamilyStats

## Storm family stats — per-card fields removed.
## Card logic is now self-contained in each HeroUpgrade via CardContext registries.
## Callback arrays are used for cards that hook into the StormManager's core loop.

# --- Callback arrays (populated by cards via apply_card) ---
var on_lightning_callbacks: Array[Callable] = []    # (target: Entity, rank: StormManager.Rank, rank_mult: float)
var on_rank_change_callbacks: Array[Callable] = []  # (rank: StormManager.Rank, rank_mult: float)
var on_crit_callbacks: Array[Callable] = []         # (target: Entity, base_value: float, real_value: float)
var on_rank_s_callbacks: Array[Callable] = []       # (rank_mult: float)

# --- Simple values read by StormManager ---
var quickcharge_grind_percent: float = 0.0
var thunder_storm_duration_bonus: float = 0.0

# --- Shared state (updated by StormManager) ---
var current_rank: StormManager.Rank = StormManager.Rank.D
var storm_breaker_memory: Dictionary = {}
