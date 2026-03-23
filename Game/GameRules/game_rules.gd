class_name GameRules
extends Resource

@export_group("Cards rules")
@export_subgroup("Cards number")
@export var rarity_card_numbers: Dictionary[Card.Rarity, int] = {
	Card.Rarity.COMMON: 25,
	Card.Rarity.RARE: 10,
	Card.Rarity.EPIC: 5,
	Card.Rarity.LEGENDARY: 3,
}

@export_subgroup("Family rules")
@export var rarity_card_values: Dictionary[Card.Rarity, int] = {
	Card.Rarity.COMMON: 1,
	Card.Rarity.RARE: 2,
	Card.Rarity.EPIC: 3,
	Card.Rarity.LEGENDARY: 5,
}

@export var family_level_points: Dictionary[int, int] = {
	0: 0,
	1: 10,
	2: 20,
	3: 30,
	4: 40,
}

@export var card_rarities_locked_by_level: Dictionary[int, Array] = {
	0: [Card.Rarity.RARE, Card.Rarity.EPIC, Card.Rarity.LEGENDARY],
	1: [Card.Rarity.EPIC, Card.Rarity.LEGENDARY],
	2: [Card.Rarity.LEGENDARY],
	3: [],
	4: [],
}

@export var card_rarity_unlocked_by_level: Dictionary[int, Card.Rarity] = {
	0: Card.Rarity.COMMON,
	1: Card.Rarity.RARE,
	2: Card.Rarity.EPIC,
	3: Card.Rarity.LEGENDARY,
}

@export_subgroup("Drop Rates")
## Key: Family Level, Value: Dictionary[Card.Rarity, int] (Percentage)
@export var drop_rates_by_family_level: Dictionary[int, Dictionary] = {
	0: {Card.Rarity.COMMON: 100, Card.Rarity.RARE: 0, Card.Rarity.EPIC: 0, Card.Rarity.LEGENDARY: 0},
	1: {Card.Rarity.COMMON: 70, Card.Rarity.RARE: 30, Card.Rarity.EPIC: 0, Card.Rarity.LEGENDARY: 0},
	2: {Card.Rarity.COMMON: 65, Card.Rarity.RARE: 25, Card.Rarity.EPIC: 10, Card.Rarity.LEGENDARY: 0},
	3: {Card.Rarity.COMMON: 60, Card.Rarity.RARE: 20, Card.Rarity.EPIC: 15, Card.Rarity.LEGENDARY: 5},
	4: {Card.Rarity.COMMON: 50, Card.Rarity.RARE: 20, Card.Rarity.EPIC: 20, Card.Rarity.LEGENDARY: 10},
}

@export_group("Card shop rules")
@export_subgroup("Card price")
@export var common_price: int = 100
@export var rare_price: int = 100
@export var epic_price: int = 100
@export var legendary_price: int = 100

@export_group("Oracle shop rules")
@export var buy_xp_price: int = 50

@export_subgroup("Other price")
@export var refresh_price: int = 20
@export var buy_random_price: int = 90

@export_group("Player gold")
@export var gold_earned_on_win_streak: Array[int] = [0, 50, 60, 70, 80] # Each consecutive win increase the gold earn after a win
@export var gold_earned_per_hp_lost: int = 30
@export var gold_earned_per_100_gold_stack: int = 10
@export var gold_stack_max: int = 500
@export var gold_earned_per_round: int = 300
@export var gold_starting_game: int = 300

@export_group("Player health")
@export var player_starting_health: int = 50

@export_group("Player damage")
# Minimum damage = <round_modifier> + <lvl_mod (1 2 3 5 8)>
#  + <victory_mod*(+-2)> + <skill_mod> + <event_mod>
@export var damage_on_win_lose_modifier: int = 2 # (<win> - <lose>) * <this modifier> = the damage modifier
@export var damage_max_diff_win_lose: int = 3 # if |<win> - <lose>| == damage_max_diff_win_lose then stop counting win lose diff for damage modifier
@export var damage_player_level_modifier: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10] # Player damage increased by his hero level

@export_group("Player xp")
@export var xp_per_round: int = 4 # XP gained each round
@export var xp_per_oracle_buy: int = 3 # XP gained for each oracle_buy
@export var xp_per_family_lvl: int = 10 # XP gained each time a card family lvl up
@export var xp_max_player_level: int = 10
@export var xp_per_levels: Dictionary[int, int] = {
	1: 6,
	2: 10,
	3: 14,
	4: 18,
	5: 22,
	6: 28,
	7: 34,
	8: 40,
	9: 50,
}

@export_group("Skills")
@export var bronze_skill_unlock_lvl: int = 3
@export var silver_skill_unlock_lvl: int = 5
@export var gold_skill_unlock_lvl: int = 7


@export_group("Game States Duration")
@export var duration_buying_phase: float = 20.0
@export var duration_fighting_countdown: float = 3.0
@export var duration_fighting_normal: float = 20.0
@export var duration_fighting_special: float = 10.0
@export var duration_fighting_celebration: float = 3.0
@export var duration_fighting_finished: float = 1.0

func get_updated_player_damage(player_lvl: int, current_player_win_lose_diff: int, last_round_won: bool, current_round: int) -> int:
	var damage_min: int = damage_player_level_modifier[player_lvl] # = player_lvl in normal games
	var damage_max: int = current_round
	var damage_mod_last_fight: int = damage_on_win_lose_modifier if last_round_won else -damage_max_diff_win_lose
	var damage_mod_win_loose_diff: int = current_player_win_lose_diff
	var damage: int = damage_player_level_modifier[player_lvl] + damage_mod_last_fight + damage_mod_win_loose_diff
	return clampi(damage, damage_min, damage_max)


func get_family_level(point: int) -> int:
	if point < family_level_points[1]: return 0
	elif point >= family_level_points[1] and point < family_level_points[2]: return 1
	elif point >= family_level_points[2] and point < family_level_points[3]: return 2
	elif point >= family_level_points[3] and point < family_level_points[4]: return 3
	else: return 4


func family_point_to_xp(point: int) -> int:
	if point < family_level_points[1]: return point
	elif point >= family_level_points[1] and point < family_level_points[2]: return point - family_level_points[1]
	elif point >= family_level_points[2] and point < family_level_points[3]: return point - family_level_points[2]
	elif point >= family_level_points[3] and point < family_level_points[4]: return point - family_level_points[3]
	else: return 0


func family_point_to_xp_max(point: int) -> int:
	if point < family_level_points[1]: return family_level_points[1]
	elif point >= family_level_points[1] and point < family_level_points[2]: return family_level_points[2] - family_level_points[1]
	elif point >= family_level_points[2] and point < family_level_points[3]: return family_level_points[3] - family_level_points[2]
	elif point >= family_level_points[3] and point < family_level_points[4]: return family_level_points[4] - family_level_points[3]
	else: return 0

func get_locked_rarities(family_level: int) -> Array[Card.Rarity]:
	if family_level < 0 or family_level > card_rarities_locked_by_level.size():
		return []
	var locked_rarities: Array[Card.Rarity]
	for rarity in card_rarities_locked_by_level[family_level]:
		locked_rarities.append(rarity)
	return locked_rarities
