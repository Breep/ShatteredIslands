extends Node

# ============================== Signals ==============================

# ============================== Enum ==============================

enum GameType { # Hello captain Hook
	UNDEF,
	SOLO,
	MULTIPLAYER
}

enum GameState {
	UNDEF,
	STARTING,
	INIT_ROUND,
	BUYING,
	FIGHTING,
	ENDING_ROUND,
	FINISHED,
}

# ============================== Public variables ==============================

var _game_rules: GameRules
var game_rules: GameRules:
	get: return _game_rules

var _game_type: GameType
var game_type: GameType:
	get: return _game_type

var _active_families: Array[Family] # Array of all families activated for this game only
var active_families: Array[Family]:
	get: return _active_families

# RunContext de la session courante : construit au start_solo_game (puis lu par
# Game._ready au moment du change_scene), reste accessible pendant toute la
# durée de la run pour les triggers de save inter-confrontation.
# En multi (post-démo), il faudra propager ce RunContext via RPC.
var _run_context: RunContext
var run_context: RunContext:
	get: return _run_context

var _game_state_timer: Timer
var game_state_timer: Timer:
	get: return _game_state_timer

signal game_state_changed(new_game_state: GameState)
var __game_state := GameState.UNDEF
var _game_state: GameState:
	get: return __game_state
	set(value):
		if __game_state == value: return
		__game_state = value
		_sync_game_state.rpc(__game_state)
		game_state_changed.emit(__game_state)
var game_state: GameState:
	get: return __game_state

# ============================== Private variables ==============================

var _game_scene: PackedScene = load("res://05_Game/game.tscn")
var _run_scene: PackedScene = load("res://05_Game/Run/RunRoot/run_root.tscn")

const RUN_SAVE_PATH := "user://saves/run.tres"
const DEMO_RUN_PATH := "res://05_Game/Run/Runs/Pool/Prototyping/demo_run.tres"
const DEMO_PLAYER_FORMATION_PATH := "res://05_Game/Run/Formations/Pool/Prototyping/default_solo.fighting.tres"
const DEMO_HERO_DESC_PATH := "res://02_Entities/Pool/Heroes/Latika/latika_desc.tres"
const DEMO_HERO_SCENE_PATH := "res://02_Entities/Pool/Heroes/Latika/latika.tscn"
const DEMO_ACOLYTE_SCENE_PATH := "res://02_Entities/Pool/Mobs/Chickens/Basic/chicken_basic.tscn"

var _FAMILIES_REF: Dictionary[Family.Type, Family] = {
}

# ============================== Node base functions ==============================

func _init() -> void:
	Verbose.debug("GAME MANAGER INIT", Verbose.Category.DEFAULT)
	_FAMILIES_REF[Family.Type.WARRIOR] = load("res://01_Cards/Descriptions/Families/warrior_family.tres") as Family
	_FAMILIES_REF[Family.Type.ENGINEER] = load("res://01_Cards/Descriptions/Families/Engineer/engineer_family.tres") as Family
	_FAMILIES_REF[Family.Type.ARDENT_CELESTIAL] = load("res://01_Cards/Descriptions/Families/ArdentCelestial/ardent_celestial_family.tres") as Family
	_FAMILIES_REF[Family.Type.POISON] = load("res://01_Cards/Descriptions/Families/poison_family.tres") as Family
	_FAMILIES_REF[Family.Type.STORM_CALLER] = load("res://01_Cards/Descriptions/Families/storm_caller_family.tres") as Family
	_FAMILIES_REF[Family.Type.LIGHT] = load("res://01_Cards/Descriptions/Families/light_family.tres") as Family
	_FAMILIES_REF[Family.Type.COLOSSUS] = load("res://01_Cards/Descriptions/Families/Colossus/colossus_family.tres") as Family
	_FAMILIES_REF[Family.Type.CHICKEN_LORD] = load("res://01_Cards/Descriptions/Families/ChickenLord/chicken_lord_family.tres") as Family
	_FAMILIES_REF[Family.Type.NECROSIS] = load("res://01_Cards/Descriptions/Families/necro_family.tres") as Family
	Verbose.debug("GAME MANAGER INIT", Verbose.Category.DEFAULT)

