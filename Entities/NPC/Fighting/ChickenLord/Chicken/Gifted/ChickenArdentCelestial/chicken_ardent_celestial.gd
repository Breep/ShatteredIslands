class_name ChickenArdentCelestial
extends ChickenGifted

var _bonus_ms_ratio: float
var _ignite_stacks: int
var _hp_threshold_ratio: float
var _rush_target: Entity

const EXPLOSION_VFX_SCENE = preload("res://SpellsAndProjectiles/Spells/Meteor/Visual/VFX_Explosion_B.tscn")

@onready var _zone_impact: Area3D = %ImpactArea3D

func init(ignite_stacks: int) -> Summon:
	_bonus_ms_ratio = 0.25
	_hp_threshold_ratio = 0.5
	_ignite_stacks = ignite_stacks
	return self


func _ready() -> void:
	stats.health_changed.connect(_on_health_changed)
	super._ready()


func _on_health_changed(current_health: float) -> void:
	if current_health < _hp_threshold_ratio * stats.health_max:
		_auto_attack_periodic_module.stop()
		_rush_target = target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
		if is_instance_valid(_rush_target):
			_movement_module.move_to_entity(_rush_target)


func process_tick() -> void:
	super.process_tick()
	if _rush_target != null and global_position.distance_squared_to(_rush_target.global_position) < 1:
		stats.health = 0


func _on_died() -> void:
	super._on_died()
	_explosion()


func _explosion() -> void:
	var ennemies: Array[Entity]
	for body in _zone_impact.get_overlapping_bodies():
		if body is Entity and (body as Entity).team != team:
			ennemies.append(body)
	
	var hit_marker : Node3D = EXPLOSION_VFX_SCENE.instantiate()
	get_tree().current_scene.add_child(hit_marker)
	hit_marker.global_position = global_position
	var anim_player: AnimationPlayer = hit_marker.get_node("AnimationPlayer")
	if anim_player:
		anim_player.play("Init")
	
	for ennemy in ennemies:
		inflict_condition_stacks(ennemy, _ignite_stacks, Stack.Type.IGNITE, "Chicken explosion")
