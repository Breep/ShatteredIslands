class_name FightingManager
extends Node

# ============================== Signals ==============================

signal state_changed(state: FightingState)
signal fight_is_over(winner_team: int)

# ============================== Enums ==============================

enum FightingState {
	WAITING_FOR_PLAYERS, # Waiting for all player to load the scene
	STARTING, # Begginning countdown
	FIGHT, # 30 seconds of fight
	FIGHT_ACCELERATED, # 10 seconds accelerated fight
	ENDING, # Either only one team remains alive or times up
	FINISHED, # Go back to buying scene
}

# ============================== Fighting phase duration (Local export) ==============================

@export var starting_count_down_duration: int # in seconds
@export var fight_duration: int # in seconds
@export var fight_accelerated_duration: int # in seconds
@export var ending_duration: int # in seconds

# ============================== Public variables ==============================

var battle_id: int = -1 # Set by the parent

# ============================== Private variables ==============================

var _fighting_state: FightingState = FightingState.WAITING_FOR_PLAYERS
var fighting_state: FightingState:
	get:
		return _fighting_state
	set(value):
		_fighting_state = value
		state_changed.emit(value)

var _teams_members: Dictionary # [int, Array[Character]] Key=team number, value=team members

# ============================== Local nodes ==============================

@onready var _timer: Timer = %Timer

# ============================== Node base functions ==============================

func _ready() -> void:
	state_changed.connect(_on_state_changed)

# ============================== Public functions ==============================

func start() -> void:
	if not multiplayer.is_server():
		return
	
	_fighting_state = FightingState.STARTING
	state_changed.emit(_fighting_state)
	_timer.wait_time = starting_count_down_duration
	_setup_teams_characters()
	_connect_to_characters_signals()
	_timer.start()

# ============================== Private functions ==============================

func _setup_teams_characters() -> void:
	var characters: Array[Character] = Shared.entity_managers_ref[battle_id].characters.values()
	for character in characters:
		if _teams_members.has(character.team):
			_teams_members[character.team].append(character)
		else:
			_teams_members[character.team] = [character]


func _connect_to_characters_signals() -> void:
	for team_members in _teams_members.values():
		for member in team_members:
			var character: Character = member
			character.dead.connect(_on_character_dead)


func _disconnect_from_characters_signals() -> void:
	for team_members in _teams_members.values():
		for member in team_members:
			var character: Character = member
			character.dead.disconnect(_on_character_dead)


func _is_only_one_team_alive() -> bool:
	var teams_number: int = _teams_members.size()
	var teams_alived_counter: int = 0
	for team_members in _teams_members.values():
		if team_members.size() > 0:
			teams_alived_counter += 1
	
	return teams_alived_counter == 1


func _get_winner_team() -> int:
	var team_life_percent: Dictionary[int, float] # Key=<Team number>, Value=<Sum of percentage of character hp of players in the team>
	for team_number in _teams_members.keys():
		team_life_percent[team_number] = 0.0
		for member in _teams_members[team_number]:
			var character: Character = member
			team_life_percent[team_number] += ((character.stats.health as float) / (character.stats.health_max as float))
	var winner_team: int = team_life_percent.keys()[0]
	for team_number in team_life_percent.keys():
		if team_life_percent[team_number] > team_life_percent[winner_team]:
			winner_team = team_number
	return winner_team


# ============================== Callbacks ==============================

func _on_timer_timeout() -> void:
	match fighting_state:
		FightingState.WAITING_FOR_PLAYERS:
			printerr("FightingManager", battle_id, ": Should not be waiting for players here")
		FightingState.STARTING:
			print("FightingManager", battle_id, ": Starting the fight")
			fighting_state = FightingState.FIGHT
			_timer.wait_time = fight_duration
			_timer.start()
		FightingState.FIGHT:
			print("FightingManager", battle_id, ": Starting the accelerated fight (TODO)")
			fighting_state = FightingState.FIGHT_ACCELERATED
			_timer.wait_time = fight_accelerated_duration
			_timer.start()
		FightingState.FIGHT_ACCELERATED:
			print("FightingManager", battle_id, ": Ending fight (CHECK FOR WINNER)")
			fighting_state = FightingState.ENDING
			_timer.wait_time = ending_duration
			_timer.start()
		FightingState.ENDING:
			print("FightingManager", battle_id, ": Going back to buying scene")
			fighting_state = FightingState.FINISHED
		FightingState.FINISHED:
			printerr("FightingManager", battle_id, ": Should not be in finished state")


func _on_character_dead(who: Character) -> void:
	for team_members in _teams_members.values():
		who.dead.disconnect(_on_character_dead)
		team_members.erase(who)
	
	if _is_only_one_team_alive():
		fighting_state = FightingState.ENDING


func _on_state_changed(new_state) -> void:
	if new_state == FightingState.ENDING:
		_timer.timeout.disconnect(_on_timer_timeout)
		_disconnect_from_characters_signals()
		var winner_team = _get_winner_team()
		print("FightingManager", battle_id, ": THERE IS A WINNER -> TEAM", winner_team)
		fight_is_over.emit(winner_team)
























 
