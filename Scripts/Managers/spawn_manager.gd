extends Node
class_name SpawnManager

# ============================== Export ==============================

@export var spawns: Array[Node2D]
@export var character_scene: PackedScene

# ============================== Node base functions ==============================

func _ready() -> void:
	for player in GameManager.players:
		var character: Character = character_scene.instantiate()
		character.global_position = spawns[0].global_position
		character.global_rotation = spawns[0].global_rotation
		character.hero = player.hero
		character.player_deck = player.deck
		character.team = 0
		# TODO Learn about spawning on other tree branch
		$".".add_child(character)
