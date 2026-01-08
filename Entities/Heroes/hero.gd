class_name Hero
extends Entity

# == VIRTUAL CLASS ==

@export_group("Configuration")
@export var hero: HeroDesc

@export_group("Local Nodes")
@export var _hero_animator: HeroAnimator

func cast_ultimate() -> void:
	printerr("Hero3D: virtual cast_ultimate() called [", get_path(), "]")
