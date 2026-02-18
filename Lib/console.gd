extends CanvasLayer

var label: RichTextLabel
var panel: PanelContainer
var current_font_size: int = 16

# --- RÉGLAGES ---
var max_lines: int = 1000 # Limite par défaut
var line_count: int = 0  # Compteur interne

func _ready():
	layer = 100 
	
	panel = PanelContainer.new()
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	panel.custom_minimum_size = Vector2(500, 300)
	panel.position = Vector2(10, 10)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.6)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel", style)

	label = RichTextLabel.new()
	panel.add_child(label)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.bbcode_enabled = true
	label.scroll_following = true 
	
	update_ui_style()

func _input(event):
	if event is InputEventKey and event.pressed and event.alt_pressed and event.ctrl_pressed:
		if event.keycode == KEY_T:
			visible = !visible
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_PLUS or event.keycode == KEY_KP_ADD:
			change_font_size(2)
			get_viewport().set_input_as_handled()
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
	# Affiche toujours dans la console système (F12 / Éditeur)
	print(msg) 
	
	if label:
		var time = "[color=gray]" + Time.get_time_string_from_system() + "[/color] "
		var line = time + "[color=yellow][b]>[/b][/color] " + str(msg) + "\n"
		
		label.append_text(line)
		line_count += 1
		
		# Nettoyage si on dépasse la limite
		if line_count > max_lines:
			# Supprime la ligne la plus ancienne (le paragraphe 0)
			label.remove_paragraph(0)
			line_count -= 1

# Optionnel : fonction pour vider manuellement la console
func clear():
	label.clear()
	line_count = 0
