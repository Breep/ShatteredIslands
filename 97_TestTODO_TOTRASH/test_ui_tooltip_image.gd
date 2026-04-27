extends Control

var tooltip : Control  # Contiendra l'UI du tooltip


# Fonction appelée lorsqu'un élément est survolé
func show_hint_tooltip(image_path: String, text: String):

	tooltip = Control.new()
	tooltip.set_anchors_preset(Control.PRESET_TOP_LEFT)
	tooltip.size = Vector2(200, 80)  # Taille du tooltip

	# Création du TextureRect (image)
	var image = TextureRect.new()
	image.texture = load(image_path)  # Charge l'image
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  # Ajuste l'affichage
	image.custom_minimum_size = Vector2(32, 32)  # Taille de l'image
	image.position = Vector2(10, 10)  # Position dans le tooltip
	
	# Création du Label (texte)
	var label = Label.new()
	label.text = text
	label.position = Vector2(50, 10)  # Décale le texte à côté de l'image
	label.add_theme_color_override("font_color", Color(1, 1, 1))  # Texte blanc

	# Ajouter les éléments au tooltip
	tooltip.add_child(image)
	tooltip.add_child(label)

	# Positionner le tooltip près de la souris
	tooltip.position = get_global_mouse_position() + Vector2(10, 10)

	# Ajouter le tooltip à la scène
	get_tree().current_scene.add_child(tooltip)

	# Supprimer après 1 seconde
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "hide_hint_tooltip"))
	tooltip.add_child(timer)
	timer.start()

# Fonction pour masquer le tooltip
func hide_hint_tooltip():
	if tooltip:
		tooltip.queue_free()


func _on_mouse_entered() -> void:
	show_hint_tooltip("res://Data/Assets/01_Card/Card_IMG/fire/icon flame.png", "Dégâts de feu !")
