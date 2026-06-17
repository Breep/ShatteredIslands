extends Node

# ============================== Configuration ==============================

## Taille (px) des icônes inline insérées via le token [[ICON:CLE]].
const _ICON_SIZE: int = 20

@onready var TOOLTIP_SCENE = load("res://04_UI/Tool/Tooltip/ui_tooltip.tscn")
@onready var THEME: TooltipTheme = load("res://04_UI/Tool/Tooltip/Theme/standard_theme.tres")

@onready var TOOLTIP_DATABASE: Array[TooltipDesc] = [
	# --- A ---
	load("res://04_UI/Tool/Tooltip/Dictionary/ability_projectile.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/acolyte.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/ad.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/big_projectile.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/small_projectile.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/ap.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/armor.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/attack.tres"),
	
	# --- B ---
	load("res://04_UI/Tool/Tooltip/Dictionary/block.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/building.tres"),
	
	# --- C ---
	load("res://04_UI/Tool/Tooltip/Dictionary/chickenlord_family.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/cleanse.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/colossus_family.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/cooldown.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/crit_chance.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/crit_multiplier.tres"),
	
	# --- D ---
	load("res://04_UI/Tool/Tooltip/Dictionary/defence.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/dispell.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/dodge.tres"),
	
	# --- E ---
	load("res://04_UI/Tool/Tooltip/Dictionary/execute.tres"),

	# --- H ---
	load("res://04_UI/Tool/Tooltip/Dictionary/hp.tres"),

	# --- I ---
	load("res://04_UI/Tool/Tooltip/Dictionary/ignite_stack.tres"), # Attention: Ton fichier s'appelle encore "_stack" ici
	
	# --- L ---
	load("res://04_UI/Tool/Tooltip/Dictionary/light_family.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/lightning_family.tres"),
	
	# --- M ---
	load("res://04_UI/Tool/Tooltip/Dictionary/magical_damage.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/meteor.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/mr.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/mana.tres"),
	
	# --- N ---
	load("res://04_UI/Tool/Tooltip/Dictionary/necro_family.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/necrosis.tres"),
	
	# --- P ---
	load("res://04_UI/Tool/Tooltip/Dictionary/physical_damage.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/poison_damage.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/poison_resist.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/poison_stack.tres"),
	
	# --- R ---
	load("res://04_UI/Tool/Tooltip/Dictionary/rank.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/regen.tres"),
	
	# --- S ---
	load("res://04_UI/Tool/Tooltip/Dictionary/shield.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/strength.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/stun.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/summon.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/scale.tres"),
	
	# --- T / V / W ---
	load("res://04_UI/Tool/Tooltip/Dictionary/taunt.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/thorn.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/true_damage.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/vulnerability.tres"),
	load("res://04_UI/Tool/Tooltip/Dictionary/weakness.tres")
]

