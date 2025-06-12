class_name Hero3D
extends StaticBody3D

@export_group("Configuration")
@export var hero: Hero

@export_group("Local Nodes")
@export var collision_shape: CollisionShape3D
@export var _hero_animator: HeroAnimator

@export_group("External Nodes")
var _character_owner: Character
@export var character_owner: Character:
	get: return _character_owner
	set(value):
		print(hero.name, " changing owner to: ", value.name)
		if value == _character_owner: return
		_character_owner = value
		_hero_animator.character_owner = value
