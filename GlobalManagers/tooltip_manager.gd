extends  Node

# Effets généraux
@onready var vulnerability_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var armor_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var poison_icon = preload("res://Card/Descriptions/Families/Icons/poison.png")
@onready var heal_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")

# Types de dégâts
@onready var magical_damage_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var physical_damage_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var poison_damage_icon = preload("res://Card/Descriptions/Families/Icons/poison.png")

# Statistiques 
@onready var attack_damage_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var attack_speed_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var critical_chance_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var critical_multiplier_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var move_speed_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var energy_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var energy_regen_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var mana_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var mana_regen_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")

# Effets de statut spéciaux
@onready var pacify_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var bounce_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var teleport_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var focus_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var invincible_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")

# Familles d'améliorations
@onready var attack_family_icon = preload("res://Data/Assets/Card/ICONS/ATTACK color.png")
@onready var defense_family_icon = preload("res://Data/Assets/Card/ICONS/DEFENSE color.png")
@onready var fire_family_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var shadow_family_icon = preload("res://Data/Assets/Card/Card_IMG/shadow/shadow icon.png")
@onready var heal_family_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")
@onready var poison_family_icon = preload("res://Card/Descriptions/Families/Icons/poison.png")
@onready var storm_family_icon = preload("res://Data/Assets/Card/Card_IMG/storm/storm icon.png")
@onready var hp_family_icon = preload("res://Data/Assets/Card/Card_IMG/fire/icon flame.png")


const POISON_DAMAGE = "[color=#3a7e24][url=poison_damage]poison damage[/url][/color]"
const POISON_STACK = "[color=#3a7e24][url=poison_stack]poison stack[/url][/color]"

var _tooltips_dictionnary : Dictionary = {}
var debugg_int = 0
var _tooltip_scene = preload("res://UI/Tool/Tooltip/ui_tooltip.tscn")

var _all_scene_tooltips: Array[Tooltip] 
var _tooltip_focused: Tooltip

