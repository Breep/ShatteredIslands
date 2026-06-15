extends Control

# Proto : exerce Leaderboard + UILeaderboard en isolation. Boutons pour ajouter
# une entrée fixe / aléatoire, vider le classement et rouvrir la popup. Tape
# directement dans le Leaderboard (stockage réel user://) — le bouton "Vider"
# remet à zéro.

# ============================== Local nodes ==============================

@onready var _popup: UILeaderboard = %UILeaderboard
@onready var _add_fixed_button: Button = %AddFixedButton
@onready var _add_random_button: Button = %AddRandomButton
@onready var _clear_button: Button = %ClearButton
@onready var _open_button: Button = %OpenButton

# ============================== Constants ==============================

const _HEROES: Array[String] = ["Dark Knight", "Latika"]
const _NAMES: Array[String] = ["Breep", "Clement", "Mathieu", "Toto", "Zorg"]

# ============================== Node base functions ==============================

func _ready() -> void:
	_add_fixed_button.pressed.connect(_on_add_fixed)
	_add_random_button.pressed.connect(_on_add_random)
	_clear_button.pressed.connect(_on_clear)
	_open_button.pressed.connect(_popup.open)

# ============================== Private functions ==============================

func _on_add_fixed() -> void:
	Leaderboard.add_entry("Dummy", "Dark Knight", 3, 185)
	_popup.open()


func _on_add_random() -> void:
	Leaderboard.add_entry(_NAMES.pick_random(), _HEROES.pick_random(), randi_range(0, 5), randi_range(60, 900))
	_popup.open()


func _on_clear() -> void:
	Leaderboard.clear()
	_popup.open()
