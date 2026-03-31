extends Node

# ============================== Configuration ==============================

@onready var TOOLTIP_SCENE = load("res://UI/Tool/Tooltip/ui_tooltip.tscn")
@onready var THEME: TooltipTheme = load("res://UI/Tool/Tooltip/Theme/standard_theme.tres")

@onready var TOOLTIP_DATABASE: Array[TooltipDesc] = [
	# --- A ---
	load("res://UI/Tool/Tooltip/Dictionary/armor.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/attack.tres"),
	
	# --- B ---
	load("res://UI/Tool/Tooltip/Dictionary/block.tres"),
	
	# --- C ---
	load("res://UI/Tool/Tooltip/Dictionary/chickenlord_family.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/cleanse.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/colossus_family.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/cooldown.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/crit_chance.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/crit_multiplier.tres"),
	
	# --- D ---
	load("res://UI/Tool/Tooltip/Dictionary/defence.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/dispell.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/dodge.tres"),
	
	# --- E ---
	load("res://UI/Tool/Tooltip/Dictionary/execute.tres"),
	
	# --- I ---
	load("res://UI/Tool/Tooltip/Dictionary/ignite_stack.tres"), # Attention: Ton fichier s'appelle encore "_stack" ici
	
	# --- L ---
	load("res://UI/Tool/Tooltip/Dictionary/light_family.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/lightning_family.tres"),
	
	# --- M ---
	load("res://UI/Tool/Tooltip/Dictionary/magical_damage.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/meteor.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/mr.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/mana.tres"),
	
	# --- N ---
	load("res://UI/Tool/Tooltip/Dictionary/necro_family.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/necrosis.tres"),
	
	# --- P ---
	load("res://UI/Tool/Tooltip/Dictionary/physical_damage.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/poison_damage.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/poison_resist.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/poison_stack.tres"),
	
	# --- R ---
	load("res://UI/Tool/Tooltip/Dictionary/rank.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/regen.tres"),
	
	# --- S ---
	load("res://UI/Tool/Tooltip/Dictionary/shield.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/strength.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/stun.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/summon.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/scale.tres"),
	
	# --- T / V / W ---
	load("res://UI/Tool/Tooltip/Dictionary/true_damage.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/vulnerability.tres"),
	load("res://UI/Tool/Tooltip/Dictionary/weakness.tres")
]