func _ready():
	_tooltips_dictionnary = {
		"test": {
			"name": "TESTING TOOLTIP",
			"icon": attack_family_icon,
			"description": "HELLO ! I'm an [b]awesome[/b] TOOLTIP !",
		},
		"test_very_long_tooltip": {
			"name": "TESTING VERY LONG TOOLTIP",
			"icon": attack_family_icon,
			"description": "HELLO ! I'm an [b]awesome[/b] TOOLTIP ! \n\
			I'm very very\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Very very ....\n\
			Oh! An other tooltip is hidden [url=test]HERE[/url]\n\
			Very very ....\n\
			long :) ....\n",
		},
		
		# Familles d'améliorations
		"attack_family": {
			"name": "Attack Family",
			"icon": attack_family_icon,
			"description": "5/10/15/25% chance to double attack",
		},
		"defense_family": {
			"name": "Defense Family",
			"icon": defense_family_icon,
			"description": "20/50/75/125% more armor gain",
		},
		"fire_family": {
			"name": "Fire Family",
			"icon": fire_family_icon,
			"description": "25/50/75/125% bonus magic damage",
		},
		"shadow_family": {
			"name": "Shadow Family",
			"icon": shadow_family_icon,
			"description": "25/50/75/125% Move speed and 1/2/3/5 more energy max",
		},
		"heal_family": {
			"name": "Heal Family",
			"icon": heal_family_icon,
			"description": "Increase all healing effects by 10/20/30/50%",
		},
		"poison_family": {
			"name": "[color=#3a7e24]Poison Family[/color]",
			"icon": poison_family_icon,
			"description": "Apply " + POISON_STACK + " over time to random enemies",
		},
		"storm_family": {
			"name": "Storm Family",
			"icon": storm_family_icon,
			"description": "Increase critical strike chance and multiplier",
		},
		"hp_family": {
			"name": "HP Family",
			"icon": hp_family_icon,
			"description": "Boosts max HP",
		},

		# Effets généraux
		"vulnerability": {
			"name": "Vulnerability",
			"icon": vulnerability_icon,
			"description": "A stackable debuff that increases critical damage on target by 1% per stack",
		},
		"armor": {
			"name": "Armor",
			"icon": armor_icon,
			"description": "A stackable buff that reduce incoming damage by 1 per stack. Stack are lost on use",
		},
		"poison_stack": {
			"name": "[color=#3a7e24]POISON STACK[/color]",
			"icon": poison_icon,
			"description": "Deals damage over time. 1 " + POISON_DAMAGE + " per stack per tick. Tick = 1sec",
		},
		"heal": {
			"name": "Heal",
			"icon": heal_icon,
			"description": "Heal can taget randomly self or other allies player",
		},

		# Types de dégâts
		"magical_damage": {
			"name": "Magical Damage",
			"icon": magical_damage_icon,
			"description": "Magical Damage",
		},
		"physical_damage": {
			"name": "Physical Damage",
			"icon": physical_damage_icon,
			"description": "Physical Damage",
		},
		"poison_damage": {
			"name": "[color=#3a7e24]POISON DAMAGE[/color]",
			"icon": poison_damage_icon,
			"description": "Ignore armor. Can't crit",
		},

		# Statistiques
		"attack_damage": {
			"name": "Attack Damage",
			"icon": attack_damage_icon,
			"description": "Increases the damage dealt by auto attacks",
		},
		"attack_speed": {
			"name": "Attack Speed",
			"icon": attack_speed_icon,
			"description": "Increases the speed of auto attacks",
		},
		"critical_chance": {
			"name": "Critical Chance",
			"icon": critical_chance_icon,
			"description": "Chance to land a critical hit",
		},
		"critical_multiplier": {
			"name": "Critical Multiplier",
			"icon": critical_multiplier_icon,
			"description": "Increases the damage of critical hits",
		},
		"move_speed": {
			"name": "Movement Speed",
			"icon": move_speed_icon,
			"description": "Boosts movement speed",
		},
		"energy": {
			"name": "Energy",
			"icon": energy_icon,
			"description": "Energy is use to moove. 1 Energy = 1m",
		},
		"energy_regen": {
			"name": "Energy Regen",
			"icon": energy_regen_icon,
			"description": "Regenerates energy over time",
		},
		"mana": {
			"name": "Mana",
			"icon": mana_icon,
			"description": "Resource for casting ultimate",
		},
		"mana_regen": {
			"name": "Mana Regen",
			"icon": mana_regen_icon,
			"description": "Regenerates mana over time",
		},

		# Effets de statut spéciaux
		"pacify": {
			"name": "Pacify",
			"icon": pacify_icon,
			"description": "Reduces the target's next dealt damage by 50%",
		},
		"bounce": {
			"name": "Bounce",
			"icon": bounce_icon,
			"description": "Attack bounces to the nearest target, dealing the same damage and applying effects",
		},
		"teleport": {
			"name": "Teleport",
			"icon": teleport_icon,
			"description": "Instantly move to a target location",
		},
		"focus": {
			"name": "Focus",
			"icon": focus_icon,
			"description": "Increases critical chance by 1.5% per sec up to 15%",
		},
		"invincible": {
			"name": "Invincibility",
			"icon": invincible_icon,
			"description": "Grants temporary immunity to all damage",
		},
	}

func create_tooltip(tooltip_name: String) -> Tooltip:
	if not tooltip_name in _tooltips_dictionnary:
		printerr(tooltip_name + "not in tooltip dictionnary")
		return
	
	var tooltip_ref: Dictionary = _tooltips_dictionnary[tooltip_name]
	var tooltip : Tooltip = _tooltip_scene.instantiate()
	get_tree().current_scene.add_child(tooltip)
	tooltip.init(tooltip_ref["name"],tooltip_ref["icon"],tooltip_ref["description"])
	tooltip.connect("focused", _on_tooltip_focused)
	tooltip.connect("unfocused", _on_tooltip_unfocused)
	tooltip.connect("queue_freed", _on_tooltip_queue_freed)
	_all_scene_tooltips.append(tooltip)
	debugg_int += 1
	tooltip.debugg_int = debugg_int
	return tooltip


func _close_all_tooltips():
	for tooltip in _all_scene_tooltips.duplicate():
		tooltip.delete()


func _on_tooltip_focused(tooltip: Tooltip)->void:
	print("focused")
	_tooltip_focused  = tooltip


func _on_tooltip_unfocused(_tooltip: Tooltip)->void:
	print("unfocused")
	_tooltip_focused  = null


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _tooltip_focused == null:
			_close_all_tooltips()
		else:
			_tooltip_focused.force_recursive_child_delete(false)

func _on_tooltip_queue_freed(tooltip: Tooltip):
	_all_scene_tooltips.erase(tooltip)
