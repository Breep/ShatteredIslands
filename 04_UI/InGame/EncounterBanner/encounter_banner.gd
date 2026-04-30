class_name EncounterBanner
extends CanvasLayer

# Affiche temporairement un texte d'introduction quand un encounter commence.
# Écoute Game.encounter_started, lit le banner_text de l'EncounterDef, et joue
# une animation fade-in / hold / fade-out via un Tween.
# Si banner_text est vide, le banner ne s'affiche pas.

#region ============================== Constants ==============================
const FADE_IN_DURATION: float = 0.4
const HOLD_DURATION: float = 2.0
const FADE_OUT_DURATION: float = 0.6
#endregion

#region ============================== Export ==============================
# À assigner dans l'inspecteur (drag du nœud Game) pour brancher le signal.
@export var _game: Game
#endregion

#region ============================== Local nodes ==============================
@onready var _label: Label = %Label
#endregion

#region ============================== Private variables ==============================
var _current_tween: Tween
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	_label.modulate.a = 0.0
	if _game != null:
		_game.encounter_started.connect(_on_encounter_started)
	else:
		push_warning("EncounterBanner: _game non assigné, le banner ne s'affichera jamais")
#endregion

#region ============================== Private functions ==============================
func _play_animation() -> void:
	# On stoppe une animation en cours pour éviter le chevauchement si deux
	# encounters s'enchaînent rapidement.
	if _current_tween != null and _current_tween.is_valid():
		_current_tween.kill()
	_label.modulate.a = 0.0
	_current_tween = create_tween()
	_current_tween.tween_property(_label, "modulate:a", 1.0, FADE_IN_DURATION)
	_current_tween.tween_interval(HOLD_DURATION)
	_current_tween.tween_property(_label, "modulate:a", 0.0, FADE_OUT_DURATION)
#endregion

#region ============================== Callbacks ==============================
func _on_encounter_started(def: EncounterDef) -> void:
	if def == null or def.banner_text.is_empty():
		return
	_label.text = def.banner_text
	_play_animation()
#endregion
