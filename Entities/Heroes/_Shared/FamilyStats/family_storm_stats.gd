class_name FamilyStormCallerStats
extends FamilyStats

# --- Callback arrays (populated by cards via apply_card) ---
var on_lightning_callbacks: Array[Callable] = []    # (target: Entity, rank: StormCallerManager.Rank, rank_mult: float)
var on_rank_change_callbacks: Array[Callable] = []  # (rank: StormCallerManager.Rank, rank_mult: float)
var on_crit_callbacks: Array[Callable] = []         # (target: Entity, base_value: float, real_value: float)
var on_rank_s_callbacks: Array[Callable] = []       # (rank_mult: float)

# --- Simple values read by StormCallerManager ---
var quickcharge_grind_percent: float = 0.0
var thunder_storm_duration_bonus: float = 0.0

# --- Shared state (updated by StormCallerManager) ---
var current_rank: StormCallerManager.Rank = StormCallerManager.Rank.D
var storm_breaker_memory: Dictionary = {}
