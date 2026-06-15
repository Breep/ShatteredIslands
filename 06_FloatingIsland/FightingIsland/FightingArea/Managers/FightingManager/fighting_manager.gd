class_name FightingManager
extends Node

# ============================== Description ==============================
#
# Local FightingManager : possède sa propre machine d'états (LocalPhase) pilotée
# par le GlobalFightingManager. Tracke le roster vivant par équipe/rôle pour
# détecter la fin du combat local sous l'EliminationMode actif. `_physics_process`
# tick le combat tant que `_is_active` (uniquement en LocalPhase.FIGHTING).


enum EliminationMode {
	KILL_ALL,         # Team out when every entity (Hero + Antagonist + Acolyte + Mobs + Summons) is dead
	KILL_MAIN,        # Team out when every Hero/Antagonist (FightRole.MAIN) is dead
	KILL_SECONDARY,   # Team out when every MAIN + every Acolyte (FightRole.SECONDARY) is dead
}

# Machine d'états locale du FM. Pilotée par GFM via start_positioning/fighting/celebration.
# L'UI déclenche les transitions sortantes des phases bloquantes via request_phase_advance.
enum LocalPhase {
	UNDEF,
	POSITIONING,   # Bloquant : attend request_phase_advance() pour signaler positioning_done
	FIGHTING,      # Combat actif : _physics_process tick
	CELEBRATION,   # Bloquant : attend request_phase_advance() pour signaler celebration_done
}

#region ============================== Signals ==============================
signal fight_is_ready_to_be_started(self_ref: FightingManager)
signal phase_changed(self_ref: FightingManager, new_phase: LocalPhase)
signal positioning_done(self_ref: FightingManager)
signal fight_done(self_ref: FightingManager, winner_teams_order: Array[int]) # [loser, winner]
signal celebration_done(self_ref: FightingManager)
#endregion

#region ============================== Constants ==============================
const _ELIMINATION_MODE := EliminationMode.KILL_ALL
#endregion

#region ============================== Public variables ==============================
var _battle_id: int = -1 # Set by the parent
var current_tick: int = 0 # Fight tick counter
#endregion

#region ============================== Private variables ==============================
# Alive roster bucketed by team then by fight role for O(1) elimination checks.
# Dictionary[team_id, Dictionary[Entity.FightRole, Array[Entity]]]
var _alive_by_team: Dictionary[int, Dictionary]
# Flat tracker of every entity we registered, used for signal cleanup.
var _registered_entities: Array[Entity]
var _is_active: bool = false
var _fight_ended: bool = false # Guard against late entity_spawned callbacks after stop
var _local_phase: LocalPhase = LocalPhase.UNDEF
var _pending_winner_teams_order: Array[int]

var _spawn_manager: SpawnManager
#endregion

#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	GlobalFightingManager.register_fighting_manager(self)


func _exit_tree() -> void:
	GlobalFightingManager.unregister_fighting_manager(self)


func _physics_process(_delta: float) -> void:
	if not _is_active: return
	# Sort by uid to guarantee identical processing order on all clients (determinism)
	var entities: Array[Entity] = _spawn_manager.get_entities()
	entities.sort_custom(func(a: Entity, b: Entity) -> bool: return a.uid < b.uid)
	for entity in entities:
		entity.process_tick()
	var projectiles: Array[Projectile] = _spawn_manager.get_projectiles()
	projectiles.sort_custom(func(a: Projectile, b: Projectile) -> bool: return a.uid < b.uid)
	for projectile in projectiles:
		projectile.process_tick()
	current_tick += 1
#endregion

#region ============================== Public functions ==============================
# Caller responsibility: spawn all initial entities into the SpawnManager BEFORE calling init().
# Tagging of fight_role on each entity is done by FightingArea._spawn_specs based on spec type.
func init(spawn_manager: SpawnManager, battle_id: int) -> void:
	_spawn_manager = spawn_manager
	_battle_id = battle_id
	_fight_ended = false
	_local_phase = LocalPhase.UNDEF
	_pending_winner_teams_order.clear()
	Utils.register_battle_rng(_battle_id, hash(str(_battle_id))) # TODO Make the server generate seeds and send it to clients

	# Snapshot the initial roster (spawns already done by FightingArea.init_fight)
	for entity: Entity in _spawn_manager.get_entities():
		_register_entity(entity)

	# Subscribe to late spawns (summons happening during the fight)
	_spawn_manager.entity_spawned.connect(_register_entity)

	fight_is_ready_to_be_started.emit(self)


