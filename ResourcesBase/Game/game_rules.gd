class_name GameRules
extends Resource

@export var common_number : int
@export var rare_number : int 
@export var epic_number : int 

@export var common_price : int
@export var rare_price : int
@export var epic_price : int

# Player gold
@export var gold_earned_on_win_streak: Array[int] # 0 50 60 70 80 Each consecutive win increase the gold earn after a win (Lose = 0, First win = 50, Second = 60, etc...)
@export var gold_earned_per_hp_lost: int # 10
@export var gold_earned_per_100_gold_stack: int # 10
@export var gold_stack_max: int # 500
@export var gold_earned_per_round: int
@export var gold_starting_game: int

# Player health
@export var player_starting_health: int # Health of the player at the start of the game

# Player damage:
# <minimum damage (cf:round_modifer> + <lvl_mod (1 2 3 5 8)> + <victory_mod (+-2)> + <skill_mod> + <event_mod>
@export var damage_on_win_lose_modifier: int # (<win> - <lose>) * <this modifier> = the damage modifier
@export var damage_max_diff_win_lose: int # if |<win> - <lose>| == damage_max_diff_win_lose then stop counting win lose diff for damage modifier
@export var damage_player_level_modifier: Array[int] # Player damage increased by his hero level
@export var damage_min_round_divider: int # round_modifier = 1 + current_round_id/damage_min_round_divider
