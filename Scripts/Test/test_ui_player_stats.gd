extends Control

@onready var attack_damage_label = %"AttackDamage"
@onready var attack_speed_label = %AttackSpeed
@onready var crit_chance_label = %CritChance
@onready var crit_multiplier_label = %CritMultiplier
@onready var health_label = %Health
@onready var mana_label = %Mana
@onready var resistance_label = %resistance
@onready var regen_mana_label = %RegenMana
@onready var name_label = %Name
@onready var description_label = %Description

@export var hero_test : Hero

var _shop : CardShop 
var charact_array : Array[Character]

func _ready() -> void:
	charact_array = _get_all_scene_characters()
		#update_player_stats(hero_test)
	_shop = get_tree().root.find_child("CardShop", true, false) 
	if _shop == null:
		printerr("shop nul")
		return
	_shop.card_bought.connect(_on_card_bought)
	
func _on_card_bought():
	pass
	
	
func update_player_stats(character: Hero):
	
	name_label.text = str(character.name)
	description_label.text = str(character.description)
	
	attack_damage_label.text = str(character.stats.auto_attack.damage) + " Attack Damage"
	attack_speed_label.text = str(character.stats.auto_attack.attack_speed) + " Attack/sec"
	crit_chance_label.text = str(character.stats.auto_attack.critical_chance) + "% Critical Chance"
	crit_multiplier_label.text = str(character.stats.auto_attack.critical_multiplier) + "% Critical Multiplier"
	
	health_label.text = str(character.stats.health_max) + " Health"
	
#	================TODO ADD NEW STATS =====================
	#resistance_label.text = str(character.stats.resistance) + " Resistance"
	#mana_label.text = str(character.stats.mana) + " Mana"
	#regen_mana_label.text = str(character.stats.regen_mana) + " Mana/sec"
	
	
func _get_all_scene_characters() -> Array[Character]:
	var ret: Array[Character]
	for node in get_tree().get_nodes_in_group("PLAYERS"):
		ret.append(node as Character)
	return ret
	
	
