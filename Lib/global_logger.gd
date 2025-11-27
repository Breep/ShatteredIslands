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

const PREFIX_TEMPLATES : Dictionary [GameType, String] = {
	GameType.SOLO: "",
	GameType.SERVER: "[SERVER] ",
	GameType.CLIENT: "[CLIENT] "
}

const LEVEL_PREFIX_TEMPLATES : Dictionary [Level, String] = {
	Level.TRACE: "<TRACE> ",
	Level.DEBUG: "<DEBUG> ",
	Level.INFO:  "<INFO>  ",
	Level.WARN:  "<WARN>  ",
	Level.ERROR: "<ERROR> "
}

var current_level: Level = Level.DEBUG
var prefix: String = ""
var level_prefix: String = ""

var is_server: bool = false

func _ready() -> void:
	if "--server" in OS.get_cmdline_args():
		is_server = true

func _get_prefix() -> String:
	if is_server: return PREFIX_TEMPLATES[GameType.SERVER]
	
	if not multiplayer.is_server():
		return PREFIX_TEMPLATES[GameType.CLIENT]
	else:
		return PREFIX_TEMPLATES[GameType.SOLO]

func _log(level: Level, msg: String) -> void:
	if level < current_level: return
	prefix = _get_prefix()
	if level == Level.ERROR:
		printerr(prefix + LEVEL_PREFIX_TEMPLATES[level] + msg)
	else:
		print(prefix + LEVEL_PREFIX_TEMPLATES[level] + msg)

func trace(msg: String): _log(Level.TRACE, msg)
func debug(msg: String): _log(Level.DEBUG, msg)
func info(msg: String):  _log(Level.INFO, msg)
func warn(msg: String):  _log(Level.WARN, msg)
func error(msg: String): _log(Level.ERROR, msg)
