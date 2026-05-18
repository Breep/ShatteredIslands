class_name UIResult
extends Control

# ============================== Signals ==============================

signal leave_requested

# ============================== Constants ==============================

const RESULT_LABELS: Dictionary[int, String] = {
	1: "Congratulations you are the best !\nYou win.\nCan you do it again ?",
	2: "Congratulations you are the bes... Wait, oh no sorry, someone is better than you.\nYou loose.\nYou'll do better next time, probably ?",
	3: "I'm sorry they are better than you.\nYou loose.\nYou'll do better next time, probably ?",
	4: "I'm sorry they are better than you.\nYou loose.\nYou'll do better next time, probably ?",
	5: "I'm sorry they are better than you.\nYou loose.\nYou'll do better next time, probably ?",
	6: "I'm sorry they are better than you.\nYou loose.\nYou'll do better next time, probably ?",
	7: "At least there is someone even zorst than you !\nYou loose.\nYou'll do better next time, probably ?",
	8: "Turbo top 8, Waoh !\nYou loose.\nYou can only do better now.",
}

# ============================== Local nodes ==============================

@onready var _confirm_panel: Panel = %ConfirmPanel
@onready var _result_label: Label = %ResultLabel
@onready var _player_place_label1: Label = %PlayerPlaceLabel1
@onready var _player_place_label2: Label = %PlayerPlaceLabel2

# ============================== Node base functions ==============================

func _ready() -> void:
	hide()

# ============================== Public functions ==============================

func show_result(player_place: int) -> void:
	show()
	_update_result_label(player_place)


func _update_result_label(player_place: int) -> void:
	if player_place < 1 or player_place > 8:
		printerr("UIResult: player place ouot of bound: ", player_place)
		return
	_result_label.text = RESULT_LABELS[player_place]
	_player_place_label1.text = str(player_place)
	_player_place_label2.text = str(player_place)

# ============================== Buttons Callbacks ==============================

func _on_stay_button_pressed() -> void:
	hide()


func _on_leave_button_pressed() -> void:
	_confirm_panel.show()


func _on_close_button_pressed() -> void:
	hide()


func _on_yes_button_pressed() -> void:
	leave_requested.emit()


func _on_no_button_pressed() -> void:
	_confirm_panel.hide()
