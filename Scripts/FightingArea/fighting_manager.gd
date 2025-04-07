class_name FightingManager
extends Node

# ============================== Description ==============================
#
# Local FightingManager, register itself to the GlobalFightingManager
# On Start() call, will connect to all character on the local FightingArea death signals
# Will notify that the fight is over (either one team is alive or the GlobalFightingManager say it's over)



# ============================== Signals ==============================

signal fight_is_over(winner_team: int)

# ============================== Public variables ==============================

var battle_id: int = -1 # Set by the parent

# ============================== Private variables ==============================

var _characters_dictionary: Dictionary # [int, Array[Character]] Key=team number, value=team members

# ============================== Node base functions ==============================

func _ready() -> void:
	GlobalFightingManager.register_fighting_manager(self)
	GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)

# ============================== Public functions ==============================

func start() -> void:
	if not multiplayer.is_server():
		return
	
	_setup_characters_dictionary()
	_connect_to_characters_signals()

# ============================== Private functions ==============================

func _setup_characters_dictionary() -> void:
	var characters: Array[Character] = Shared.entity_managers_ref[battle_id].characters.values()
	for character in characters:
		if _characters_dictionary.has(character.team):
			_characters_dictionary[character.team].append(character)
		else:
			_characters_dictionary[character.team] = [character]


func _connect_to_characters_signals() -> void:
	for team_members in _characters_dictionary.values():
		for member in team_members:
			var character: Character = member
			character.dead.connect(_on_character_dead)


func _disconnect_from_characters_signals() -> void:
	for team_members in _characters_dictionary.values():
		for member in team_members:
			var character: Character = member
			character.dead.disconnect(_on_character_dead)


func _is_only_one_team_alive() -> bool:
	var teams_number: int = _characters_dictionary.size()
	var teams_alived_counter: int = 0
	for team_members in _characters_dictionary.values():
		if team_members.size() > 0:
			teams_alived_counter += 1
	
	return teams_alived_counter == 1


# Find the team with the highest sum of health percentage
func _get_winner_team() -> int:
	var team_life_percent: Dictionary[int, float] # Key=<Team number>, Value=<Sum of percentage of character hp of players in the team>
	for team_number in _characters_dictionary.keys():
		team_life_percent[team_number] = 0.0
		for member in _characters_dictionary[team_number]:
			var character: Character = member
			team_life_percent[team_number] += ((character.stats.health as float) / (character.stats.health_max as float))
	var winner_team: int = team_life_percent.keys()[0]
	for team_number in team_life_percent.keys():
		if team_life_percent[team_number] > team_life_percent[winner_team]:
			winner_team = team_number
	return winner_team


func _stop_fighting_manager() -> void:
	_disconnect_from_characters_signals()
	var winner_team = _get_winner_team()
	print("FightingManager", battle_id, ": THERE IS A WINNER -> TEAM", winner_team)
	fight_is_over.emit(winner_team)
	queue_free()

# ============================== Callbacks ==============================

func _on_character_dead(who: Character) -> void:
	for team_members in _characters_dictionary.values():
		who.dead.disconnect(_on_character_dead)
		team_members.erase(who)
	
	if _is_only_one_team_alive():
		_stop_fighting_manager()


func _on_global_fighting_manager_state_changed(new_state) -> void:
	if new_state == GlobalFightingManager.FightingState.FINISHED:
		_stop_fighting_manager()
























 