func _ready() -> void:
	_game_state_timer = Timer.new()
	_game_state_timer.autostart = false
	_game_state_timer.one_shot = true
	add_child(_game_state_timer)
	game_state_changed.connect(_on_game_state_changed)
	_game_state_timer.timeout.connect(_on_game_state_timer_timeout)
	GlobalFightingManager.all_fights_are_over.connect(_on_gfm_all_fights_are_over)

# ============================== Public function ==============================

## Request a game state transition. Only the server can change state.
## Game.gd and other scenes should call this instead of setting game_state directly.
func request_state_transition(new_state: GameState) -> void:
	if not multiplayer.is_server(): return
	_game_state = new_state


func clear() -> void:
	_game_type = GameType.UNDEF
	_active_families.clear()
	_run_context = null
	CardShopManager.clear()

	# Reset complete du state
	__game_state = GameState.UNDEF
	if _game_state_timer != null:
		_game_state_timer.stop()


func init() -> void:
	_game_rules = load("res://05_Game/GameRules/normal_game_rules.tres")
	_active_families.append(_FAMILIES_REF[Family.Type.ENGINEER])
	#_active_families.append(_FAMILIES_REF[Family.Type.POISON])
	_active_families.append(_FAMILIES_REF[Family.Type.ARDENT_CELESTIAL])
	#_active_families.append(_FAMILIES_REF[Family.Type.WARRIOR])
	#_active_families.append(_FAMILIES_REF[Family.Type.LIGHT])
	_active_families.append(_FAMILIES_REF[Family.Type.CHICKEN_LORD])
	_active_families.append(_FAMILIES_REF[Family.Type.COLOSSUS])
	#_active_families.append(_FAMILIES_REF[Family.Type.NECROSIS])


# Hérité du modèle PvP (last man standing). En roguelite la fin de run est
# pilotée par RunRoot via la complétion des confrontations, pas ici.
func is_end_of_game() -> bool:
	return PlayerManager.get_alive_players().size() == 1


func start_solo_game() -> void:
	_game_type = GameType.SOLO
	for i in 7: # TODO Avoir un nombre max de joueur qui dépend du mode ?
		PlayerManager.add_bot()
	PlayerManager.join_game(1, "Breepsolo")
	_run_context = _build_new_run_context()
	start_game()


# Flow B (roguelite démo) : 1 humain, pas de bots, Run chargée depuis le .tres
# de démo, formation joueur hardcodée (sera remplacée par un HeroSelector
# pré-run plus tard).
func start_solo_run() -> void:
	_game_type = GameType.SOLO
	PlayerManager.join_game(1, "Breepsolo")
	var demo_run: Run = load(DEMO_RUN_PATH) as Run
	if demo_run == null:
		Verbose.error("start_solo_run: demo_run.tres introuvable", Verbose.Category.GLOBAL_MANAGER)
		return
	_run_context = _build_new_run_context(demo_run)
	_populate_demo_party_formation(_run_context.party)
	start_run()


func _build_new_run_context(run: Run = null) -> RunContext:
	var ctx := RunContext.new()
	if run != null:
		ctx.run = run
	ctx.game_rules = _game_rules
	ctx.active_families = _active_families.duplicate()
	ctx.rng_seed = randi()
	ctx.started_at = int(Time.get_unix_time_from_system())
	ctx.run_id = str(ctx.started_at) + "_" + str(ctx.rng_seed)
	for player: Player in PlayerManager.players.values():
		if player.state != null:
			ctx.party.players.append(player.state)
	return ctx


