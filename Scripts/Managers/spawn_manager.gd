extends Node
class_name SpawnManager

# ============================== Signal ==============================

signal all_players_spawned()

# ============================== Export ==============================

@export var spawns: Array[Node3D]
@export var character_scene: PackedScene

# ============================== Node base functions ==============================

func _ready() -> void:
	var i :int = 0
	for player in GameManager.players:
		var character: Character = character_scene.instantiate()
		character.global_position = spawns[i].global_position
		character.global_rotation = spawns[i].global_rotation
		character.hero = player.hero
		character.player = player
		character.team = i
		character.connect_all_players_spawned_signal(self, "all_players_spawned")
		# TODO Learn about spawning on other tree branch
		$".".add_child(character)
		i += 1
	all_players_spawned.emit()
