class_name FightingManager
extends Node

# ============================== Description ==============================
#
# Local FightingManager, register itself to the GlobalFightingManager
# On Start() call, will connect to all heroes on the local FightingArea death signals
# Will notify that the fight is over (either one team is alive or the GameManager says it's over)

#region ============================== Signals ==============================
signal fight_is_over(self_ref: FightingManager, winner_teams_order: Array[int]) # The Array is from Looser to Winner [4th, 3rd, 2nd, 1st]
signal fight_is_ready_to_be_started(self_ref: FightingManager)
#endregion

#region ============================== Public variables ==============================
var battle_id: int = -1 # Set by the parent
#endregion

#region ============================== Private variables ==============================
# All fighting heroes sorted by team
var _heroes_dictionary: Dictionary[int, Array] # [int, Array[Hero]] Key=team_id, value=team members
var _alive_heroes_dictionary: Dictionary[int, Array] # [int, Array[Hero]] Key=team_id, value=team members
var _lowest_hp_teams_order: Array[int] # Array of teams in order of death [2, 3, 4] means team 2 died first, then 3 and then 4
var _is_active: bool = false
#endregion

#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	GlobalFightingManager.register_fighting_manager(self)
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)


func _exit_tree() -> void:
	GlobalFightingManager.unregister_fighting_manager(self)
#endregion

#region ============================== Public functions ==============================
func start(heroes: Array[Hero]) -> void:
	_is_active = true
	_setup_heroes_dictionary(heroes)
	_connect_to_heroes_signals()
	fight_is_ready_to_be_started.emit(self)
#endregion

#region ============================== Private functions ==============================
func _setup_heroes_dictionary(heroes: Array[Hero]) -> void:
	for hero: Hero in heroes:
		if _heroes_dictionary.has(hero.team):
			_heroes_dictionary[hero.team].append(hero)
			_alive_heroes_dictionary[hero.team].append(hero)
		else:
			_heroes_dictionary[hero.team] = [hero]
			_alive_heroes_dictionary[hero.team] = [hero]


func _connect_to_heroes_signals() -> void:
	for team_members in _heroes_dictionary.values():
		for hero: Hero in team_members:
			hero.died.connect(_on_hero_died.bind(hero), CONNECT_ONE_SHOT)


func _disconnect_from_heroes_signals() -> void:
	for team_members in _heroes_dictionary.values():
		for hero: Hero in team_members:
			if hero.died.is_connected(_on_hero_died):
				hero.died.disconnect(_on_hero_died)


# Check if there is only one team alive, also add into the _lowest_hp_teams_order the team_id of a newly dead team
func _is_only_one_team_alive() -> bool:
	var teams_alived_counter: int = 0
	for team_id in _alive_heroes_dictionary.keys():
		if _alive_heroes_dictionary[team_id].size() > 0:
			teams_alived_counter += 1
		elif not _lowest_hp_teams_order.has(team_id):
			_lowest_hp_teams_order.append(team_id)
	
	return teams_alived_counter == 1


# return Dictionary[team_id, total_hp]
func _get_teams_total_hp() -> Dictionary[int, float]:
	var teams_total_hp: Dictionary[int, float]
	for team_id in _heroes_dictionary.keys():
		teams_total_hp[team_id] = 0
		for member in _heroes_dictionary[team_id]:
			var hero: Hero = member
			teams_total_hp[team_id] += hero.stats.health
	return teams_total_hp


# Return the teams order sorted by hp (lowest to highest) [[Loosers], [], [], [], [Winners]]
# If several teams are already at 0, they should be already sorted in the array by _is_only_one_team_alive()
func _get_winner_teams_order() -> Array[int]:
	var teams_total_hp: Dictionary[int, float] = _get_teams_total_hp()
	var teams_total_hp_sorted: Array[float] = teams_total_hp.values().duplicate()
	teams_total_hp_sorted.sort()
	for team_hp in teams_total_hp_sorted:
		for team_id in teams_total_hp.keys():
			if team_hp == teams_total_hp[team_id] and not _lowest_hp_teams_order.has(team_id):
				_lowest_hp_teams_order.append(team_id)
	
	return _lowest_hp_teams_order


func _stop_fighting_manager() -> void:
	_is_active = false
	_disconnect_from_heroes_signals()
	var winner_teams_order: Array[int] = _get_winner_teams_order()
	for member in _heroes_dictionary[winner_teams_order[winner_teams_order.size() - 1]]:
		var hero: Hero = member
		# if PlayerManager.players.has(hero.owner_player_id):
		# 	Events.signal_player_won_a_fight(PlayerManager.players[hero.owner_player_id]) # TODO rework this
	for member in _heroes_dictionary[winner_teams_order[0]]:
		var hero: Hero = member
		# if PlayerManager.players.has(hero.owner_player_id):
		# 	Events.signal_player_lost_a_fight(PlayerManager.players[hero.owner_player_id]) # TODO rework this
	fight_is_over.emit(self, winner_teams_order)
	_cleanup()


func _cleanup() -> void:
	battle_id = -1
	_is_active = false
	_heroes_dictionary.clear()
	_alive_heroes_dictionary.clear()
	_lowest_hp_teams_order.clear()
#endregion

#region ============================== Callbacks ==============================
func _on_hero_died(who: Hero) -> void:
	for team_members in _alive_heroes_dictionary.values():
		team_members.erase(who)
	
	if _is_only_one_team_alive():
		_stop_fighting_manager()


func _on_gfm_fighting_phase_state_changed(new_state: GlobalFightingManager.FightingPhaseState) -> void:
	if not _is_active: return
	match new_state:
		GlobalFightingManager.FightingPhaseState.CELEBRATING:
			_stop_fighting_manager()
#endregion























 
