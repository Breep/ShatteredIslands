extends Node

enum Level {
	TRACE,
	DEBUG,
	INFO,
	WARN,
	ERROR
}

enum GameType {
	SOLO,
	SERVER,
	CLIENT
}

enum Category {
	DEFAULT,
	NET,
	GLOBAL_MANAGER,
	ROUND_MANAGER,
	CARD_SHOP,
	AI,
	GAME,
	HERO_SELECTOR
}

const CATEGORY_PREFIX_TEMPLATES : Dictionary [Category, String] = {
	Category.DEFAULT:        "()          ",
	Category.NET:            "(NET)       ",
	Category.GLOBAL_MANAGER: "(GM)        ",
	Category.ROUND_MANAGER:  "(RM)        ",
	Category.CARD_SHOP:      "(CARD_SHOP) ",
	Category.AI:             "(AI)        ",
	Category.GAME:           "(GAME)      ",
	Category.HERO_SELECTOR:  "(HERO_SLCT) ",
}

const PREFIX_TEMPLATES : Dictionary [GameType, String] = {
	GameType.SOLO:   "[SOLO]   ",
	GameType.SERVER: "[SERVER] ",
	GameType.CLIENT: "[CLIENT] "
}

const RICH_PREFIX_TEMPLATES : Dictionary [GameType, String] = {
	GameType.SOLO:   "[color=brown][SOLO][/color]   ",
	GameType.SERVER: "[color=blue][SERVER][/color] ",
	GameType.CLIENT: "[color=green][CLIENT][/color] "
}

const LEVEL_PREFIX_TEMPLATES : Dictionary [Level, String] = {
	Level.TRACE: "<TRACE> ",
	Level.DEBUG: "<DEBUG> ",
	Level.INFO:  "<INFO>  ",
	Level.WARN:  "<WARN>  ",
	Level.ERROR: "<ERROR> "
}

#region ============================== Configuration ==============================
var current_level: Level = Level.TRACE
var current_categories: Array[Category] = [
	
]
#endregion

#region ============================== Private variables ==============================
var _is_server: bool = false
#endregion

#region ============================== Public function ==============================
func trace(msg: String, cat: Category = Category.DEFAULT) -> void:
	_log(cat, Level.TRACE, msg)


func debug(msg: String, cat: Category = Category.DEFAULT):
	_log(cat, Level.DEBUG, msg)


func info(msg: String, cat: Category = Category.DEFAULT):
	_log(cat, Level.INFO, msg)


func warn(msg: String, cat: Category = Category.DEFAULT):
	_log(cat, Level.WARN, msg)


func error(msg: String, cat: Category = Category.DEFAULT):
	_log(cat, Level.ERROR, msg)
#endregion



#region ============================== Node base function ==============================
func _ready() -> void:
	if "--server" in OS.get_cmdline_args():
		_is_server = true
#endregion



#region ============================== Public function ==============================
func _get_prefix() -> String:
	if _is_server: return PREFIX_TEMPLATES[GameType.SERVER]
	
	if not multiplayer.is_server():
		return PREFIX_TEMPLATES[GameType.CLIENT]
	else:
		return PREFIX_TEMPLATES[GameType.SOLO]


func _get_rich_prefix() -> String:
	if _is_server: return RICH_PREFIX_TEMPLATES[GameType.SERVER]
	
	if not multiplayer.is_server():
		return RICH_PREFIX_TEMPLATES[GameType.CLIENT]
	else:
		return RICH_PREFIX_TEMPLATES[GameType.SOLO]


func _is_category_active(cat: Category) -> bool:
	if current_categories.is_empty(): return true
	if current_categories.has(cat): return true
	return false


func _log(cat: Category, level: Level, msg: String) -> void:
	if level < current_level: return
	if not _is_category_active(cat): return
	if level == Level.ERROR:
		printerr(_get_prefix() + LEVEL_PREFIX_TEMPLATES[level] + CATEGORY_PREFIX_TEMPLATES[cat] + msg)
	else:
		print_rich(_get_rich_prefix() + LEVEL_PREFIX_TEMPLATES[level] + CATEGORY_PREFIX_TEMPLATES[cat] + msg)
#endregion
