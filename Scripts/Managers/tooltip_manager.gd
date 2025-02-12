extends  Node

var debugg_int = 0
var _tooltip_scene = preload("res://Scenes/UI/ui_tooltip.tscn")
var _tooltips_dictionnary = {
	"attack": {
		"name": "Attack Family",
		"icon": "res://Data/Assets/Card/ICONS/ATTACK color.png",
		"description": "5/10/15/25% chance to double attack",
		"color": Color(1, 0, 0)  # Rouge
	},
	"defense": {
		"name": "Defense Family",
		"icon":"res://Data/Assets/Card/ICONS/DEFENSE color.png" ,
		"description": "20/50/75/125% + armor gain , [url=fire]🔥[/url]",
		"color": Color(0.465, 0.232, 0.022)  # Marron
	},
	"fire": {
		"name": "Fire Family",
		"icon": "res://Data/Assets/Card/Card_IMG/fire/icon flame.png",
		"description": "25/50/45/125% + magic damage, [url=fire]🔥[/url]",
		"color": Color(1, 0.5, 0)  # Orange
	},
	"shadow": {
		"name": "Shadow Family",
		"icon": "res://Data/Assets/Card/Card_IMG/shadow/shadow icon.png",
		"description": "25/50/75/125% Move speed | 1/2/3/5 + energy max",
		"color": Color(0, 0, 0)  # Noir
	},
	"vulnerability": {
		"name": "Storm Family",
		"icon": "res://Data/Assets/Card/Card_IMG/shadow/shadow icon.png",
		"description": "25/50/75/125% Move speed | 1/2/3/5 + energy max",
		"color": Color(0, 0, 0)  # Noir
		}
}

var _all_scene_tooltips: Array[Tooltip] 
var _tooltip_focused: Tooltip


func create_tooltip(tooltip_name: String) -> Tooltip:
	if not tooltip_name in _tooltips_dictionnary:
		printerr(tooltip_name + "not in tooltip dictionnary")
		return
	
	var tooltip_ref: Dictionary = _tooltips_dictionnary[tooltip_name]
	var tooltip : Tooltip = _tooltip_scene.instantiate()
	get_tree().current_scene.add_child(tooltip)
	tooltip.init(tooltip_ref["name"],load(tooltip_ref["icon"]),tooltip_ref["description"])
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


func _on_tooltip_unfocused(tooltip: Tooltip)->void:
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
