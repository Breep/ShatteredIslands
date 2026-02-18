extends CanvasLayer

var label: RichTextLabel
var panel: PanelContainer
var current_font_size: int = 10

func _ready():
	# 1. Configuration du Layer (au-dessus de tout)
	layer = 100 
	
	# 2. Création du fond (PanelContainer avec style personnalisé)
	panel = PanelContainer.new()
	add_child(panel)
	
	# Position et taille
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	panel.custom_minimum_size = Vector2(500, 300)
	panel.position = Vector2(10, 10) # Petit décalage du bord de l'écran
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE # Ne bloque pas les clics
	
	# Style du fond (Noir semi-transparent + bords arrondis)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.6) # Noir à 60% d'opacité
	style.set_corner_radius_all(10)      # Bords arrondis
	style.set_content_margin_all(10)     # Marge interne pour le texte
	panel.add_theme_stylebox_override("panel", style)

	# 3. Configuration du texte (Enfant du panel)
	label = RichTextLabel.new()
	panel.add_child(label)
	
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.bbcode_enabled = true
	label.scroll_following = true # Auto-scroll
	
	update_ui_style()
	
	hide()

func _input(event):
	if event is InputEventKey and event.pressed and event.alt_pressed and event.ctrl_pressed:
		# Ctrl + Alt + T : Afficher/Cacher
		if event.keycode == KEY_T:
			visible = !visible
			get_viewport().set_input_as_handled()
		
		# Ctrl + Alt + Plus : Zoom
		elif event.keycode == KEY_PLUS or event.keycode == KEY_KP_ADD:
			change_font_size(2)
			get_viewport().set_input_as_handled()
			
		# Ctrl + Alt + Moins : Dézoom
		elif event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT:
			change_font_size(-2)
			get_viewport().set_input_as_handled()

func change_font_size(amount: int):
	current_font_size = clamp(current_font_size + amount, 8, 72)
	update_ui_style()

func update_ui_style():
	label.add_theme_font_size_override("normal_font_size", current_font_size)
	label.add_theme_font_size_override("bold_font_size", current_font_size)

func print(msg: Variant):
	if label:
		# Formatage avec BBCode pour la lisibilité
		label.append_text("[color=gray]" + Time.get_time_string_from_system() + "[/color] ")
		label.append_text("[color=yellow][b]>[/b][/color] " + str(msg) + "\n")
