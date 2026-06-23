class_name GammaTurret
extends Entity
#
#func _init() -> void:
	#super._init()
	#category = Category.BUILDING
#
#enum Modifier {
	#TURRET_AD,
	#TURRET_SHIELD,
	#TURRET_AS,
	#TURRET_HP,
	#MASTER,
	#RESPAWN_TIMER
#}
#
#@onready var animation_hovering_module: AnimHoveringModule = %AnimHoveringModule
#
#var _ad: float
#var _shield: int
#var _as: float
#var _hp: int
#var _master: Entity
#var _respawn_timer: float
#
#func init(shield: int, ad: float, attack_speed: float, hp: int, master: Entity, respawn_timer: float = -1.0) -> Entity:
	#_shield = shield
	#_ad = ad
	#_as = attack_speed
	#_hp = hp
	#_master = master
	#_respawn_timer = respawn_timer
	#return self
#
#
#func _ready() -> void:
	##_base_stats.health_max = _hp
	##_base_stats.attack_damage = _ad
	##_base_stats.attack_speed = _as
	#stat_modifiers_registry.recompute_all()
	#if not is_instance_valid(_master): _master = summoner
	## Posée comme bâtiment (sans invocateur) : pas d'orbite ni de bouclier de maître.
	#if is_instance_valid(_master):
		#movement.orbit_entity(_master, 2, 1, MovementComponent.OrbitFacing.NONE)
		#_master.died.connect(_on_master_died)
	## TODO Phase 2 controller refacto : migrer la strategy vers AIController._strategy
	## auto_attack_periodic._attack_strategy = TargetComponent.TargettingStrategy.CLOSEST_ENEMY_SUMMON
	#super._ready()
	#if is_instance_valid(_master):
		#alterations.apply_stack(Alteration.Type.SHIELD, _shield, _master, &"Gamma Turret")
#
#
#func _on_master_died() -> void:
	#_find_new_master()
#
#
#func _find_new_master() -> void:
	#var ally: Entity = target.get_target(TargetComponent.TargettingStrategy.RANDOM_ALLY)
	#if ally == null: return
	#if is_instance_valid(_master) and _master.died.is_connected(_on_master_died):
		#_master.died.disconnect(_on_master_died)
	#_master = ally
	#_master.died.connect(_on_master_died)
	#movement.orbit_entity(_master, 2, 1, MovementComponent.OrbitFacing.NONE)
#
#
#func _on_died() -> void:
	#animation_hovering_module.stop_hover()
	#super._on_died()
	#_play_fall_anim()
	#if _respawn_timer > 0:
		#battle_callback_registry.register_oneshot(_respawn_timer, resurrect.bind(100))
#
#
#func _on_resurrected() -> void:
	#super._on_resurrected()
	#alterations.apply_stack(Alteration.Type.SHIELD, _shield, summoner, &"Gamma Turret")
	#var tween := create_tween().set_parallel()
	#tween.tween_property(_visual_3d, "position:y", 2.8, 0.8) \
		#.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	#tween.tween_property(_visual_3d, "rotation:z", 0.0, 0.8) \
		#.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	#tween.chain().tween_callback(func() -> void:
		#animation_hovering_module.start_hover()
		#_find_new_master()
	#)
#
#
#func _play_fall_anim() -> void:
	#var tween := create_tween().set_parallel()
	#tween.tween_property(_visual_3d, "position:y", 0.0, 0.6) \
		#.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	#tween.tween_property(_visual_3d, "rotation:z", deg_to_rad(25.0), 0.6) \
		#.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
