class_name Player
extends Resource

# ============================== Enum ==============================

enum SerializedField {
	NAME,
	ID,
	TEAM,
	HEALTH,
	MAX_HEALTH,
	DAMAGE,
	HERO,
	GOLD,
	XP,
	IS_BOT,
}

# ============================== Variables ==============================

var name: String # Nickname of the player
var id: int # Multiplayer id

var is_bot: bool # If the player is a fake player (a bot controlled by the server)

var ready: bool # If this player is ready to continue the game flow (Used to sync players with server)

var deck: PlayerDeck
var character: Character
var fighting_island: FightingIsland

var win_streak: int
var health_lost_since_last_round: int
var total_win_number: int
var total_lose_number: int
var current_damage_win_lose_diff: int # <win>-<lose> but can't go over what the rules indicate (used for damage modifier)
var battle_history: Array[Battle.BattleResolution]

var is_dead: bool = false # True if the player is dead and signaled it
var round_of_death: int = -1 # The round when the player died (if dead)

var skill_manager: SkillManager

var _team: int # Current team of the player during this round
var team: int:
	get: return _team
	set(value):
		_team = value
		if character != null: character.team = _team

signal lvl_changed(self_ref: Player, new_lvl: int)
var _lvl: int = 1
var lvl: int:
	get: return _lvl
	set(value):
		if _lvl == value: return
		_lvl = clampi(value, 1, 10)
		lvl_changed.emit(self, _lvl)

signal xp_changed(self_ref: Player, new_xp: int)
var _xp: int
var xp: int:
	get: return _xp
	set(value):
		if _xp == value: return
		_xp = value
		_check_lvl_up()
		xp_changed.emit(self, _xp)

signal hero_changed(self_ref: Player, new_hero: Hero)
var _hero: Hero
var hero: Hero:
	get: return _hero
	set(value):
		if _hero == value: return
		_hero = value
		hero_changed.emit(self, _hero)

signal max_health_changed(self_ref: Player, new_max_health: int)
var _max_health: int
var max_health: int:
	get: return _max_health
	set(value):
		if _max_health == value: return
		_max_health = clampi(value, 0, 100) # TODO la valeur de 100 est purement arbitraire
		max_health_changed.emit(self, _max_health)

signal death(self_ref: Player)
signal health_changed(self_ref: Player, new_health: int)
var _health: int
var health: int:
	get: return _health
	set(value):
		if _health == value: return
		_health = clampi(value, -100, 100)
		health_changed.emit(self, _health)
		if _health <= 0: # TODO Change this by a pile of corpse is funnier
			death.emit(self)
			character.queue_free()

signal gold_changed(self_ref: Player, new_gold: int)
var _gold: int
var gold: int:
	get: return _gold
	set(value):
		if _gold == value: return
		_gold = clampi(value, 0, 10000)
		gold_changed.emit(self, _gold)

signal damage_changed(self_ref: Player, new_damage: int)
var _damage: int
var damage: int:
	get: return _damage
	set(value):
		if _damage == value: return
		_damage = value
		damage_changed.emit(self, _damage)

# ============================== Static functions ==============================

static func new_from_serialized(serialized_data: Dictionary) -> Player:
	var player := Player.new()
	player.skill_manager = SkillManager.new()
	player.name = serialized_data[SerializedField.NAME]
	player.id = serialized_data[SerializedField.ID]
	player.team = serialized_data[SerializedField.TEAM]
	player.health = serialized_data[SerializedField.HEALTH]
	player.max_health = serialized_data[SerializedField.MAX_HEALTH]
	player.damage = serialized_data[SerializedField.DAMAGE]
	player.hero = Shared.HEROES[serialized_data[SerializedField.HERO]]
	player.gold = serialized_data[SerializedField.GOLD]
	player.is_bot = serialized_data[SerializedField.IS_BOT]
	player.xp = serialized_data[SerializedField.XP]
	return player

# ============================== Public functions ==============================

func serialized() -> Dictionary:
	var serialized_version = {
		SerializedField.NAME: name,
		SerializedField.ID: id,
		SerializedField.TEAM: team,
		SerializedField.HEALTH: health,
		SerializedField.MAX_HEALTH: max_health,
		SerializedField.DAMAGE: damage,
		SerializedField.HERO: 0 if hero == null else hero.id,
		SerializedField.GOLD: gold,
		SerializedField.IS_BOT: is_bot,
		SerializedField.XP: xp,
	}
	return serialized_version


func update_from_serialized(serialized_data: Dictionary) -> void:
	name = serialized_data[SerializedField.NAME]
	id = serialized_data[SerializedField.ID]
	team = serialized_data[SerializedField.TEAM]
	health = serialized_data[SerializedField.HEALTH]
	max_health = serialized_data[SerializedField.MAX_HEALTH]
	damage = serialized_data[SerializedField.DAMAGE]
	hero = Shared.HEROES[serialized_data[SerializedField.HERO]]
	gold = serialized_data[SerializedField.GOLD]
	is_bot = serialized_data[SerializedField.IS_BOT]
	xp = serialized_data[SerializedField.XP]


func spawn_character(spawn_node: Node3D, spawn_point: SpawnPoint) -> Character:
	if character != null: character.queue_free()
	var new_character: Character = preload("res://Entities/Character/character.tscn").instantiate()
	new_character.owner_player_id = id
	new_character.hero_id = hero.id
	new_character.name = "Character_" + hero.name
	character = new_character
	spawn_node.add_child(character)
	character.global_rotation = spawn_point.global_rotation
	character.global_position = spawn_point.global_position
	return character

# ============================== Resource base functions ==============================

func _init() -> void:
	deck = PlayerDeck.new()
	deck.has_changed.connect(_on_deck_has_changed)

# ============================== Private functions ==============================

func _apply_all_cards_upgrades() -> void:
	if deck == null or character == null:
		printerr("Player: Can't apply cards upgrades")
		return
	character.apply_cards_upgrade(deck)


func _check_lvl_up() -> void:
	while xp >= GameManager.game_rules.xp_per_levels[_lvl]:
		xp -= GameManager.game_rules.xp_per_levels[_lvl]
		lvl += 1
		if _lvl == GameManager.game_rules.xp_max_player_level:
			return

# ============================== Callbacks ==============================

func _on_deck_has_changed() -> void:
	#print("Player[", name, "]: Deck has changed")
	_apply_all_cards_upgrades()
















 
