class_name Table
extends Node3D

# ============================== Local nodes ==============================

@onready var _entities_node: Node3D = %Entities

# ============================== Export (Local) ==============================

@export var _coin_piles: Array[CoinPile]
@export var _hero_spawns: Array[SpawnPoint]

@export var battle_type: Battle.BattleType
@export var battle_id: int

# ============================== Private variables ==============================

var _coin_piles_dictionary: Dictionary[SpawnPoint, CoinPile]

# ============================== Node base functions ==============================

func _ready() -> void:
	if _hero_spawns.size() != _coin_piles.size():
		printerr("Table: There are not the same amount of CoinPile/HereSpawn")
		return
	
	for i in _hero_spawns.size():
		_coin_piles_dictionary[_hero_spawns[i]] = _coin_piles[i]

# ============================== Public functions ==============================

func connect_to_players(players: Array[Player]) -> void:
	if players.size() > _hero_spawns.size():
		printerr("Table: There are too many players for this table !")
		return
	
	var avaible_spawns: Array[SpawnPoint] = _hero_spawns.duplicate()
	for player in players:
		_spawn_player_hero(player, avaible_spawns)


func cleanup() -> void:
	for coin_pile: CoinPile in _coin_piles:
		coin_pile.cleanup()

# ============================== Private functions ==============================

func _spawn_player_hero(player: Player, avaible_spawns: Array[SpawnPoint]) -> void:
	var hero: Hero = player.hero
	if hero == null:
		Verbose.error("Player " + player.player_name + " has no hero instance", Verbose.Category.TABLE)
		return

	if hero.is_inside_tree():
		Verbose.warn("Hero " + hero.entity_name + " already in tree, this shouldn't happen [TABLE]", Verbose.Category.TABLE)
		return

	# Trouver le spawn point correspondant à la team du joueur
	for spawn_point in avaible_spawns:
		if spawn_point.team == player.team:
			# Ajouter le hero à la scène
			_entities_node.add_child(hero)
			hero.global_rotation = spawn_point.global_rotation
			hero.global_position = spawn_point.global_position
			avaible_spawns.erase(spawn_point)
			_coin_piles_dictionary[spawn_point].connect_to_player(player)
			return

	Verbose.error("No spawn point found for team " + str(player.team), Verbose.Category.TABLE)
