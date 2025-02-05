extends Node3D

@export var player_gold: int = 47
@onready var coin_scene: PackedScene = preload("res://Scenes/buying_zone/3d_coin.tscn")  # Remplace par le bon chemin

# Timer pour gérer le délai entre chaque pièce
@onready var spawn_timer = Timer.new()

func _ready() -> void:
	add_child(spawn_timer)
	spawn_timer.wait_time = 0.1  # Délai de 0.1 seconde entre chaque pièce
	spawn_timer.one_shot = true  # Le timer ne boucle pas automatiquement

	spawn_coins()

func spawn_coins() -> void:
	var y = 0.0
	for i in range(player_gold):
		y = i * 0.1  # Empilage vertical
		var coin_instance = coin_scene.instantiate()
		add_child(coin_instance)
		
		# Position de la pièce (décalée en Y pour l'empilage)
		coin_instance.global_transform.origin = Vector3(global_position.x, y+1, global_position.z)
		
		# Attendre la fin du timer avant de continuer la boucle
		spawn_timer.start()
		await spawn_timer.timeout
