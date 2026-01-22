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
	PLAYER_MANAGER,
	GLOBAL_FIGHTING_MANAGER,
	FAMILY_MANAGER,
	HERO_SPAWNER,
	CARD_SHOP,
	SHOP_DECK,
	CARD_LAYOUT,
	ORACLE_SHOP,
	AI,
	GAME,
	HERO_SELECTOR,
	DECK,
	FIGHTING_ISLAND,
	ACTION_MODIFIER,
	STAT_MODIFIER,
	ENTITY_MODULE,
	ENTITY,
	HERO,
	BATTLE_SYNC,
	BATTLE_READER,
	BATTLE_WRITER,
	ENTITY_MANAGER,
	FIGHTING_AREA,
	BDS_REGISTERY,
	TABLE,
}

const CATEGORY_PREFIX_TEMPLATES: Dictionary[Category, String] = {
	Category.DEFAULT: "(          ) ",
	Category.NET: "(NET       ) ",
	Category.GLOBAL_MANAGER: "(GAME_MAN  ) ",
	Category.ROUND_MANAGER: "(ROUND_MAN ) ",
	Category.CARD_SHOP: "(CARD_SHOP ) ",
	Category.SHOP_DECK: "(SHOP_DECK ) ",
	Category.CARD_LAYOUT: "(CARD_LAY  ) ",
	Category.AI: "(AI        ) ",
	Category.GAME: "(GAME      ) ",
	Category.HERO_SELECTOR: "(HERO_SLCT ) ",
	Category.PLAYER_MANAGER: "(PLAYER_MAN) ",
	Category.DECK: "(DECK      ) ",
	Category.FIGHTING_ISLAND: "(FIGHT_ISLD) ",
	Category.ORACLE_SHOP: "(XP_SHOP   ) ",
	Category.ACTION_MODIFIER: "(ACTION_MOD) ",
	Category.STAT_MODIFIER: "(STAT_MOD  ) ",
	Category.GLOBAL_FIGHTING_MANAGER: "(GFM       ) ",
	Category.ENTITY_MODULE: "(ENT_MODULE) ",
	Category.ENTITY: "(ENTITY    ) ",
	Category.HERO: "(HERO      ) ",
	Category.BATTLE_SYNC: "(BATTLESYNC) ",
	Category.BATTLE_READER: "(BATTLEREAD) ",
	Category.BATTLE_WRITER: "(BATTLEWRIT) ",
	Category.ENTITY_MANAGER: "(ENTITY_MAN) ",
	Category.HERO_SPAWNER: "(HERO_SPAWN) ",
	Category.FIGHTING_AREA: "(FIGHT_AREA) ",
	Category.FAMILY_MANAGER: "(FAMILY_MAN) ",
	Category.BDS_REGISTERY: "(BDS_REG   ) ",
	Category.TABLE: "(TABLE     ) ",
}

const PREFIX_TEMPLATES: Dictionary[GameType, String] = {
	GameType.SOLO: "[SOLO] ",
	GameType.SERVER: "[SERVER] ",
	GameType.CLIENT: "[CLIENT] "
}

const RICH_PREFIX_TEMPLATES: Dictionary[GameType, String] = {
	GameType.SOLO: "[color=purple][SOLO][/color] ",
	GameType.SERVER: "[color=blue][SERVER][/color] ",
	GameType.CLIENT: "[color=green][CLIENT][/color] "
}

const LEVEL_PREFIX_TEMPLATES: Dictionary[Level, String] = {
	Level.TRACE: "<TRACE> ",
	Level.DEBUG: "<DEBUG> ",
	Level.INFO: "<INFO > ",
	Level.WARN: "<WARN > ",
	Level.ERROR: "<ERROR> "
}

#region ============================== Configuration ==============================
var current_categories_level: Dictionary[Category, Level] = {
	Category.DEFAULT: Level.WARN,
	Category.NET: Level.WARN,
	Category.GLOBAL_MANAGER: Level.WARN,
	Category.ROUND_MANAGER: Level.WARN,
	Category.CARD_SHOP: Level.WARN,
	Category.SHOP_DECK: Level.WARN,
	Category.CARD_LAYOUT: Level.WARN,
	Category.AI: Level.WARN,
	Category.GAME: Level.WARN,
	Category.HERO_SELECTOR: Level.WARN,
	Category.PLAYER_MANAGER: Level.WARN,
	Category.DECK: Level.WARN,
	Category.FIGHTING_ISLAND: Level.WARN,
	Category.ORACLE_SHOP: Level.WARN,
	Category.ACTION_MODIFIER: Level.WARN,
	Category.STAT_MODIFIER: Level.WARN,
	Category.GLOBAL_FIGHTING_MANAGER: Level.WARN,
	Category.ENTITY_MODULE: Level.WARN,
	Category.ENTITY: Level.WARN,
	Category.HERO: Level.DEBUG,
	Category.BATTLE_SYNC: Level.WARN,
	Category.BATTLE_READER: Level.WARN,
	Category.BATTLE_WRITER: Level.WARN,
	Category.ENTITY_MANAGER: Level.WARN,
	Category.HERO_SPAWNER: Level.WARN,
	Category.FAMILY_MANAGER: Level.DEBUG,
	Category.FIGHTING_AREA: Level.WARN,
	Category.BDS_REGISTERY: Level.WARN,
	Category.TABLE: Level.WARN,
}
#endregion


#region ============================== Private variables ==============================
var _is_server: bool = false
var _get_stamp: bool = true
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


func _is_category_active(cat: Category, log_level: Level) -> bool:
	var cat_level: Level = current_categories_level.get(cat, Level.WARN)
	return log_level >= cat_level


func _log(cat: Category, level: Level, msg: String) -> void:
	var time_stamp: String = ""
	
	if _get_stamp:
		time_stamp = " " + str(Time.get_ticks_msec()) + " "
	
	if not _is_category_active(cat, level): return
	
	match level:
		Level.TRACE:
			print_rich(_get_rich_prefix() + time_stamp + "[color=gray]" + LEVEL_PREFIX_TEMPLATES[level] + CATEGORY_PREFIX_TEMPLATES[cat] + msg + "[/color]")
		Level.DEBUG:
			print_rich(_get_rich_prefix() + time_stamp + "[color=white]" + LEVEL_PREFIX_TEMPLATES[level] + CATEGORY_PREFIX_TEMPLATES[cat] + msg + "[/color]")
		Level.INFO:
			print_rich(_get_rich_prefix() + time_stamp + "[color=white]" + LEVEL_PREFIX_TEMPLATES[level] + CATEGORY_PREFIX_TEMPLATES[cat] + msg + "[/color]")
		Level.WARN:
			print_rich(_get_rich_prefix() + time_stamp + "[color=yellow]" + LEVEL_PREFIX_TEMPLATES[level] + CATEGORY_PREFIX_TEMPLATES[cat] + msg + "[/color]")
		Level.ERROR:
			print_rich(_get_rich_prefix() + time_stamp + "[color=red]" + LEVEL_PREFIX_TEMPLATES[level] + CATEGORY_PREFIX_TEMPLATES[cat] + msg + "[/color]")
#endregion
