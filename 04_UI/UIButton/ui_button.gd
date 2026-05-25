# Bouton UI standardisé : applique automatiquement les sons hover, click et
# disabled-click via AudioManager (bus UI). Tous les boutons du jeu doivent
# étendre cette classe plutôt que Button directement — voir AudioManager doc,
# Cas 4.
#
# Overrides disponibles dans l'inspecteur :
# - `play_sounds = false` : silencer le bouton entier
# - `hover_sound_key` / `click_sound_key` / `disabled_click_sound_key` :
#    remplacer la clé SFX par défaut. Mettre "" pour désactiver un son précis.
# - `sound_volume_db` : offset volume (ex: -6.0 pour un bouton plus discret).
class_name UIButton
extends Button

#region ============================== Export ==============================
@export var play_sounds: bool = true

@export_group("Sound overrides")
@export var hover_sound_key: String = "button_hover"
@export var click_sound_key: String = "button_click"
@export var disabled_click_sound_key: String = "button_click_disabled"
@export var sound_volume_db: float = 0.0
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	mouse_entered.connect(_on_ui_button_mouse_entered)
	pressed.connect(_on_ui_button_pressed)
	gui_input.connect(_on_ui_button_gui_input)
#endregion

#region ============================== Callbacks ==============================
func _on_ui_button_mouse_entered() -> void:
	if not play_sounds or hover_sound_key.is_empty():
		return
	AudioManager.play_ui(hover_sound_key, sound_volume_db)


func _on_ui_button_pressed() -> void:
	if not play_sounds or click_sound_key.is_empty():
		return
	AudioManager.play_ui(click_sound_key, sound_volume_db)


func _on_ui_button_gui_input(event: InputEvent) -> void:
	if not play_sounds or disabled_click_sound_key.is_empty():
		return
	if not disabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		AudioManager.play_ui(disabled_click_sound_key, sound_volume_db)
#endregion