# Entrée en phase POSITIONING. Appelée par GFM. Bloquante : attend request_phase_advance().
func start_positioning() -> void:
	if _local_phase != LocalPhase.UNDEF:
		Verbose.warn("FightingManager.start_positioning: illegal transition from " + str(LocalPhase.keys()[_local_phase]), Verbose.Category.FIGHTING_AREA)
		return
	_local_phase = LocalPhase.POSITIONING
	phase_changed.emit(self, _local_phase)


# Entrée en phase FIGHTING (combat actif). Appelée par GFM.
func start_fighting() -> void:
	if _local_phase != LocalPhase.POSITIONING:
		Verbose.warn("FightingManager.start_fighting: illegal transition from " + str(LocalPhase.keys()[_local_phase]), Verbose.Category.FIGHTING_AREA)
		return
	_local_phase = LocalPhase.FIGHTING
	current_tick = 0
	_is_active = true
	phase_changed.emit(self, _local_phase)


# Entrée en phase CELEBRATION. Appelée par GFM (sur fight_done de tous les FMs ou
# forçage via SPECIAL timeout). Bloquante : attend request_phase_advance().
func start_celebration() -> void:
	if _local_phase != LocalPhase.FIGHTING:
		Verbose.warn("FightingManager.start_celebration: illegal transition from " + str(LocalPhase.keys()[_local_phase]), Verbose.Category.FIGHTING_AREA)
		return
	_local_phase = LocalPhase.CELEBRATION
	_is_active = false
	_fight_ended = true

	# Si fight_done n'a pas encore été émis (cas SPECIAL timeout forcé sans élimination),
	# on calcule maintenant le winner order via le fallback HP-eligible-count.
	if _pending_winner_teams_order.is_empty():
		_pending_winner_teams_order = _build_winner_teams_order()

	var winner_team: int = _pending_winner_teams_order[_pending_winner_teams_order.size() - 1]
	for team_id in _alive_by_team.keys():
		var is_winner: bool = team_id == winner_team
		for role in _alive_by_team[team_id].keys():
			for entity in _alive_by_team[team_id][role]:
				if not is_instance_valid(entity): continue
				entity.handle_end_of_fight(is_winner)

	_disconnect_all()
	_cleanup()
	phase_changed.emit(self, _local_phase)


# Avance la phase bloquante courante. Appelée par l'UI sur clic READY (POSITIONING)
# ou NEXT (CELEBRATION).
func request_phase_advance() -> void:
	match _local_phase:
		LocalPhase.POSITIONING:
			positioning_done.emit(self)
		LocalPhase.CELEBRATION:
			celebration_done.emit(self)
		_:
			Verbose.warn("FightingManager.request_phase_advance: no-op in phase " + str(LocalPhase.keys()[_local_phase]), Verbose.Category.FIGHTING_AREA)
#endregion

#region ============================== Private functions ==============================
func _register_entity(entity: Entity) -> void:
	if _fight_ended: return  # Guard against synchronous death→summon chains after stop
	if entity == null or entity.team < 0: return
	if entity in _registered_entities: return  # Idempotent

	if not _alive_by_team.has(entity.team):
		_alive_by_team[entity.team] = {
			Entity.FightRole.MAIN: [],
			Entity.FightRole.SECONDARY: [],
			Entity.FightRole.EXTRA: [],
		}
	_alive_by_team[entity.team][entity.fight_role].append(entity)
	_registered_entities.append(entity)

	# Not CONNECT_ONE_SHOT — must survive resurrect → re-death cycles.
	# .bind(entity) compense le `died.emit()` qui n'envoie pas de payload (à fixer un jour).
	entity.died.connect(_on_entity_died.bind(entity))
	entity.resurrected.connect(_on_entity_resurrected.bind(entity))


func _is_team_eliminated(team_id: int) -> bool:
	var team: Dictionary = _alive_by_team[team_id]
	match _ELIMINATION_MODE:
		EliminationMode.KILL_MAIN:
			return team[Entity.FightRole.MAIN].is_empty()
		EliminationMode.KILL_SECONDARY:
			return team[Entity.FightRole.MAIN].is_empty() \
				and team[Entity.FightRole.SECONDARY].is_empty()
		EliminationMode.KILL_ALL:
			return team[Entity.FightRole.MAIN].is_empty() \
				and team[Entity.FightRole.SECONDARY].is_empty() \
				and team[Entity.FightRole.EXTRA].is_empty()
	return false


