# Représente un joueur dans une session : identité réseau (id, name, team),
# porte-monnaie et progression (gold sur PlayerState ; level/xp proxiés vers
# la RoasterEntry du héros dans party.roaster). Les données hero-level (deck,
# level, xp, data_memory) vivent canoniquement dans RoasterEntry ; Player
# expose des getters/setters qui pointent dessus pour préserver l'API
# existante des call sites et pour porter les signaux runtime (lvl_changed,
# xp_changed).
class_name Player
extends Node

#region ============================== Variables ==============================
var player_name: String # Nickname of the player
var id: int # Multiplayer id

var is_bot: bool # If the player is a fake player (a bot controlled by the server)

var state: PlayerState

var hero: Entity
var fighting_island: FightingIsland

var skill_manager: SkillManager

var _team: int # Current team of the player during this round
var team: int:
	get: return _team
	set(value):
		_team = value
		if hero != null: hero.team = _team

# === Proxies vers RoasterEntry (truth canonique des données hero-level) ===

var deck: Hand:
	get:
		var entry: RoasterEntry = _get_my_roaster_entry()
		return entry.deck if entry != null else null
	set(value):
		var entry: RoasterEntry = _get_my_roaster_entry()
		if entry != null: entry.deck = value

var data_memory: NestedRegistry:
	get:
		var entry: RoasterEntry = _get_my_roaster_entry()
		return entry.data_memory if entry != null else null
	set(value):
		var entry: RoasterEntry = _get_my_roaster_entry()
		if entry != null: entry.data_memory = value

signal lvl_changed(self_ref: Player, new_lvl: int)
var lvl: int:
	get:
		var entry: RoasterEntry = _get_my_roaster_entry()
		return entry.level if entry != null else 1
	set(value):
		var entry: RoasterEntry = _get_my_roaster_entry()
		if entry == null: return
		var clamped := clampi(value, 1, 10)
		if entry.level == clamped: return
		entry.level = clamped
		lvl_changed.emit(self, entry.level)

signal xp_changed(self_ref: Player, new_xp: int)
var xp: int:
	get:
		var entry: RoasterEntry = _get_my_roaster_entry()
		return entry.xp if entry != null else 0
	set(value):
		var entry: RoasterEntry = _get_my_roaster_entry()
		if entry == null: return
		if entry.xp == value: return
		entry.xp = value
		_check_lvl_up()
		xp_changed.emit(self, entry.xp)

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
		var card_shop: PlayerCardShop = preload("res://05_Game/CardShop/player_card_shop.tscn").instantiate()
		card_shop.name = "CardShop"
		card_shop.player = self
		add_child(card_shop)

	# Bot AI: only on server for bots
	if is_bot and is_server:
		var bot_ai: PlayerBotAI = preload("res://07_Players/PlayerBotAI/player_bot_ai.tscn").instantiate()
		bot_ai.player = self
		bot_ai.name = "PlayerBotAI"
		add_child(bot_ai)
#endregion

# ============================== Private functions ==============================
func _init() -> void:
	deck = Hand.new()
	state = PlayerState.new()
	skill_manager = SkillManager.new()
	skill_manager.init(self)


# Résout la RoasterEntry du joueur dans la party active. En solo : 1ère entry
# de catégorie HERO. En multi (futur) : convention via slot index / mapping.
func _get_my_roaster_entry() -> RoasterEntry:
	if GameManager.run_context == null: return null
	if GameManager.run_context.party == null: return null
	return GameManager.run_context.party.get_first_entry_of_category(Entity.Category.HERO)


func _check_lvl_up() -> void:
	while xp >= GameManager.game_rules.xp_per_levels[lvl]:
		xp -= GameManager.game_rules.xp_per_levels[lvl]
		lvl += 1
		if lvl == GameManager.game_rules.xp_max_player_level:
			return