func _populate_demo_party_formation(party: Party) -> void:
	var default_formation: FightingFormation = load(DEMO_PLAYER_FORMATION_PATH) as FightingFormation
	if default_formation == null:
		Verbose.error("start_solo_run: default_solo formation introuvable", Verbose.Category.GLOBAL_MANAGER)
		return

	# Roaster : source canonique. Latika + 4 chickens (chicken desc inline,
	# pas de .tres pour les chickens à ce stade — sera créé plus tard).
	# Note : `desc.scene` n'est pas stocké dans le .tres (cycle de dépendance
	# car la scene référence aussi la desc) — on l'attache ici au runtime.
	var hero_desc: EntityDesc = load(DEMO_HERO_DESC_PATH) as EntityDesc
	if hero_desc != null:
		if hero_desc.scene == null:
			hero_desc.scene = load(DEMO_HERO_SCENE_PATH) as PackedScene
		party.add_to_roaster(RoasterEntry.from_desc(hero_desc))
	else:
		Verbose.warn("start_solo_run: hero desc introuvable", Verbose.Category.GLOBAL_MANAGER)

	var chicken_desc: EntityDesc = _build_demo_chicken_desc()
	if chicken_desc != null:
		for i in 4:
			party.add_to_roaster(RoasterEntry.from_desc(chicken_desc))

	# Formation : positions issues des spawn_specs de la formation par défaut,
	# mappées aux entries du roaster dans l'ordre (hero puis acolytes).
	party.formation = _build_formation_from_roaster(party.roaster, default_formation)

	_init_roaster_runtime_data(party)


# Construit une FightingFormation en posant les entries du roaster sur les
# spawn_specs de la formation modèle. Premier hero → premier hero_spawn_spec ;
# acolytes dans l'ordre sur acolyte_spawn_specs. Surplus dropé.
func _build_formation_from_roaster(roaster: Array[RoasterEntry], template: FightingFormation) -> FightingFormation:
	var formation := FightingFormation.new()
	if template == null: return formation
	var hero_entries: Array[RoasterEntry] = []
	var acolyte_entries: Array[RoasterEntry] = []
	for entry: RoasterEntry in roaster:
		if entry == null or entry.desc == null: continue
		match entry.desc.default_category:
			Entity.Category.HERO: hero_entries.append(entry)
			Entity.Category.ACOLYTE: acolyte_entries.append(entry)

	var hero_count: int = mini(hero_entries.size(), template.hero_spawn_specs.size())
	for i in hero_count:
		formation.entity_specs.append(_make_player_spec(hero_entries[i], template.hero_spawn_specs[i].transform, "Hero_" + str(i)))

	var acolyte_count: int = mini(acolyte_entries.size(), template.acolyte_spawn_specs.size())
	for i in acolyte_count:
		formation.entity_specs.append(_make_player_spec(acolyte_entries[i], template.acolyte_spawn_specs[i].transform, "Acolyte_" + str(i)))

	return formation


func _make_player_spec(entry: RoasterEntry, t: Transform3D, label: String) -> EntitySpec:
	var spec := EntitySpec.new()
	spec.desc = entry.desc
	spec.entry = entry
	spec.transform = t
	spec.display_label = label
	return spec


func _build_demo_chicken_desc() -> EntityDesc:
	var chicken_scene: PackedScene = load(DEMO_ACOLYTE_SCENE_PATH) as PackedScene
	if chicken_scene == null:
		Verbose.warn("start_solo_run: chicken scene introuvable", Verbose.Category.GLOBAL_MANAGER)
		return null
	var desc := EntityDesc.new()
	desc.scene = chicken_scene
	desc.default_category = Entity.Category.ACOLYTE
	desc.name = "Chicken"
	return desc


# Garantit que chaque RoasterEntry hero a deck et data_memory non-null. Source
# canonique des données hero-level, lues à chaque spawn via EntitySpec.entry.
func _init_roaster_runtime_data(party: Party) -> void:
	if party == null: return
	var local_player_name: String = PlayerManager.get_local_player().player_name if PlayerManager.get_local_player() != null else ""
	for entry: RoasterEntry in party.roaster:
		if entry == null or entry.desc == null: continue
		if entry.desc.default_category != Entity.Category.HERO: continue
		if entry.deck == null:
			entry.deck = PlayerDeck.new().init(local_player_name)
		if entry.data_memory == null:
			entry.data_memory = NestedRegistry.new()


func get_active_families() -> Array[Family]:
	return _active_families


@rpc("any_peer", "call_local")
func start_game() -> void:
	CardShopManager.init(_active_families, _game_rules)
	get_tree().change_scene_to_packed(_game_scene)


@rpc("any_peer", "call_local")
func start_run() -> void:
	CardShopManager.init(_active_families, _game_rules)
	get_tree().change_scene_to_packed(_run_scene)

