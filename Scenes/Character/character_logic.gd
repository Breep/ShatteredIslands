class_name CharacterLogic
extends Node

@export var _source: Character

@export var modules: Dictionary[Module.ModuleType, Module]
@export var families_managers: Dictionary[Family.FamilyType, FamilyManager]

var target_module: TargetModule

func _enter_tree() -> void:
	if is_node_ready(): return # Only do it once
	for module in modules.values():
		module.source = _source
	
	for family_manager in families_managers.values():
		family_manager.source = _source
	
	target_module = modules[Module.ModuleType.TARGET]


func _ready() -> void:
	_source.fighting_state_changed.connect(_on_source_fighting_state_changed)


func connect_to_fighting_area(fighting_area: FightingArea) -> void:
	target_module.connect_to_entity_manager(fighting_area.entity_manager)
	var action_module: ActionModule = modules[Module.ModuleType.ACTION]
	action_module.connect_to_spawn_manager(fighting_area.spawn_manager)


func _on_source_fighting_state_changed(new_state: GlobalFightingManager.FightingState) -> void:
	print("_on_source_fighting_state_changed() ", new_state)
	match new_state:
		GlobalFightingManager.FightingState.STARTING:
			pass
		GlobalFightingManager.FightingState.FIGHT:
			for family_manager in families_managers.values():
				family_manager.start()
			modules[Module.ModuleType.AUTOATTACK].start()
		GlobalFightingManager.FightingState.FINISHED:
			for family_manager in families_managers.values():
				family_manager.stop()
			modules[Module.ModuleType.AUTOATTACK].stop()






 
