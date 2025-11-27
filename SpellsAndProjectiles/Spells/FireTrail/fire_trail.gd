class_name FireTrail
extends Node3D
#
## =========================================================
## === This is the Fire trail from the card [Fire trail] ===
## =========================================================
#
#var _areas_dictionaries: Array[Dictionary] # { Area3D, Time }
#
#var _source: Character # Owner of this poison cloud
#var _action_module: ActionModule # Owner ActionModule ref
#var _characters_inside: Dictionary # {Character, int} Dictionary of number reference of characters
#var _damage_percent: float = 0 # Stacks applied every tick
#var _life_time: float # Life time of each point of the fire trail
#var _damage_wait_time: float # period between two ticks of damage (in seconds)
#
#var _previous_source_position: Vector3 # Last position of the source when a trail point was added
#const MINIMUM_DISTANCE_FOR_NEW_POINT: float = 0.5 # Minimum distance between two point of the fire trail path (in m)
#
#@onready var _damage_timer: Timer = %DamageTimer
#
#@onready var _fire_trail_area_scene: PackedScene = preload("res://SpellsAndProjectiles/Spells/FireTrail/fire_trail_area.tscn")
#
#func init(source: Character, damage_percent: float, period: float, life_time: float) -> void:
	#_source = source
	#_damage_wait_time = period
	#_damage_percent = damage_percent
	#_life_time = life_time
	#var action_modules = _source.find_children("", "ActionModule", true, false)
	#if action_modules.is_empty():
		#printerr("Meteor: An ActionModule is mandatory on the owner")
		#return
	#_action_module = action_modules[0]
#
#
#func _ready() -> void:
	#_previous_source_position = _source.global_position
	#_damage_timer.wait_time = _damage_wait_time
	#_damage_timer.start()
#
#
#func _construct_new_fire_trail_point() -> void:
	#var distance_with_previous_point = _source.global_position.distance_to(_previous_source_position)
	#if distance_with_previous_point < MINIMUM_DISTANCE_FOR_NEW_POINT:
		#return
	#
	#_previous_source_position = _source.global_position
	#var fire_trail_area: Area3D = _fire_trail_area_scene.instantiate()
	#fire_trail_area.connect("body_entered", _on_fire_trail_area_body_entered)
	#fire_trail_area.connect("body_exited", _on_fire_trail_area_body_exited)
	#get_tree().current_scene.add_child(fire_trail_area)
	#fire_trail_area.global_position = _source.global_position
	#var new_dictionary_entry: Dictionary
	#new_dictionary_entry["area"] = fire_trail_area
	#new_dictionary_entry["time"] = Time.get_ticks_msec()
	#_areas_dictionaries.append(new_dictionary_entry)
#
#
#func _remove_outdated_fire_trail_points() -> void:
	#for area_dictionary in _areas_dictionaries.duplicate():
		#var current_life_time = (Time.get_ticks_msec() - area_dictionary["time"]) / 1000.0
		#if current_life_time <= _life_time: # No need to check other points as they are newest
			#return
		#get_tree().current_scene.remove_child(area_dictionary["area"])
		#_areas_dictionaries.erase(area_dictionary)
#
## ===================================================================
#
## Enemy take damage when entering the fire trail, then each damage_tick_period
#func _on_fire_trail_area_body_entered(body: Node3D) -> void:
	#if body is Character and body.team != _source.team:
		#if _characters_inside.has(body):
			#_characters_inside[body] += 1
		#else:
			#_characters_inside[body] = 1
			#_action_module.direct_attack_percent(body, _damage_percent, Utils.DamageType.MAGICAL, Utils.PercentModifier.MAX_HP)
#
#
#func _on_fire_trail_area_body_exited(body: Node3D) -> void:
	#if body is Character and body.team != _source.team:
		#_characters_inside[body] -= 1
		#if _characters_inside[body] == 0:
			#_characters_inside.erase(body)
#
#
#func _on_construction_timer_timeout() -> void:
	#_remove_outdated_fire_trail_points()
	#_construct_new_fire_trail_point()
#
#
#func _on_damage_timer_timeout() -> void:
	#for character in _characters_inside:
		#if character.team != _source.team:
			#_action_module.direct_attack_percent(character, _damage_percent, Utils.DamageType.MAGICAL, Utils.PercentModifier.MAX_HP)
