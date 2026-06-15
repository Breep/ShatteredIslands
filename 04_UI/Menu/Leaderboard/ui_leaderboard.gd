class_name UILeaderboard
extends Control

# Popup de classement : affiche les entrées du Leaderboard (triées rencontres
# vaincues puis temps) sous forme de lignes. Peuplée à chaque ouverture via open().

# ============================== Local nodes ==============================

@onready var _entries_container: VBoxContainer = %EntriesContainer
@onready var _empty_label: Label = %EmptyLabel

# ============================== Node base functions ==============================

func _ready() -> void:
	hide()

# ============================== Public functions ==============================

func open() -> void:
	_populate()
	show()

# ============================== Private functions ==============================

func _populate() -> void:
	for child: Node in _entries_container.get_children():
		child.queue_free()

	var entries: Array[Dictionary] = Leaderboard.get_entries()
	_empty_label.visible = entries.is_empty()

	var rank: int = 1
	for entry: Dictionary in entries:
		_entries_container.add_child(_make_row(rank, entry))
		rank += 1


func _make_row(rank: int, entry: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	row.add_child(_make_cell(str(rank), 50))
	row.add_child(_make_cell(str(entry.get(Leaderboard.KEY_NAME, "")), 220))
	row.add_child(_make_cell(str(entry.get(Leaderboard.KEY_HERO, "")), 180))
	row.add_child(_make_cell(str(entry.get(Leaderboard.KEY_ENCOUNTERS, 0)), 130))
	row.add_child(_make_cell(RunTracker.format_time(int(entry.get(Leaderboard.KEY_TIME, 0))), 120))
	return row


func _make_cell(text: String, min_width: float) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(min_width, 0)
	return label

# ============================== Buttons Callbacks ==============================

func _on_close_button_pressed() -> void:
	hide()
