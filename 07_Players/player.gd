# Représente un joueur dans une session : identité réseau (id, name, team),
# porte-monnaie et progression. Le héros et son inventaire vivent dans le
# Roaster du joueur (party.roasters[slot]) ; Player garde des refs directes
# (roaster, hero_entry) posées par bind_to(party), et expose des proxies
# triviaux (gold/lvl/xp/hand/data_memory) vers les sources canoniques pour
# préserver l'API des call sites et porter les signaux runtime.
class_name Player
extends Node

#region ============================== Variables ==============================
var player_name: String # Nickname of the player
var id: int # Multiplayer id

var is_bot: bool # If the player is a fake player (a bot controlled by the server)

var state: PlayerState

var hero: Entity
var fighting_island: FightingIsland

var _team: int # Current team of the player during this round
var team: int:
	get: return _team
	set(value):
		_team = value
		if hero != null: hero.team = _team

# === Refs vers la sous-partie de Party qui appartient à ce joueur ===
# Posées par bind_to(party). Null tant qu'aucun binding n'a été fait (ou si
# la party n'a pas encore de Roaster pour ce slot).

var _roaster: Roaster
var roaster: Roaster:
	get: return _roaster

var _hero_entry: RoasterEntry
var hero_entry: RoasterEntry:
	get: return _hero_entry

# === Proxies vers RoasterEntry (truth canonique des données hero-level) ===

var hand: Hand:
	get: return _hero_entry.hand if _hero_entry != null else null
	set(value):
		if _hero_entry != null: _hero_entry.hand = value

var data_memory: NestedRegistry:
	get: return _hero_entry.data_memory if _hero_entry != null else null
	set(value):
		if _hero_entry != null: _hero_entry.data_memory = value

signal lvl_changed(self_ref: Player, new_lvl: int)
var lvl: int:
	get: return _hero_entry.level if _hero_entry != null else 1
	set(value):
		if _hero_entry == null: return
		var clamped := clampi(value, 1, 10)
		if _hero_entry.level == clamped: return
		_hero_entry.level = clamped
		lvl_changed.emit(self, _hero_entry.level)

signal xp_changed(self_ref: Player, new_xp: int)
var xp: int:
	get: return _hero_entry.xp if _hero_entry != null else 0
	set(value):
		if _hero_entry == null: return
		if _hero_entry.xp == value: return
		_hero_entry.xp = value
		_check_lvl_up()
		xp_changed.emit(self, _hero_entry.xp)

# === Porte-monnaie (reste sur PlayerState) ===

signal gold_changed(self_ref: Player, new_gold: int)
var gold: int:
	get: return state.gold
	set(value):
		var clamped := clampi(value, 0, 10000)
		if state.gold == clamped: return
		var previous := state.gold
		state.gold = clamped
		gold_changed.emit(self, state.gold)
		if clamped > previous and PlayerManager.get_local_player() == self:
			Events.gold_gained.emit(clamped - previous)
#endregion

#region ============================== Public functions ==============================
func init_player() -> void:
	pass


func setup_components() -> void:
	var is_server := multiplayer.is_server()
	var is_local := (id == multiplayer.get_unique_id())

	# CardShop: local human player OR bot on server
	if (is_local and not is_bot) or (is_bot and is_server):
		var card_shop: PlayerCardShop = preload("res://01_Cards/Templates/CardShop/player_card_shop.tscn").instantiate()
		card_shop.name = "CardShop"
		card_shop.player = self
		add_child(card_shop)

	# Bot AI: only on server for bots
	if is_bot and is_server:
		var bot_ai: PlayerBotAI = preload("res://07_Players/PlayerBotAI/player_bot_ai.tscn").instantiate()
		bot_ai.player = self
		bot_ai.name = "PlayerBotAI"
		add_child(bot_ai)


# Pose les refs vers la sous-partie de Party qui appartient à ce joueur :
# - state : récupéré depuis party.players[slot] s'il y est, sinon le state
#   actuel y est ajouté (party.players partage la même ref que player.state).
# - _roaster : le Roaster du joueur (null si pas encore créé pour ce slot).
# - _hero_entry : la RoasterEntry du héros (null tant qu'aucun héros lock).
# Idempotent : peut être rappelé après tout event qui affecte ces refs (ex.
# lock_hero_into_run, load d'une run depuis disque).
func bind_to(party: Party) -> void:
	if party == null or state == null:
		return
	var matching_state: PlayerState = null
	for ps: PlayerState in party.players:
		if ps != null and ps.slot == state.slot:
			matching_state = ps
			break
	if matching_state != null:
		state = matching_state
	elif not party.players.has(state):
		party.players.append(state)
	_roaster = party.get_roaster(state.slot)
	_hero_entry = _roaster.hero if _roaster != null else null
#endregion

# ============================== Private functions ==============================
func _init() -> void:
	state = PlayerState.new()


func _check_lvl_up() -> void:
	while xp >= GameManager.game_rules.xp_per_levels[lvl]:
		xp -= GameManager.game_rules.xp_per_levels[lvl]
		lvl += 1
		if lvl == GameManager.game_rules.xp_max_player_level:
			return
