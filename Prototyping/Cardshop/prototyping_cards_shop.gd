extends Node

@export_group("Cards rules")
@export_subgroup("Cards number")
@export var common_number: int = 25
@export var rare_number: int = 10
@export var epic_number: int = 5
@export var legendary_number: int = 3

@export_group("Family")
@export var _families: Dictionary[Family.FamilyType, bool]

@onready var _family_popup: OptionButton = %FamilyPopup
@onready var _time_label: Label = %TimeLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_populate_family_popup()

func _populate_family_popup() -> void:
	for family_type: Family.FamilyType in _families.keys():
		#print(Family.FamilyType.keys()[family_type],_families[family_type])
		if _families[family_type]:
			_family_popup.add_item(Family.FamilyType.keys()[family_type])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_draw_cards_button_pressed() -> void:
	var start_time := Time.get_ticks_usec()
	
	#function draw
	
	await get_tree().create_timer(1.5).timeout
	
	# Time measurement of the draw function
	var end_time := Time.get_ticks_usec()
	var duration_usec := end_time - start_time
	var duration_msec := duration_usec / 1000.0
	if duration_usec > 1000:
		_time_label.text = str(duration_msec) + "msec"
	else:
		_time_label.text = str(duration_usec) + "usec"
