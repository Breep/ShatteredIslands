class_name Table
extends Node3D

# ============================== Local nodes ==============================

@onready var entities_node: Node3D = %Entities

# ============================== Export (Local) ==============================

@export var _coin_piles: Array[CoinPile]
@export var _hero_spawns: Array[SpawnPoint]

@export var battle_type: Battle.BattleType
@export var battle_id: int

# ============================== Node base functions ==============================

func _ready() -> void:
	if _hero_spawns.size() != _coin_piles.size(): # or _card_fans.size() != _hero_spawns.size():
		printerr("Table: There are not the same amount of CoinPile/HereSpawn")
		return

# ============================== Public functions ==============================

func connect_to_players(players: Array[Player]) -> void:
	if players.size() > _hero_spawns.size():
		printerr("Table: There are too many players for this table !")
		return
		
	var avaible_spawns: Array[SpawnPoint] = _hero_spawns.duplicate()
	for player in players:
		_spawn_player_character(player, avaible_spawns)

# ============================== Private functions ==============================

func _spawn_player_character(player: Player, avaible_spawns: Array[SpawnPoint]) -> void:
	var character: Character = player.character
	for spawn_point in avaible_spawns:
		if spawn_point.team == player.team:
			reparent_entity.rpc(character.get_path(), entities_node.get_path())
			character.global_rotation = spawn_point.global_rotation
			character.global_position = spawn_point.global_position
			avaible_spawns.erase(spawn_point)
			return
			#_coin_piles[i].connect_to_player(players[i])


@rpc("authority", "call_local")
func reparent_entity(entity_path: NodePath, new_parent_path: NodePath):
	var entity = get_node(entity_path)
	var new_parent = get_node(new_parent_path)
	if entity and new_parent:
		entity.reparent(new_parent)
