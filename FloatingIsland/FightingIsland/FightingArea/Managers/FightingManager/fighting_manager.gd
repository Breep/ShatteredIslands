class_name FightingManager
extends Node

# ============================== Description ==============================
#
# Local FightingManager, register itself to the GlobalFightingManager
# On Start() call, will connect to all character on the local FightingArea death signals
# Will notify that the fight is over (either one team is alive or the GlobalFightingManager say it's over)

# ============================== Signals ==============================

signal fight_is_over(self_ref: FightingManager, winner_teams_order: Array[int]) # The Array is from Looser to Winner [4th, 3rd, 2nd, 1st]
signal fight_is_started(self_ref: FightingManager)

# ============================== Public variables ==============================

var battle_id: int = -1 # Set by the parent

# ============================== Private variables ==============================

# All fighting characters sorted by team
var _characters_dictionary: Dictionary[int, Array] # [int, Array[Character]] Key=team_id, value=team members
var _alive_characters_dictionary: Dictionary[int, Array] # [int, Array[Character]] Key=team_id, value=team members
var _lowest_hp_teams_order: Array[int] # Array of teams in order of death [2, 3, 4] means team 2 died first, then 3 and then 4
var _is_active: bool = false

# ============================== Node base functions ==============================

func _enter_tree() -> void:
	GlobalFightingManager.register_fighting_manager(self)
	GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)


func _exit_tree() -> void:
	GlobalFightingManager.unregister_fighting_manager(self)

# ============================== Public functions ==============================

func start(characters: Array[Character]) -> void:
	_is_active = true
	fight_is_started.emit(self)
	_setup_characters_dictionary(characters)
	_connect_to_characters_signals()

# ============================== Private functions ==============================

func _setup_characters_dictionary(characters) -> void:
	for character in characters:
		if _characters_dictionary.has(character.team):
			_characters_dictionary[character.team].append(character)
			_alive_characters_dictionary[character.team].append(character)
		else:
			_characters_dictionary[character.team] = [character]
			_alive_characters_dictionary[character.team] = [character]


func _connect_to_characters_signals() -> void:
	for team_members in _characters_dictionary.values():
		for member in team_members:
			var character: Character = member
			character.dead.connect(_on_character_dead, CONNECT_ONE_SHOT)


func _disconnect_from_characters_signals() -> void:
	for team_members in _characters_dictionary.values():
		for member in team_members:
			var character: Character = member
			if character.dead.is_connected(_on_character_dead):
				character.dead.disconnect(_on_character_dead)


# Check if there is only one team alive, also add into the _lowest_hp_teams_order the team_id of a newly dead team
func _is_only_one_team_alive() -> bool:
	var teams_number: int = _alive_characters_dictionary.size()
	var teams_alived_counter: int = 0
	for team_id in _alive_characters_dictionary.keys():
		if _alive_characters_dictionary[team_id].size() > 0:
			teams_alived_counter += 1
		elif not _lowest_hp_teams_order.has(team_id):
			_lowest_hp_teams_order.append(team_id)
	
	return teams_alived_counter == 1


# return Dictionary[team_id, total_hp]
func _get_teams_total_hp() -> Dictionary[int, int]:
	var teams_total_hp: Dictionary[int, int]
	for team_id in _characters_dictionary.keys():
		teams_total_hp[team_id] = 0
		for member in _characters_dictionary[team_id]:
			var character: Character = member
			teams_total_hp[team_id] += character.stats.health
	return teams_total_hp


# Return the teams order sorted by hp (lowest to highest)
# If several teams are already at 0, they should be already sorted in the array by _is_only_one_team_alive()
func _get_winner_teams_order() -> Array[int]:
	var teams_total_hp: Dictionary[int, int] = _get_teams_total_hp()
	var teams_total_hp_sorted: Array[int] = teams_total_hp.values().duplicate()
	teams_total_hp_sorted.sort()
	for team_hp in teams_total_hp_sorted:
		for team_id in teams_total_hp.keys():
			if team_hp == teams_total_hp[team_id] and not _lowest_hp_teams_order.has(team_id):
				_lowest_hp_teams_order.append(team_id)
	
	return _lowest_hp_teams_order


func _stop_fighting_manager() -> void:
	print("[DEBUG] Stop FightingManager [", battle_id, "] - ", _get_winner_teams_order().size())
	_is_active = false
	_disconnect_from_characters_signals()
	var winner_teams_order: Array[int] = _get_winner_teams_order()
	for member in _characters_dictionary[winner_teams_order[winner_teams_order.size() - 1]]:
		var character: Character = member
		character.fight_is_won.emit()
	fight_is_over.emit(self, winner_teams_order)
	_cleanup()


func _cleanup() -> void:
	battle_id = -1
	_is_active = false
	_characters_dictionary.clear()
	_alive_characters_dictionary.clear()
	_lowest_hp_teams_order.clear()

# ============================== Callbacks ==============================

func _on_character_dead(who: Character) -> void:
	for team_members in _alive_characters_dictionary.values():
		team_members.erase(who)
	
	if _is_only_one_team_alive():
		_stop_fighting_manager()


func _on_global_fighting_manager_state_changed(new_state) -> void:
	if not _is_active: return
	if new_state == GlobalFightingManager.FightingState.FINISHED:
		_stop_fighting_manager()
























 
