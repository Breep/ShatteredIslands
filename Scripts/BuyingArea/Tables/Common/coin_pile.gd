extends Node3D

@export var player_gold: int = 47
@onready var coin_scene: PackedScene = preload("res://Scenes/buying_zone/3d_coin.tscn")
@onready var spawn_timer = Timer.new()

# Coordonnées des 6 piles
var pile_positions = [
	Vector3(0, 0, 0),
	Vector3(-0.16, 0, -0.277),
	Vector3(0.165, 0, -0.262),
	Vector3(-0.326, 0, 0),
	Vector3(0.313, 0, 0.023),
	Vector3(0.017, 0, -0.531)
]

# Hauteur actuelle de chaque pile
var pile_heights = [0, 0, 0, 0, 0, 0]

func _ready() -> void:
	add_child(spawn_timer)
	spawn_timer.wait_time = 0.1
	spawn_timer.one_shot = true

	spawn_coins()

func spawn_coins() -> void:
	for i in range(player_gold):
		# Choisir une pile au hasard
		var random_pile_index = randi() % pile_positions.size()
		var base_position = pile_positions[random_pile_index]

		# Empilage vertical : y basé sur la hauteur actuelle de la pile
		var y_offset = pile_heights[random_pile_index] * 0.1  # Décalage en Y
		pile_heights[random_pile_index] += 1  # Incrémenter la hauteur de la pile

		# Créer et positionner la pièce
		var coin_instance = coin_scene.instantiate()
		add_child(coin_instance)
		coin_instance.global_transform.origin = base_position + Vector3(global_position.x, y_offset + 1, global_position.z)
		
		# Attendre avant de continuer
		spawn_timer.start()
		await spawn_timer.timeout
