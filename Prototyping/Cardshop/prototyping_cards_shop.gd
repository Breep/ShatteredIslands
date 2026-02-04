extends Node

@export_group("Cards rules")
@export_subgroup("Cards number")
@export var common_number: int = 25
@export var rare_number: int = 10
@export var epic_number: int = 5
@export var legendary_number: int = 3

@export_group("Family")
@export var _active_families: Dictionary[Family.FamilyType, bool]

@onready var _family_popup: OptionButton = %FamilyPopup
@onready var _time_label: Label = %TimeLabel

@onready var _cards_drawn_number: SpinBox = %CardNumberSpinBox

@onready var _custom_chance_bool: bool = true
@onready var _custom_check_box: CheckBox = %CustomChanceCheckBox

@onready var _ui_cards_viewer: UICardsViewer = %UICardsViewer
@onready var _shop_deck := ShopDeck.new()
@onready var _game_rules := GameRules.new()
@onready var _families: Array[Family]

@onready var _cards_drawn: Label = %CardsDrawnLabel
@onready var _shopdeck_cards_remaining_label: Label = %ShopDeckCardsRemainingLabel

var _FAMILIES_REF: Dictionary[Family.FamilyType, Family] = {
	Family.FamilyType.ATTACK: load("res://Card/Descriptions/Families/attack_family.tres") as Family,
	Family.FamilyType.DEFENSE: load("res://Card/Descriptions/Families/defense_family.tres") as Family,
	Family.FamilyType.FIRE: load("res://Card/Descriptions/Families/fire_family.tres") as Family,
	Family.FamilyType.POISON: load("res://Card/Descriptions/Families/poison_family.tres") as Family,
	Family.FamilyType.STORM: load("res://Card/Descriptions/Families/storm_family.tres") as Family,
	Family.FamilyType.SERENITY: load("res://Card/Descriptions/Families/serenity_family.tres") as Family,
	Family.FamilyType.LIFE: load("res://Card/Descriptions/Families/life_family.tres") as Family,
	Family.FamilyType.MANA: load("res://Card/Descriptions/Families/mana_family.tres") as Family,
	Family.FamilyType.CHICKEN: load("res://Card/Descriptions/Families/chickenlord_family.tres") as Family,
	Family.FamilyType.LIGHTNING: load("res://Card/Descriptions/Families/lightning_family.tres") as Family,
	Family.FamilyType.NECROSIS: load("res://Card/Descriptions/Families/necro_family.tres") as Family,
	Family.FamilyType.SHADOW: load("res://Card/Descriptions/Families/shadow_family.tres") as Family,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Init family popup
	_populate_family_popup()
	
	# Check game rules in inspector
	_check_game_rules()
	
	
	_shop_deck.construct_shop_deck(_families, _game_rules)
	
	# Init custom chance use
	_custom_chance_bool = _custom_check_box.button_pressed
	
	

func _populate_family_popup() -> void:
	for family_type: Family.FamilyType in _active_families.keys():
		if _active_families[family_type]:
			_family_popup.add_item(Family.FamilyType.keys()[family_type])
			_families.append(_FAMILIES_REF[family_type])

func _check_game_rules() -> void:
	_game_rules.common_number = common_number
	_game_rules.rare_number = rare_number
	_game_rules.epic_number = epic_number
	_game_rules.legendary_number = legendary_number

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_draw_cards_button_pressed() -> void:
	var start_time := Time.get_ticks_usec()
	
	#function draw
	var cards: Array[Card] = _shop_deck.draw_n_cards(int(_cards_drawn_number.value))
	#for card: Card in cards:
		#_shop_deck.remove_from_available_cards(card)
	
	
	# Time measurement of the draw function
	var end_time := Time.get_ticks_usec()
	var duration_usec := end_time - start_time
	var duration_msec := duration_usec / 1000.0
	if duration_usec > 1000:
		_time_label.text = str(duration_msec) + "msec"
	else:
		_time_label.text = str(duration_usec) + "usec"
	
	_ui_cards_viewer.update_content(cards)
	_cards_drawn.text = str(cards.size())
	_shopdeck_cards_remaining_label.text =  str(_shop_deck.size())



func _on_custom_chance_check_box_toggled(toggled_on: bool) -> void:
	_custom_chance_bool = toggled_on