func _alive_eligible_count(team_id: int) -> int:
	var team: Dictionary = _alive_by_team[team_id]
	match _ELIMINATION_MODE:
		EliminationMode.KILL_MAIN:
			return team[Entity.FightRole.MAIN].size()
		EliminationMode.KILL_SECONDARY:
			return team[Entity.FightRole.MAIN].size() + team[Entity.FightRole.SECONDARY].size()
		EliminationMode.KILL_ALL:
			return team[Entity.FightRole.MAIN].size() \
				+ team[Entity.FightRole.SECONDARY].size() \
				+ team[Entity.FightRole.EXTRA].size()
	return 0


func _check_fight_over() -> void:
	if _fight_ended: return
	var surviving_teams: int = 0
	for team_id in _alive_by_team.keys():
		if not _is_team_eliminated(team_id):
			surviving_teams += 1
	if surviving_teams <= 1:
		_signal_local_fight_done()


# Élimination locale : on stoppe le tick, calcule le résultat, émet fight_done.
# La phase CELEBRATION sera entrée plus tard via start_celebration() (pilotée par GFM).
func _signal_local_fight_done() -> void:
	if _fight_ended: return
	_fight_ended = true
	_is_active = false
	_pending_winner_teams_order = _build_winner_teams_order()
	fight_done.emit(self, _pending_winner_teams_order)


# Build the winner order : [loser, winner]. Assumes 2 teams.
# If no team is fully eliminated (SPECIAL timeout), pick the loser by smaller
# eligible-alive count; tiebreak on lowest team_id for determinism.
func _build_winner_teams_order() -> Array[int]:
	var team_ids: Array[int] = []
	for k in _alive_by_team.keys():
		team_ids.append(k)
	assert(team_ids.size() == 2, "FightingManager: design assumes exactly 2 teams")

	var eliminated: Array[int] = []
	for team_id in team_ids:
		if _is_team_eliminated(team_id):
			eliminated.append(team_id)

	if eliminated.size() >= 1:
		var loser: int = eliminated[0]
		var winner: int = team_ids[0] if team_ids[1] == loser else team_ids[1]
		return [loser, winner]

	# Fallback: timeout fired without any team eliminated.
	var counts: Dictionary[int, int] = {}
	for team_id in team_ids:
		counts[team_id] = _alive_eligible_count(team_id)
	team_ids.sort_custom(
		func(a: int, b: int) -> bool:
			if counts[a] != counts[b]: return counts[a] < counts[b]
			return a < b
	)
	return team_ids


func _disconnect_all() -> void:
	if _spawn_manager != null and _spawn_manager.entity_spawned.is_connected(_register_entity):
		_spawn_manager.entity_spawned.disconnect(_register_entity)
	for entity in _registered_entities:
		if not is_instance_valid(entity): continue
		# died and resurrected are both connected via .bind(entity) — match by method name.
		for cb in entity.died.get_connections():
			if cb.callable.get_method() == "_on_entity_died":
				entity.died.disconnect(cb.callable)
		for cb in entity.resurrected.get_connections():
			if cb.callable.get_method() == "_on_entity_resurrected":
				entity.resurrected.disconnect(cb.callable)


func _cleanup() -> void:
	Utils.unregister_battle_rng(_battle_id)
	_battle_id = -1
	_alive_by_team.clear()
	_registered_entities.clear()
#endregion

#region ============================== Callbacks ==============================
func _on_entity_died(entity: Entity) -> void:
	if _fight_ended: return
	if entity == null: return
	# L'entité peut renaître : elle reste dans le roster pour ne pas terminer le
	# combat prématurément pendant la fenêtre de résurrection.
	if entity.can_revive: return
	if not _alive_by_team.has(entity.team): return
	_alive_by_team[entity.team][entity.fight_role].erase(entity)  # erase is idempotent
	_check_fight_over()


func _on_entity_resurrected(entity: Entity) -> void:
	if _fight_ended: return
	if entity == null: return
	if not _alive_by_team.has(entity.team): return
	var bucket: Array = _alive_by_team[entity.team][entity.fight_role]
	if not entity in bucket:
		bucket.append(entity)
#endregion
