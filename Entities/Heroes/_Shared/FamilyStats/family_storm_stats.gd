class_name FamilyStormStats
extends FamilyStats

## Storm family stats — per-card fields removed.
## Card logic is now self-contained in each HeroUpgrade via CardContext registries.
## Callback arrays are used for cards that hook into the StormManager's core loop.

# --- Callback arrays (populated by cards via apply_card) ---
var on_lightning_callbacks: Array[Callable] = []   # (target: Entity, rank: StormManager.Rank, rank_mult: float)
var on_rank_change_callbacks: Array[Callable] = []  # (rank: StormManager.Rank, rank_mult: float)
var on_crit_callbacks: Array[Callable] = []         # (target: Entity, base_value: float, real_value: float)
var on_rank_s_callbacks: Array[Callable] = []       # (rank_mult: float)

# --- Simple values read by StormManager ---
var quickcharge_grind_percent: float = 0.0
var thunder_storm_duration_bonus: float = 0.0

# --- Shared state (updated by StormManager) ---
var current_rank: StormManager.Rank = StormManager.Rank.D
var storm_breaker_memory: Dictionary = {}

# --- Legacy fields (cross-family, not in Storm card scope) ---

var periodic_vulnerability_activated: bool
var periodic_vulnerability_amount: int
var periodic_vulnerability_period: float

var crit_heal_activated: bool
var crit_heal_amount: int

var crit_vulnerability_activated: bool
var crit_vulnerability_amount: int

var focused: bool
var focus_target_activated: bool
var focus_target_time_before: float
var focus_target_crit_min: float
var focus_target_crit_max: float
var focus_target_crit_current: float
var focus_target_duration: float

var overcharge_activated: bool
var overcharge_percent: float

var lost_hp_crit_multiplier_activated: bool
var lost_hp_crit_multiplier_amount: int
var lost_hp_crit_multiplier_hp_number: int

var crit_poison_activated: bool
var crit_poison_amount: int

var speed_boosted: bool
var crit_move_speed_activated: bool
var crit_move_speed_amount: int
var crit_move_speed_duration: float
