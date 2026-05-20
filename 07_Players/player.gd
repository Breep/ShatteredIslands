# Représente un joueur dans une session : identité réseau (id, name, team),
# porte-monnaie et progression (gold sur PlayerState ; level/xp proxiés vers
# le HeroSpec de la formation). Les données hero-level (deck, level, xp,
# data_memory) vivent canoniquement dans HeroSpec ; Player expose des getters/
# setters qui pointent dessus pour préserver l'API existante des call sites
# et pour porter les signaux runtime (lvl_changed, xp_changed).
class_name Player
extends Node

#region ============================== Variables ==============================
var player_name: String # Nickname of the player
var id: int # Multiplayer id

var is_bot: bool # If the player is a fake player (a bot controlled by the server)

var state: PlayerState

var hero: Hero
var fighting_island: FightingIsland

var skill_manager: SkillManager

var _team: int # Current team of the player during this round
var team: int:
	get: return _team
	set(value):
		_team = value
		if hero != null: hero.team = _team

# === Proxies vers HeroSpec (truth canonique des données hero-level) ===

var deck: PlayerDeck:
	get:
		var spec: HeroSpec = _get_my_hero_spec()
		return spec.deck if spec != null else null
	set(value):
		var spec: HeroSpec = _get_my_hero_spec()
		if spec != null: spec.deck = value

var data_memory: NestedRegistry:
	get:
		var spec: HeroSpec = _get_my_hero_spec()
		return spec.data_memory if spec != null else null
	set(value):
		var spec: HeroSpec = _get_my_hero_spec()
		if spec != null: spec.data_memory = value

signal lvl_changed(self_ref: Player, new_lvl: int)
var lvl: int:
	get:
		var spec: HeroSpec = _get_my_hero_spec()
		return spec.level if spec != null else 1
	set(value):
		var spec: HeroSpec = _get_my_hero_spec()
		if spec == null: return
		var clamped := clampi(value, 1, 10)
		if spec.level == clamped: return
		spec.level = clamped
		lvl_changed.emit(self, spec.level)

signal xp_changed(self_ref: Player, new_xp: int)
var xp: int:
	get:
		var spec: HeroSpec = _get_my_hero_spec()
		return spec.xp if spec != null else 0
	set(value):
		var spec: HeroSpec = _get_my_hero_spec()
		if spec == null: return
		if spec.xp == value: return
		spec.xp = value
		_check_lvl_up()
		xp_changed.emit(self, spec.xp)

# === Porte-monnaie (reste sur PlayerState) ===

signal gold_changed(self_ref: Player, new_gold: int)
var gold: int:
	get: return state.gold
	set(value):
		var clamped := clampi(value, 0, 10000)
		if state.gold == clamped: return
		state.gold = clamped
		gold_changed.emit(self, state.gold)
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
	state = PlayerState.new()
	skill_manager = SkillManager.new()
	skill_manager.init(self)


# Résout la HeroSpec du joueur dans la formation active. En solo : 1ère HeroSpec
# de party.formation. En multi (futur) : convention via slot index / mapping.
func _get_my_hero_spec() -> HeroSpec:
	if GameManager.run_context == null: return null
	if GameManager.run_context.party == null: return null
	var formation: FightingFormation = GameManager.run_context.party.formation
	if formation == null: return null
	for spec: EntitySpec in formation.entity_specs:
		if spec is HeroSpec:
			return spec
	return null


func _check_lvl_up() -> void:
	while xp >= GameManager.game_rules.xp_per_levels[lvl]:
		xp -= GameManager.game_rules.xp_per_levels[lvl]
		lvl += 1
		if lvl == GameManager.game_rules.xp_max_player_level:
			return
