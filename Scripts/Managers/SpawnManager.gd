extends Node
class_name SpawnManager

@export var spawns: Array[Node2D]
@export var characterScene: PackedScene
@export var fightingArea: Node2D

func _ready() -> void:
	print("SpawnManager")
	print(spawns[0].global_position)
	for player in GameManager.players:
		var character: Character = characterScene.instantiate()
		character.global_position = spawns[0].global_position
		character.global_rotation = spawns[0].global_rotation
		character.hero = player.hero
		character.playerDeck = player.deck
		character.team = 0
		#fightingArea.add_child(character)
		#add_child(character)
		$".".add_child(character)
		print("COUCOU")
	print(get_tree_string_pretty())
