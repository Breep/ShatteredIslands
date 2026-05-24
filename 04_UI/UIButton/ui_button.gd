# Bouton UI standardisé : applique automatiquement les sons hover, click et
# disabled-click via AudioManager. Toggle `play_sounds = false` pour un bouton
# silencieux (rare). Tous les boutons du jeu doivent étendre cette classe
# plutôt que Button directement — voir AudioManager doc, Cas 4.
class_name UIButton
extends Button

#region ============================== Export ==============================
@export var play_sounds: bool = true
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	mouse_entered.connect(_on_ui_button_mouse_entered)
	pressed.connect(_on_ui_button_pressed)
	gui_input.connect(_on_ui_button_gui_input)
#endregion

#region ============================== Callbacks ==============================
func _on_ui_button_mouse_entered() -> void:
	if not play_sounds:
		return
	AudioManager.play_sfx("button_hover")


func _on_ui_button_pressed() -> void:
	if not play_sounds:
		return
	AudioManager.play_sfx("button_click")


func _on_ui_button_gui_input(event: InputEvent) -> void:
	if not play_sounds:
		return
	if not disabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		AudioManager.play_sfx("button_click_disabled")
#endregion
