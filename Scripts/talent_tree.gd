extends Control

var lvl : int = 5
@onready var button_talentlvl1_1 = %TalentLvl1_1
@onready var button_talentlvl1_2 = %TalentLvl1_2
@onready var button_talentlvl3_1 = %TalentLvl3_1
@onready var button_talentlvl3_2 = %TalentLvl3_2
@onready var button_talentlvl5_1 = %TalentLvl5_1
@onready var button_talentlvl5_2 = %TalentLvl5_2

func update_button_visual(button: TextureButton, is_disabled: bool):
	button.disabled = is_disabled
	if is_disabled:
		button.modulate = Color(0.3, 0.3, 0.3, 1)  
	else:
		button.modulate = Color(1, 1, 1, 1)

func _ready():
	update_button_visual(button_talentlvl1_1, false)
	update_button_visual(button_talentlvl1_2, false)
	update_button_visual(button_talentlvl3_1, true)
	update_button_visual(button_talentlvl3_2, true)
	update_button_visual(button_talentlvl5_1, true)
	update_button_visual(button_talentlvl5_2, true)

func _on_talent_lvl_1_1_pressed() -> void:
	if not button_talentlvl1_1.disabled:
		update_button_visual(button_talentlvl1_1, true)
		update_button_visual(button_talentlvl1_2, true)
		update_button_visual(button_talentlvl3_1, false)
		update_button_visual(button_talentlvl3_2, false)
		button_talentlvl1_1.modulate = Color(1, 1, 1, 1)
		print("Talent 1 choose")

func _on_talent_lvl_1_2_pressed() -> void:
	if not button_talentlvl1_2.disabled:
		update_button_visual(button_talentlvl1_1, true)
		update_button_visual(button_talentlvl1_2, true)
		update_button_visual(button_talentlvl3_1, false)
		update_button_visual(button_talentlvl3_2, false)
		button_talentlvl1_2.modulate = Color(1, 1, 1, 1)
		print("Talent 2 choose")

func _on_talent_lvl_3_1_pressed() -> void:
	if not button_talentlvl3_1.disabled and lvl >= 3:
		update_button_visual(button_talentlvl3_1, true)
		update_button_visual(button_talentlvl3_2, true)
		update_button_visual(button_talentlvl5_1, false)
		update_button_visual(button_talentlvl5_2, false)
		button_talentlvl3_1.modulate = Color(1, 1, 1, 1)
		print("Talent 3 choose")

func _on_talent_lvl_3_2_pressed() -> void:
	if not button_talentlvl3_2.disabled and lvl >= 3 :
		update_button_visual(button_talentlvl3_1, true)
		update_button_visual(button_talentlvl3_2, true)
		update_button_visual(button_talentlvl5_1, false)
		update_button_visual(button_talentlvl5_2, false)
		button_talentlvl3_2.modulate = Color(1, 1, 1, 1)
		print("Talent 4 choose")

func _on_talent_lvl_5_1_pressed() -> void:
	if not button_talentlvl5_1.disabled and lvl >= 5 :
		update_button_visual(button_talentlvl5_1, true)
		update_button_visual(button_talentlvl5_2, true)
		button_talentlvl5_1.modulate = Color(1, 1, 1, 1)
		print("Talent 5 choose")

func _on_talent_lvl_5_2_pressed() -> void:
	if not button_talentlvl5_2.disabled and lvl >= 5:
		update_button_visual(button_talentlvl5_1, true)
		update_button_visual(button_talentlvl5_2, true)
		button_talentlvl5_2.modulate = Color(1, 1, 1, 1)
		print("Talent 6 choose")
