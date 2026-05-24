# Overlay de paramètres du jeu (Audio, Vidéo).
# Indépendant du contexte d'appel — show/hide depuis n'importe où.
class_name UIGameSettings
extends Control

#region ============================== Private vars ==============================
@onready var _sfx_slider: HSlider = %SFXSlider
@onready var _sfx_value_label: Label = %SFXValueLabel
@onready var _bgm_slider: HSlider = %BGMSlider
@onready var _bgm_value_label: Label = %BGMValueLabel
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	visibility_changed.connect(_emit_window_opened_if_visible)
	hide()
	_sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	_bgm_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	_refresh_labels()


func _emit_window_opened_if_visible() -> void:
	if visible:
		Events.ui_window_opened.emit()
#endregion

#region ============================== Private functions ==============================
func _refresh_labels() -> void:
	_sfx_value_label.text = str(int(_sfx_slider.value * 100)) + "%"
	_bgm_value_label.text = str(int(_bgm_slider.value * 100)) + "%"
#endregion

#region ============================== Callbacks ==============================
func _on_close_button_pressed() -> void:
	hide()


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("SFX", value)
	_sfx_value_label.text = str(int(value * 100)) + "%"


func _on_bgm_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("Music", value)
	_bgm_value_label.text = str(int(value * 100)) + "%"
#endregion
