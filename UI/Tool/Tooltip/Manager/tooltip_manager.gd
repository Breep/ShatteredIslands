extends Node

# ============================== Configuration ==============================

@onready var TOOLTIP_SCENE = load("res://UI/Tool/Tooltip/ui_tooltip.tscn")
@onready var THEME: TooltipTheme = load("res://UI/Tool/Tooltip/Theme/standard_theme.tres")
@onready var TOOLTIP_DATABASE: Array[TooltipDesc] = [
	load("res://UI/Tool/Tooltip/Dictionary/poison_stack.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/poison_damage.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/ignite_stack.tres")
]

@onready var SNIPPET_MAP: Dictionary[String, String] = {
	"POISON_DAMAGE": "[color=%s][url=POISON_DAMAGE]poison damage[/url][/color]" % THEME.color_html("POISON_COLOR"),
	"POISON_STACK":  "[color=%s][url=POISON_STACK]poison stack[/url][/color]"  % THEME.color_html("POISON_COLOR"),
	"IGNITE_STACK":  "[color=%s][url=IGNITE_STACK]ignite stack[/url][/color]"  % THEME.color_html("FIRE_COLOR")
}

var _all_scene_tooltips: Array[Tooltip] 
var _tooltip_focused: Tooltip
var _tooltips: Dictionary = {}

# ============================== Node base functions ==============================

func _ready():
	_build_cache()


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _tooltip_focused == null:
			_close_all_tooltips()
		else:
			_tooltip_focused.force_recursive_child_delete(false)

# ============================== Public functions ==============================

func create_tooltip(key: StringName) -> Tooltip:
	if key not in _tooltips:
		printerr(str(key) + " is not in the tooltip database")
		return null
	var data = _tooltips[key]
	var t: Tooltip = TOOLTIP_SCENE.instantiate()
	get_tree().current_scene.add_child(t)
	t.init(data.name, data.icon, data.description)
	t.connect("focused", _on_tooltip_focused)
	t.connect("unfocused", _on_tooltip_unfocused)
	t.connect("queue_freed", _on_tooltip_queue_freed)
	_all_scene_tooltips.append(t)
	return t


func render_bbcode(text: String) -> String:
	return _render_bbcode(text)

# ============================== Private functions ==============================

func _build_cache():
	_tooltips.clear()
	for d in TOOLTIP_DATABASE:
		var title := _render_bbcode(d.title)
		var desc := _render_bbcode(d.description)
		var icon := THEME.icon(d.icon_key)
		_tooltips[d.key] = {"name": title, "icon": icon, "description": desc}


func _render_bbcode(text: String) -> String:
	var out := text

	# 1) Replace snippet tokens like [[POISON_STACK]]
	var r := RegEx.new()
	r.compile("\\[\\[(\\w+)\\]\\]")
	var matches := r.search_all(out)
	for m in matches:
		var token := m.get_string(1)
		if token in SNIPPET_MAP:
			out = out.replace("[[%s]]" % token, SNIPPET_MAP[token])
	
	# 2) Replace color spans: {{COLOR:NAME}}...{{/COLOR}}
	var rc := RegEx.new()
	rc.compile("\\{\\{COLOR:(\\w+)\\}\\}(.*?)\\{\\{\\/COLOR\\}\\}")
	while true:
		var mm := rc.search(out)
		if mm == null: break
		var cname := mm.get_string(1)
		var span := mm.get_string(2)
		var hex := THEME.color_html(cname)
		out = out.substr(0, mm.get_start()) \
			+ "[color=%s]" % hex + span + "[/color]" \
			+ out.substr(mm.get_end())

	return out


func _close_all_tooltips():
	for tooltip in _all_scene_tooltips.duplicate():
		tooltip.delete()

# ============================== Callbacks ==============================

func _on_tooltip_focused(t: Tooltip) -> void:
	_tooltip_focused = t

func _on_tooltip_unfocused(_t: Tooltip) -> void:
	_tooltip_focused = null

func _on_tooltip_queue_freed(t: Tooltip) -> void:
	_all_scene_tooltips.erase(t)