# ============================== Private functions ==============================

#region GAME STATE
@rpc("authority", "call_remote", "reliable")
func _sync_game_state(server_game_state: GameState) -> void:
	Verbose.debug("Sync game state | " + str(GameState.keys()[server_game_state]), Verbose.Category.GLOBAL_MANAGER)
	_game_state = server_game_state


func _on_game_state_timer_timeout() -> void:
	match _game_state:
		GameState.BUYING:
			await PlayerManager.sync_point(PlayerManager.SyncID.BUYING_PHASE)
			_game_state = GameState.FIGHTING
		GameState.FIGHTING:
			Verbose.warn("Fighting phase watchdog triggered", Verbose.Category.GLOBAL_MANAGER)
			_game_state = GameState.ENDING_ROUND
		GameState.ENDING_ROUND:
			_game_state = GameState.INIT_ROUND


func _on_game_state_changed(new_state) -> void:
	_game_state_timer.stop()
	match new_state:
		GameState.UNDEF:
			Verbose.debug("[State=UNDEF]", Verbose.Category.GLOBAL_MANAGER)
		GameState.STARTING:
			Verbose.debug("[State=STARTING]", Verbose.Category.GLOBAL_MANAGER)
		GameState.INIT_ROUND:
			Verbose.debug("[State=INIT_ROUND]", Verbose.Category.GLOBAL_MANAGER)
		GameState.BUYING:
			Verbose.debug("[State=BUYING] (" + str(_game_rules.duration_buying_phase) + "s)", Verbose.Category.GLOBAL_MANAGER)
			_game_state_timer.wait_time = _game_rules.duration_buying_phase
			_game_state_timer.start()
		GameState.FIGHTING:
			Verbose.debug("[State=FIGHTING]", Verbose.Category.GLOBAL_MANAGER)
			var watchdog_time: float = _game_rules.duration_fighting_countdown + _game_rules.duration_fighting_normal
			watchdog_time += _game_rules.duration_fighting_special + _game_rules.duration_fighting_celebration
			watchdog_time += 10 # MAGIC NUMBER => TODO define it ?
			_game_state_timer.wait_time = watchdog_time
			_game_state_timer.start()
		GameState.ENDING_ROUND:
			Verbose.debug("[State=ENDING_ROUND]", Verbose.Category.GLOBAL_MANAGER)
			await get_tree().create_timer(0.1).timeout # Quick fix to avoid recursive signals
			await PlayerManager.sync_point(PlayerManager.SyncID.FIGHTING_PHASE)
			_game_state_timer.wait_time = _game_rules.duration_fighting_finished
			_game_state_timer.start()
		GameState.FINISHED:
			Verbose.debug("[State=FINISHED]", Verbose.Category.GLOBAL_MANAGER)


func save_run_context() -> void:
	if not multiplayer.is_server(): return # autorité hôte
	if _run_context == null: return
	var err: Error = _run_context.save_to(RUN_SAVE_PATH)
	if err == OK:
		Verbose.debug("RunContext saved to " + RUN_SAVE_PATH, Verbose.Category.SAVE)
	else:
		Verbose.error("Failed to save RunContext (err=" + str(err) + ") to " + RUN_SAVE_PATH, Verbose.Category.SAVE)


func clear_save() -> void:
	if not multiplayer.is_server(): return
	if not FileAccess.file_exists(RUN_SAVE_PATH): return
	var err: Error = DirAccess.remove_absolute(RUN_SAVE_PATH)
	if err == OK:
		Verbose.debug("RunContext save cleared: " + RUN_SAVE_PATH, Verbose.Category.SAVE)
	else:
		Verbose.warn("Failed to clear save (err=" + str(err) + ") at " + RUN_SAVE_PATH, Verbose.Category.SAVE)


func _on_gfm_all_fights_are_over() -> void:
	Verbose.trace("GFM signals that all fights are over")
	if _game_state != GameState.FIGHTING:
		Verbose.error("GFM signals that all fights are over but the GameManager state isn't on FIGHTING", Verbose.Category.GLOBAL_MANAGER)
		return
	_game_state_timer.stop()
	_game_state = GameState.ENDING_ROUND
#endregion
