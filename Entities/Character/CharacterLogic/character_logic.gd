class_name CharacterLogic
extends Node

@export var _source: Character

@export var modules: Dictionary[Module.ModuleType, Module]
@export var families_managers: Dictionary[Family.FamilyType, FamilyManager]

var target_module: TargetModule

var _is_stopped: bool = true

func _enter_tree() -> void:
	if is_node_ready(): return # Only do it once
	target_module = modules[Module.ModuleType.TARGET]


func _ready() -> void:
	_source.fighting_state_changed.connect(_on_source_fighting_state_changed)


func connect_to_fighting_area(fighting_area: FightingArea) -> void:
	var action_module: ActionModule = modules[Module.ModuleType.ACTION]
	action_module.connect_to_spawn_manager(fighting_area.spawn_manager)


func start() -> void: # Only the server simulate the fight, Clients gets the BattleLog and do a playback
	if not multiplayer.is_server(): return
	if not _is_stopped: return
	_is_stopped = false
	for family_manager in families_managers.values():
		family_manager.start()
	modules[Module.ModuleType.AUTOATTACK].start()


func stop() -> void:
	if not multiplayer.is_server(): return
	if _is_stopped: return
	_is_stopped = true
	for family_manager in families_managers.values():
		family_manager.stop()
	modules[Module.ModuleType.AUTOATTACK].stop()


func _on_source_fighting_state_changed(new_state: GlobalFightingManager.FightingState) -> void:
	match new_state:
		GlobalFightingManager.FightingState.POSITIONING:
			target_module.start()
		GlobalFightingManager.FightingState.FIGHTING:
			start()
		GlobalFightingManager.FightingState.CELEBRATING:
			target_module.stop()
			stop()






 