@onready var SNIPPET_MAP: Dictionary[String, String] = {
	# --- DEGATS ---
	"PHYSICAL_DAMAGE": _keyword("PHYSICAL_DAMAGE", "PHYSICAL DAMAGE", "PHYSICAL_COLOR"),
	"MAGICAL_DAMAGE":  _keyword("MAGICAL_DAMAGE", "MAGICAL DAMAGE", "MAGICAL_COLOR"),
	"POISON_DAMAGE":   _keyword("POISON_DAMAGE", "POISON DAMAGE", "POISON_COLOR"),
	"TRUE_DAMAGE":     _keyword("TRUE_DAMAGE", "TRUE DAMAGE", "TRUE_COLOR"),

	# --- ENGINEER ---
	"ARMOR":             _keyword("ARMOR", "ARMOR", "DEFENCE_COLOR"),
	"MR":                _keyword("MR", "MAGIC RESISTANCE", "MAGICAL_COLOR"),
	"DODGE":             _keyword("DODGE", "DODGE", "STAT_COLOR"),
	"DEFENCE":           _keyword("DEFENCE", "DEFENCE", "DEFENCE_COLOR"),
	"POISON_RESISTANCE": _keyword("POISON_RESISTANCE", "POISON RESISTANCE", "POISON_COLOR"),
	"SCALE":             _keyword("SCALE", "SCALE", "SCALE_COLOR"),
	"HP":                _keyword("HP", "HP", "LIFE_COLOR"),

	# --- STATS OFFENSIVES ---
	"WARRIOR":         _keyword("WARRIOR", "ATTACK", "ATTACK_COLOR"),
	"AD":              _keyword("AD", "AD", "ATTACK_COLOR"),
	"AP":              _keyword("AP", "AP", "MAGICAL_COLOR"),
	"CRIT_CHANCE":     _keyword("CRIT_CHANCE", "CRIT CHANCE", "STAT_COLOR"),
	"CRIT_MULTIPLIER": _keyword("CRIT_MULTIPLIER", "CRIT MULTIPLIER", "STAT_COLOR"),

	# --- STACKS ---
	"POISON_STACK": _keyword("POISON_STACK", "POISON STACK", "POISON_COLOR"),
	"IGNITE":       _keyword("IGNITE", "IGNITE", "FIRE_COLOR"),
	"NECROSIS":     _keyword("NECROSIS", "NECROSIS", "NECRO_COLOR"),
	"REGEN":        _keyword("REGEN", "REGEN", "REGEN_COLOR"),
	"SHIELD":       _keyword("SHIELD", "SHIELD", "SHIELD_COLOR"),
	"BLOCK":        _keyword("BLOCK", "BLOCK", "BLOCK_COLOR"),
	"THORN":        _keyword("THORN", "THORN", "THORN_COLOR"),

	# --- EFFETS / STATUS ---
	"STUN":          _keyword("STUN", "STUN", "STAT_COLOR"),
	"WEAKNESS":      _keyword("WEAKNESS", "WEAKNESS", "DEBUFF_COLOR"),
	"STRENGTH":      _keyword("STRENGTH", "STRENGTH", "DEBUFF_COLOR"),
	"VULNERABILITY": _keyword("VULNERABILITY", "VULNERABILITY", "DEBUFF_COLOR"),
	"TAUNT":         _keyword("TAUNT", "TAUNT", "TAUNT_COLOR"),
	"CLEANSE":       _keyword("CLEANSE", "CLEANSE", "SERENITY_COLOR"),
	"DISPELL":       _keyword("DISPELL", "DISPELL", "DISPELL_COLOR"),
	"EXECUTE":       _keyword("EXECUTE", "EXECUTE", "FIRE_COLOR"),

	# --- FAMILLE / PASSIV ---
	"METEOR":       _keyword("METEOR", "METEOR", "METEOR_COLOR"),
	"RANK":         _keyword("RANK", "RANK", "LIGHTNING_COLOR"),
	"SUMMON":       _keyword("SUMMON", "SUMMON", "NECRO_COLOR"),
	"ACOLYTE":      _keyword("ACOLYTE", "ACOLYTE", "SERENITY_COLOR"),
	"BUILDING":     _keyword("BUILDING", "BUILDING", "DEFENCE_COLOR"),
	"LIGHTNING":    _keyword("LIGHTNING", "LIGHTNING", "LIGHTNING_COLOR"),
	"LIGHT":        _keyword("LIGHT", "SERENITY", "SERENITY_COLOR"),
	"CHICKEN_LORD": _keyword("CHICKEN_LORD", "CHICKEN-LORD", "CHICKEN_COLOR"),
	"COLOSSUS":     _keyword("COLOSSUS", "LIFE", "LIFE_COLOR"),
	"NECRO":        _keyword("NECRO", "NECRO", "NECRO_COLOR"),

	# --- AUTRE ---
	"COOLDOWN": _keyword("COOLDOWN", "COOLDOWN", "STAT_COLOR"),
	"MANA":     _keyword("MANA", "MANA", "MANA_COLOR"),

	# --- PROJECTILES ---
	"SMALL_PROJECTILE":   _keyword("SMALL_PROJECTILE", "SMALL PROJECTILE", "SMALL_PROJECTILE_COLOR"),
	"BIG_PROJECTILE":     _keyword("BIG_PROJECTILE", "BIG PROJECTILE", "BIG_PROJECTILE_COLOR"),
	"ABILITY_PROJECTILE": _keyword("ABILITY_PROJECTILE", "ABILITY PROJECTILE", "ABILITY_PROJECTILE_COLOR")
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


## icon_size : taille (px) des icônes inline [[ICON:CLE]]. 0 = défaut (_ICON_SIZE).
## Passe-lui la taille de police du label appelant pour que l'icône suive le texte.
func render_bbcode(text: String, icon_size: int = 0) -> String:
	return _render_bbcode(text, icon_size)


## Liste canonique des définitions de mots-clés (réutilisée par le glossaire joueur).
func get_descriptions() -> Array[TooltipDesc]:
	return TOOLTIP_DATABASE


## Texture d'icône du thème pour une clé donnée (ex: "SHIELD_ICON"). DEFAULT_ICON sinon.
func get_icon(icon_key: String) -> Texture2D:
	return THEME.icon(icon_key)

# ============================== Private functions ==============================

## Construit le bbcode d'un mot-clé cliquable : couleur de famille, gras, contour
## de la même couleur, et libellé en capitales. key = id [url] (résolu par les
## tooltips), label = texte affiché, color_name = clé couleur du thème.
func _keyword(key: String, label: String, color_name: String) -> String:
	var c := THEME.color_html(color_name)
	return "[color=%s][url=%s][b][outline_size=3][outline_color=%s]%s[/outline_color][/outline_size][/b][/url][/color]" % [c, key, c, label]


func _build_cache():
	_tooltips.clear()
	for d in TOOLTIP_DATABASE:
		var title := _render_bbcode(d.title)
		var desc := _render_bbcode(d.description)
		var icon := THEME.icon(d.icon_key)
		_tooltips[d.key] = {"name": title, "icon": icon, "description": desc}


func _render_bbcode(text: String, icon_size: int = 0) -> String:
	var out := text
	var px: int = icon_size if icon_size > 0 else _ICON_SIZE

	# 0) Replace icon tokens like [[ICON:COOLDOWN]] -> inline image (clé -> CLE_ICON du thème)
	var ri := RegEx.new()
	ri.compile("\\[\\[ICON:(\\w+)\\]\\]")
	for m in ri.search_all(out):
		var icon_name := m.get_string(1)
		var tex := THEME.icon(icon_name + "_ICON")
		if tex != null and not tex.resource_path.is_empty():
			out = out.replace("[[ICON:%s]]" % icon_name, "[img=%d]%s[/img]" % [px, tex.resource_path])

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
