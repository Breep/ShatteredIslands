extends Control

@onready var _diamond_icon = preload("res://Data/Assets/Buying_area/UI/Family_ui/rond_diamond.png")
@onready var _platine_icon = preload("res://Data/Assets/Buying_area/UI/Family_ui/rond_vert.png")
@onready var _gold_icon = preload("res://Data/Assets/Buying_area/UI/Family_ui/rond_jaune.png")
@onready var _silver_icon = preload("res://Data/Assets/Buying_area/UI/Family_ui/rond_gris.png")
@onready var _bronze_icon = preload("res://Data/Assets/Buying_area/UI/Family_ui/rond_marron.png")

@onready var _lvl_family : TextureRect = %LvlFamille
@onready var _progress_family : TextureProgressBar = %ProgressFamille
@onready var _icon_family : TextureRect = %IconFamille

var _card_shop : CardShop

signal first_family_card_bought

var _ranks = {
	"Bronze": { "icon": _bronze_icon, "threshold": 10 },
	"Silver": { "icon": _silver_icon, "threshold": 20 },
	"Gold": { "icon": _gold_icon, "threshold": 30 },
	"Platine": { "icon": _platine_icon, "threshold": 40 },
	"Diamond": { "icon": _diamond_icon, "threshold": 50 }
}

var _family_card_count = {
	Family.FamilyType.Attack: 0, 
	Family.FamilyType.Defense: 0, 
	Family.FamilyType.Fire: 0, 
	Family.FamilyType.Storm: 0,
	Family.FamilyType.Serenity: 0, 
	Family.FamilyType.Life: 0, 
	Family.FamilyType.Poison: 0, 
	Family.FamilyType.Shadow: 0
}

func _ready() -> void:
	_card_shop = get_tree().get_root().find_child("CardShop", true, false)
	if _card_shop == null:
		printerr("Pas de card  shop")
		return
	_card_shop.connect("card_bought", _on_card_shop_card_bought)

func _on_card_shop_card_bought(card_bought:Card) -> void:
	if card_bought.families.is_empty():
		printerr("La carte n'a pas de famille")
		return 
		
	for family in card_bought.families:
		if family in _family_card_count:
			_family_card_count[family] += 1 
			_update_family_display(family)

func _update_family_display(family) -> void:
	
	var count = _family_card_count[family]  
	_progress_family.value = count  
	
	if count == 1:
		first_family_card_bought.emit(family)
		#var node = get_node_or_null(family + "Family")
		#node.show()
	
	for rank in _ranks.keys():
		if count >= _ranks[rank]["threshold"]: 
			_lvl_family.texture = _ranks[rank]["icon"]
			_progress_family.value = 0
