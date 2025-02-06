extends Camera3D

@export var move_speed: float = 10.0  # Vitesse de déplacement de la caméra

func _process(delta: float) -> void:
	var movement = Vector3.ZERO

	# Déplacement gauche/droite (A/D ou flèches gauche/droite)
	if Input.is_action_pressed("move_left"):  # Par défaut, "A" ou flèche gauche
		movement.x -= 1
	if Input.is_action_pressed("move_right"):  # Par défaut, "D" ou flèche droite
		movement.x += 1

	# Déplacement haut/bas (W/S ou flèches haut/bas)
	if Input.is_action_pressed("move_up"):  # Par défaut, "W" ou flèche haut
		movement.y += 1
	if Input.is_action_pressed("move_down"):  # Par défaut, "S" ou flèche bas
		movement.y -= 1

	# Normalisation pour éviter les déplacements plus rapides en diagonale
	if movement.length() > 0:
		movement = movement.normalized() * move_speed * delta
		translate(movement)
