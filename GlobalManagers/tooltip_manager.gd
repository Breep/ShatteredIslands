extends  Node

@onready var THEME: TooltipTheme = preload("res://UI/Tool/Tooltip/TooltipDictionary/standard_theme.tres")

@onready var POISON_DAMAGE = "[color=" + THEME.POISON_COLOR.to_html() + "][url=poison_damage]poison damage[/url][/color]"
@onready var POISON_STACK = "[color=" + THEME.POISON_COLOR.to_html() + "][url=poison_stack]poison stack[/url][/color]"

var _tooltips_dictionnary : Dictionary = {}
var debugg_int = 0
var _tooltip_scene = preload("res://UI/Tool/Tooltip/ui_tooltip.tscn")

var _all_scene_tooltips: Array[Tooltip] 
var _tooltip_focused: Tooltip

func _ready():
	_tooltips_dictionnary = {
		"test": {
			"name": "TESTING TOOLTIP",
			"icon": THEME.DEFAULT_ICON,
			"description": "HELLO ! I'm an [b]awesome[/b] TOOLTIP !",
		},
		"test_very_long_tooltip": {
			"name": "TESTING VERY LONG TOOLTIP",
			"icon": THEME.DEFAULT_ICON,
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
		"test_recursive": {
			"name": "RECURSIVE TOOLTIP",
			"icon": THEME.DEFAULT_ICON,
			"description": "[url=test_recursive]RECURSIVE TOOLTIP[/url]",
		},
		
		"poison_family": {
			"name": "[color=" + THEME.POISON_COLOR.to_html() + "]POISON FAMILY[/color]",
			"icon": THEME.POISON_FAMILY_ICON,
			"description": "Apply " + POISON_STACK + " over time to random enemies",
		},
		"poison_stack": {
			"name": "[color=" + THEME.POISON_COLOR.to_html() + "]POISON STACK[/color]",
			"icon": THEME.POISON_STACK_ICON,
			"description": "Deals damage over time. 1 " + POISON_DAMAGE + " per stack per tick. Tick = 1sec",
		},
		"poison_damage": {
			"name": "[color=" + THEME.POISON_COLOR.to_html() + "]POISON DAMAGE[/color]",
			"icon": THEME.POISON_DAMAGE_ICON,
			"description": "Ignore armor. Can't crit",
		},
	}

func create_tooltip(tooltip_name: String) -> Tooltip:
	if not tooltip_name in _tooltips_dictionnary:
		printerr(tooltip_name + " is not in the tooltip dictionnary")
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