@onready var SNIPPET_MAP: Dictionary[String, String] = {
	# --- DEGATS ---
	"PHYSICAL_DAMAGE": "[color=%s][url=PHYSICAL_DAMAGE]physical damage[/url][/color]" % THEME.color_html("PHYSICAL_COLOR"),
	"MAGICAL_DAMAGE":  "[color=%s][url=MAGICAL_DAMAGE]magical damage[/url][/color]"   % THEME.color_html("MAGICAL_COLOR"),
	"POISON_DAMAGE":   "[color=%s][url=POISON_DAMAGE]poison damage[/url][/color]"     % THEME.color_html("POISON_COLOR"),
	"TRUE_DAMAGE":     "[color=%s][url=TRUE_DAMAGE]true damage[/url][/color]"         % THEME.color_html("TRUE_COLOR"),

	# --- ENGINEER ---
	"ARMOR":             "[color=%s][url=ARMOR]armor[/url][/color]"                         % THEME.color_html("DEFENCE_COLOR"),
	"MR":                "[color=%s][url=MR]magic resistance[/url][/color]"                 % THEME.color_html("MAGICAL_COLOR"),
	"DODGE":             "[color=%s][url=DODGE]dodge[/url][/color]"                         % THEME.color_html("STAT_COLOR"),
	"DEFENCE":           "[color=%s][url=DEFENCE]defence[/url][/color]"                     % THEME.color_html("DEFENCE_COLOR"),
	"POISON_RESISTANCE": "[color=%s][url=POISON_RESISTANCE]poison resistance[/url][/color]" % THEME.color_html("POISON_COLOR"),
	"SCALE":             "[color=%s][url=SCALE]scale[/url][/color]"                         % THEME.color_html("SCALE_COLOR"),

	# --- STATS OFFENSIVES ---
	"WARRIOR":         "[color=%s][url=WARRIOR]attack[/url][/color]"                  % THEME.color_html("ATTACK_COLOR"),
	"CRIT_CHANCE":     "[color=%s][url=CRIT_CHANCE]crit chance[/url][/color]"         % THEME.color_html("STAT_COLOR"),
	"CRIT_MULTIPLIER": "[color=%s][url=CRIT_MULTIPLIER]crit multiplier[/url][/color]" % THEME.color_html("STAT_COLOR"),

	# --- STACKS ---
	"POISON_STACK": "[color=%s][url=POISON_STACK]poison stack[/url][/color]" % THEME.color_html("POISON_COLOR"),
	"IGNITE":       "[color=%s][url=IGNITE]ignite[/url][/color]"             % THEME.color_html("FIRE_COLOR"),
	"NECROSIS":     "[color=%s][url=NECROSIS]necrosis[/url][/color]"         % THEME.color_html("NECRO_COLOR"),
	"REGEN":        "[color=%s][url=REGEN]regen[/url][/color]"               % THEME.color_html("REGEN_COLOR"),
	"SHIELD":       "[color=%s][url=SHIELD]shield[/url][/color]"             % THEME.color_html("SHIELD_COLOR"),
	"BLOCK":        "[color=%s][url=BLOCK]block[/url][/color]"               % THEME.color_html("BLOCK_COLOR"),

	# --- EFFETS / STATUS ---
	"STUN":          "[color=%s][url=STUN]stun[/url][/color]"                   % THEME.color_html("STAT_COLOR"),
	"WEAKNESS":      "[color=%s][url=WEAKNESS]weakness[/url][/color]"           % THEME.color_html("DEBUFF_COLOR"),
	"STRENGTH":      "[color=%s][url=STRENGTH]strength[/url][/color]"           % THEME.color_html("DEBUFF_COLOR"),
	"VULNERABILITY": "[color=%s][url=VULNERABILITY]vulnerability[/url][/color]" % THEME.color_html("DEBUFF_COLOR"),
	"CLEANSE":       "[color=%s][url=CLEANSE]cleanse[/url][/color]"             % THEME.color_html("SERENITY_COLOR"),
	"DISPELL":       "[color=%s][url=DISPELL]dispell[/url][/color]"             % THEME.color_html("DISPELL_COLOR"),
	"EXECUTE":       "[color=%s][url=EXECUTE]execute[/url][/color]"             % THEME.color_html("FIRE_COLOR"),

	# --- FAMILLE / PASSIV ---
	"METEOR":       "[color=%s][url=METEOR]meteor[/url][/color]"             % THEME.color_html("METEOR_COLOR"),
	"RANK":         "[color=%s][url=RANK]rank[/url][/color]"                 % THEME.color_html("LIGHTNING_COLOR"),
	"SUMMON":       "[color=%s][url=SUMMON]summon[/url][/color]"             % THEME.color_html("NECRO_COLOR"),
	"LIGHTNING":    "[color=%s][url=LIGHTNING]lightning[/url][/color]"       % THEME.color_html("LIGHTNING_COLOR"),
	"LIGHT":        "[color=%s][url=LIGHT]serenity[/url][/color]"            % THEME.color_html("SERENITY_COLOR"),
	"CHICKEN_LORD": "[color=%s][url=CHICKEN_LORD]chicken-lord[/url][/color]" % THEME.color_html("CHICKEN_COLOR"),
	"COLOSSUS":     "[color=%s][url=COLOSSUS]life[/url][/color]"             % THEME.color_html("LIFE_COLOR"),
	"NECRO":        "[color=%s][url=NECRO]necro[/url][/color]"               % THEME.color_html("NECRO_COLOR"),

	# --- AUTRE ---
	"COOLDOWN": "[color=%s][url=COOLDOWN]cooldown[/url][/color]"    % THEME.color_html("STAT_COLOR"),
	"MANA":     "[color=%s][url=MANA]mana[/url][/color]"            % THEME.color_html("MANA_COLOR")
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
