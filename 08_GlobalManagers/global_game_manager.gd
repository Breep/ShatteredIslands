extends Node

const MAIN_MENU_SCENE_PATH := "res://05_Game/MainMenu/main_menu.tscn"


# Quitte la partie en cours et revient au menu principal en repartant d'un état
# propre. Libère d'abord les îles (taverne / combat) que l'EncounterRunner ajoute
# directement sous get_tree().root : étant des sœurs de la current_scene, elles
# survivent à change_scene_to_file et fuiteraient (crash au relancement). Le reset
# des singletons est fait par MainMenu._ready (reset_all_managers).
func return_to_main_menu() -> void:
	_free_floating_islands()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


func _free_floating_islands() -> void:
	for child in get_tree().root.get_children():
		if child is FloatingIsland:
			child.queue_free()


# All game manager
func reset_all_managers() -> void:
	_clear_all_managers()
	_init_all_managers()


func _clear_all_managers() -> void:
	GlobalFightingManager.clear()
	PlayerManager.clear()
	GameManager.clear()


func _init_all_managers() -> void:
	GameManager.init()

func _init() -> void:
	Verbose.debug("GLOBAL_GAME_MANAGER INIT", Verbose.Category.DEFAULT)
