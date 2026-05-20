class_name Entity
extends CharacterBody3D

# == VIRTUAL CLASS ==

#region ============================== Signals ==============================
signal died(self_ref: Entity)
@warning_ignore("unused_signal")
signal action_received(source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool)
@warning_ignore("unused_signal")
signal action_done(target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool)
@warning_ignore("unused_signal")
signal action_dodged(source: Entity, action_type: Utils.ActionType, value: float, is_critical: bool)
@warning_ignore("unused_signal")
signal action_blocked(source: Entity, action_type: Utils.ActionType, value: float)
@warning_ignore("unused_signal")
signal critical_action_done(target: Entity, action_type: Utils.ActionType, value_before_crit: float, value_after_crit: float)
@warning_ignore("unused_signal")
signal action_overhealed(target: Entity, amount: float)
@warning_ignore("unused_signal")
signal damage_taken(damage: float, damage_type: Utils.ActionType, is_critical: bool, blocked_by_armor: bool)
@warning_ignore("unused_signal")
signal heal_taken(heal_amount: float, is_critical: bool)
@warning_ignore("unused_signal")
signal stack_taken(stack_type: Alteration.Type, stack_number: float, is_critical: bool)
@warning_ignore("unused_signal")
signal auto_attack_completed()
@warning_ignore("unused_signal")
signal spell_casted(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary)
signal spawn_completed()
signal resurrected()
#endregion

#region ============================== Enums ==============================
enum LifeState {
	ALIVE,
	DEAD
}

enum FightingState {
	SPAWNING,
	IDLE,
	FIGHTING,
	CELEBRATING,
	UNDEF
}

enum EntityType {
	HERO,
	SNAKE_BARREL,
	SNAKE,
	FIELD_GENERATOR,
	CHICKEN,
	PROTO_SHIELD,
	FORTIFICATION_DRONE,
	AEGIS_BLADE,
	DEFLECTION_SHIELD,
	GAMMA_TURRET,
	TREX,
	CHICKEN_EGG
}

# Role of an entity in the fight victory conditions.
# MAIN = Hero / Antagonist, SECONDARY = Acolyte, EXTRA = mobs / summons / anything else.
enum FightRole {
	MAIN,
	SECONDARY,
	EXTRA
}

enum SnakeBarrelModifier {
	SNAKE_NUMBER,
	SNAKE_POISON_STACKS,
	MAX_HEALTH
}

enum FieldGeneratorModifier {
	MAX_HEALTH,
	SHIELD_AMOUNT,
	SHIELD_INTERVAL,
	INITIAL_SHIELD,
	TARGET_COUNT
}
#endregion

#region ============================== Constants ==============================
const TICKS_PER_SECOND: int = 60
#endregion

#region ============================== Public variables ==============================
var uid: int = -1 # Multiplayer ID of the entity

var _is_targetable: bool = true
var is_targetable: bool:
	get:
		if alterations != null:
			return not alterations.has_state(Alteration.Type.UNTARGETABLE)
		return _is_targetable


# Auto loaded extensions
var stats: EntityStats
var base_stats: EntityStats:
	get: return _base_stats
var spawn_manager: SpawnManager:
	get: return _spawn_manager


# Modifiers
var auto_attack_modifier_registry: AutoAttackModifierRegistry
var action_modifiers_registry: ActionModifiersRegistry
var stat_modifiers_registry: EntityStatModifiersRegistry
var death_modifiers_registry: DeathModifiersRegistry
var periodic_timer_registry: PeriodicTimerRegistry
var battle_callback_registry: BattleCallbackRegistry


# Components
var damage: DamageComponent
var heal: HealComponent
var projectile: ProjectileComponent
var spell: SpellComponent
var summon: SummonComponent
var auto_attack: AutoAttackComponent
var alterations: AlterationsComponent
var target: TargetComponent
var movement: MovementComponent
var animation: AnimationComponent
var spawn_animation: SpawnAnimationComponent
var clickable: ClickableComponent
#endregion

#region ============================== Private variables ==============================
var _base_stats: EntityStats # Private, use base_stats property to access

var _auto_attack_periodic_module: AutoAttackPeriodicModule # Optional, can be null
var _label_popup_module: LabelPopupModule

# Spawn system
var _original_fighting_state: FightingState = FightingState.UNDEF
#endregion

#region ============================== Export ==============================
@export var team: int = -1 # Team number of the entity
@export var battle_id: int = -1 # The id of the battle the entity is in
@export var entity_name: String = "<entity name>"

# Tagué au spawn par FightingArea selon le type de spec. Consommé par FightingManager
# pour les conditions d'élimination (KILL_MAIN / KILL_SECONDARY / KILL_ALL).
var fight_role: FightRole = FightRole.EXTRA

@export_group("Optional configuration")
@export var invisible: bool = false
@export var custom_base_stats: EntityStats

@export_subgroup("Visual")
@export var _visual_3d: Node3D
@export var _health_bar_marker: Marker3D
@export var _health_bar: SimpleInfoPanel2D
@export var _attack_spawn_marker: Marker3D
@export var _projectile_type: Projectile.Type

@export_subgroup("Visual/Animation")
@export var custom_animation_component: AnimationComponent
@export var custom_spawn_animation_component: SpawnAnimationComponent # Overrides the default spawn animation if set

@export_subgroup("Interaction")
@export var custom_clickable_component: ClickableComponent # Overrides the default click/hover handler if set

@export_subgroup("Prototyping")
@export var _spawn_manager: SpawnManager
@export var _arena_zone_manager: ArenaZoneManager
@export var auto_attack_enabled: bool = true
#endregion

@onready var bds_registry := EntityBDSRegistry.new(self)
@onready var _state_machine := EntityStateMachine.new(self)

#region ============================== Misc State ==============================
signal life_state_changed(new_life_state: LifeState)
var _life_state: LifeState = LifeState.ALIVE
var life_state: LifeState:
	get: return _life_state
	set(value):
		if value != _life_state:
			_life_state = value
			life_state_changed.emit(_life_state)

signal fighting_state_changed(new_fighting_state: FightingState)
var _fighting_state: FightingState = FightingState.UNDEF
var _initial_fighting_state_from_context: FightingState = FightingState.UNDEF # Stored during apply_context
var fighting_state: FightingState:
	get: return _fighting_state
	set(value):
		if value != _fighting_state:
			_fighting_state = value
			fighting_state_changed.emit(_fighting_state)

signal is_moving_changed(state: bool)
var _is_moving: bool = false
var is_moving: bool:
	get: return _is_moving
	set(value):
		if value != _is_moving:
			_is_moving = value
			is_moving_changed.emit(_is_moving)
#endregion

#region ============================== Status States ==============================
func is_alive() -> bool:
	return life_state == LifeState.ALIVE

func is_dead() -> bool:
	return life_state == LifeState.DEAD
#endregion

# ============================== Node base functions ==============================

#region ============================== Init ==============================
func _init() -> void:
	# Stats
	stats = EntityStats.new()
	_base_stats = EntityStats.new()

	# Default Modifier Registries
	auto_attack_modifier_registry = AutoAttackModifierRegistry.new()
	action_modifiers_registry = ActionModifiersRegistry.new()
	death_modifiers_registry = DeathModifiersRegistry.new()
	Verbose.trace("Entity [" + entity_name + "_" + str(uid) + "] init", Verbose.Category.ENTITY)


func _enter_tree() -> void:
	Verbose.trace("Entity [" + entity_name + "_" + str(uid) + "] enter_tree", Verbose.Category.ENTITY)
	# Stats registry needs to be created after _init() because custom_base_stats is not available in _init()
	if custom_base_stats != null:
		_base_stats = custom_base_stats
		_base_stats.reset_from_self()
		Verbose.debug("Entity [" + entity_name + "] using custom_base_stats", Verbose.Category.ENTITY)
	stat_modifiers_registry = EntityStatModifiersRegistry.new(_base_stats, stats)

	_auto_load_components()
	_load_spawn_animation()
	_load_animation()
	_load_clickable()

	periodic_timer_registry = PeriodicTimerRegistry.new()
	periodic_timer_registry.name = "PeriodicTimerRegistry"
	add_child(periodic_timer_registry)

	battle_callback_registry = BattleCallbackRegistry.new()

	_is_targetable = false # Prevent targeting during spawn


func _ready() -> void:
	# Connect to status signals
	if alterations != null:
		alterations.stunned_changed.connect(_on_stunned_changed)

	Verbose.trace("Entity [" + entity_name + "_" + str(uid) + "] ready", Verbose.Category.ENTITY)

	fighting_state_changed.connect(_on_fighting_state_changed)
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)

	stats.health_changed.connect(_on_stats_health_changed)
	_on_stats_health_changed(stats.health)
	died.connect(_on_died)
	resurrected.connect(_on_resurrected)

	stats.scale_changed.connect(_on_stats_scale_changed)
	_on_stats_scale_changed(stats.scale)

	# TODO CHECK THIS ??
	if _initial_fighting_state_from_context != FightingState.UNDEF:
		_original_fighting_state = _initial_fighting_state_from_context
	else:
		_original_fighting_state = fighting_state if fighting_state != FightingState.UNDEF else FightingState.IDLE

	spawn_animation.spawn_finished.connect(_on_spawn_finished)

	# Connect module interdependencies
	_connect_module_dependencies()

	_start_spawn()



func _exit_tree() -> void:
	if stats != null and stats.health_changed.is_connected(_on_stats_health_changed):
		stats.health_changed.disconnect(_on_stats_health_changed)
#endregion


# ============================== Public functions ==============================
#region ============================== Utils ==============================
func look_at_target_y_only(target_position: Vector3):
	var direction = target_position - global_position
	direction.y = 0
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)


func get_auto_attack_spawn() -> Node3D:
	return self


func get_collision_center() -> Vector3:
	"""Returns the center of the entity's collision box for accurate projectile targeting."""
	# Search for a CollisionShape3D in the entity's children
	for child in get_children():
		if child is CollisionShape3D:
			var collision_shape: CollisionShape3D = child
			if collision_shape.shape:
				# Return the global position of the collision shape
				# This accounts for the shape's offset from the entity's pivot
				return collision_shape.global_position

	# Fallback to global position if no collision shape found
	return global_position


func process_tick() -> void:
	if movement != null:
		movement.process_tick()
	if _auto_attack_periodic_module != null:
		_auto_attack_periodic_module.process_tick()
	if alterations != null:
		alterations.process_tick()
	spawn_animation.process_tick()
	if periodic_timer_registry != null:
		periodic_timer_registry.process_tick()
#endregion

#region ============================== Context ==============================
func get_context() -> EntityContext:
	var ctx := EntityContext.new()
	ctx.team = team
	ctx.battle_id = battle_id
	ctx.spawn_manager = _spawn_manager
	ctx.arena_zone_manager = _arena_zone_manager
	ctx.life_state = LifeState.ALIVE # Summons always spawn alive
	ctx.fighting_state = fighting_state # Inherit parent's state
	ctx.entity_owner = self
	Verbose.debug("Entity [" + entity_name + "] creating context with fighting_state [" + str(FightingState.keys()[fighting_state]) + "]", Verbose.Category.ENTITY)
	return ctx


func apply_context(context: EntityContext) -> void:
	team = context.team
	battle_id = context.battle_id
	life_state = context.life_state
	_initial_fighting_state_from_context = context.fighting_state
	_spawn_manager = context.spawn_manager
	_arena_zone_manager = context.arena_zone_manager

	# Connect all sender modules to managers
	var senders: Array[EntityComponent] = [
		damage, heal, projectile, spell, summon, auto_attack
	]
	for module in senders:
		if module == null: continue
		if _spawn_manager != null: module.connect_to_spawn_manager(_spawn_manager)
		if _arena_zone_manager != null: module.connect_to_arena_zone_manager(_arena_zone_manager)

	Verbose.debug("Entity [" + entity_name + "] received fighting_state [" + str(FightingState.keys()[context.fighting_state]) + "] from context", Verbose.Category.ENTITY)


func connect_to_fighting_area(fighting_area_ref: FightingArea) -> void:
	Verbose.debug("Connecting to fighting area", Verbose.Category.ENTITY)
	if fighting_area_ref == null:
		Verbose.error("Trying to connect a null fighting area to an Entity", Verbose.Category.ENTITY)
		return
	
	_spawn_manager = fighting_area_ref.spawn_manager
	if projectile != null:
		projectile.connect_to_spawn_manager(fighting_area_ref.spawn_manager)
	if spell != null:
		spell.connect_to_spawn_manager(fighting_area_ref.spawn_manager)
	if summon != null:
		summon.connect_to_spawn_manager(fighting_area_ref.spawn_manager)
		summon.connect_to_arena_zone_manager(fighting_area_ref.arena_zone_manager)
	if target != null:
		target.connect_to_spawn_manager(fighting_area_ref.spawn_manager)
#endregion


#region ============================== Misc ==============================
func cast_ultimate() -> void:
	printerr("Entity: cast_ultimate() called but not implemented [", get_path(), "]")


# Hook appelé par FightingManager sur chaque entité vivante quand le combat se termine.
# Override par Hero pour gérer son state post-combat. No-op pour les autres entités.
func handle_end_of_fight(_is_winner: bool) -> void:
	pass


func resurrect(hp_percent: float) -> void:
	if life_state != LifeState.DEAD:
		Verbose.error("Entity [" + entity_name + "] try to resurrect while not dead.", Verbose.Category.ENTITY)
		return

	stats.health = stats.health_max * (hp_percent / 100)
	life_state = LifeState.ALIVE
	_state_machine.start_combat_modules()
	resurrected.emit()
#endregion

# ============================== Private functions ==============================

#region ============================== Spawn system ==============================
func _start_spawn() -> void:
	fighting_state = FightingState.SPAWNING
	Verbose.debug("Entity [" + entity_name + "] starting spawn", Verbose.Category.ENTITY)
	spawn_animation.start_spawn()


func _on_spawn_finished() -> void:
	Verbose.debug("Entity [" + entity_name + "] completing spawn", Verbose.Category.ENTITY)
	_is_targetable = true
	if _fighting_state != FightingState.FIGHTING:
		fighting_state = _original_fighting_state
	spawn_completed.emit()
#endregion

#region ============================== Auto loading ==============================
func _auto_load_components() -> void:
	damage =  Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.DAMAGE].instantiate().init(self)
	heal =  Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.HEAL].instantiate().init(self)
	projectile =  Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.PROJECTILE].instantiate().init(self)
	spell =  Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.SPELL].instantiate().init(self)
	summon =  Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.SUMMON].instantiate().init(self)
	auto_attack =  Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.AUTO_ATTACK].instantiate().init(self)
	alterations =  Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.ALTERATIONS].instantiate().init(self)
	target =  Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.TARGET].instantiate().init(self)
	movement =  Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.MOVEMENT].instantiate().init(self)
	_auto_attack_periodic_module = Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.AUTO_ATTACK_PERIODIC_MODULE].instantiate().init(self)
	_label_popup_module = Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.LABEL_POPUP_MODULE].instantiate().init(self)
	
	add_child(damage)
	add_child(heal)
	add_child(projectile)
	add_child(spell)
	add_child(summon)
	add_child(auto_attack)
	add_child(alterations)
	add_child(target)
	add_child(movement)
	add_child(_auto_attack_periodic_module)
	add_child(_label_popup_module)


func _load_spawn_animation() -> void:
	if custom_spawn_animation_component != null:
		spawn_animation = custom_spawn_animation_component
		return
	spawn_animation = Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.SPAWN_ANIMATION].instantiate().init(self)
	add_child(spawn_animation)


func _load_animation() -> void:
	if custom_animation_component != null:
		animation = custom_animation_component
		return
	animation = Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.ANIMATION].instantiate().init(self)
	add_child(animation)


func _load_clickable() -> void:
	if custom_clickable_component != null:
		clickable = custom_clickable_component
		return
	clickable = Shared.ENTITY_COMPONENT_SCENES[EntityComponent.Type.CLICKABLE].instantiate().init(self)
	add_child(clickable)


func _connect_module_dependencies() -> void:
	if target != null:
		target.connect_to_spawn_manager(_spawn_manager)
	
	if projectile != null:
		projectile.connect_to_spawn_manager(_spawn_manager)
	
	if spell != null:
		spell.connect_to_spawn_manager(_spawn_manager)
	
	if summon != null: 
		summon.connect_to_spawn_manager(_spawn_manager)
		summon.connect_to_arena_zone_manager(_arena_zone_manager)
	
	if auto_attack != null:
		auto_attack.connect_modules(movement, animation)
		auto_attack.set_auto_attack_spawn(_attack_spawn_marker)
		auto_attack.set_projectile_type(_projectile_type)
	
	if _auto_attack_periodic_module != null and auto_attack != null:
		_auto_attack_periodic_module.connect_modules(auto_attack)
	
	if animation != null:
		animation.connect_modules(auto_attack)
	
	if _label_popup_module != null:
		_label_popup_module.connect_marker(_health_bar_marker)
#endregion

#region ============================== Callbacks ==============================
func _on_fighting_state_changed(new_fighting_state: FightingState) -> void:
	Verbose.debug("Entity [" + entity_name + "] fighting state changed to [" + str(FightingState.keys()[new_fighting_state]) + "]", Verbose.Category.ENTITY)
	_state_machine.transition_to(new_fighting_state)


func _on_stats_health_changed(new_health: float) -> void:
	if new_health < 1:
		died.emit()


func _on_stats_scale_changed(new_scale: float) -> void:
	if is_instance_valid(_visual_3d):
		_visual_3d.scale = Vector3(new_scale, new_scale, new_scale)


func _on_died() -> void:
	Verbose.debug("Entity [" + entity_name + "] died", Verbose.Category.ENTITY)

	life_state = LifeState.DEAD
	_state_machine.stop_combat_modules()

	for action_modifier in death_modifiers_registry.consume_all_modifiers():
		if action_modifier.after_action_logic_callback.is_valid():
			action_modifier.after_action_logic_callback.call({})


func _on_resurrected() -> void:
	pass


func _on_gfm_fighting_phase_state_changed(fighting_phase_state: GlobalFightingManager.FightingPhaseState) -> void:
	match fighting_phase_state:
		GlobalFightingManager.FightingPhaseState.NORMAL:
			fighting_state = FightingState.FIGHTING
		GlobalFightingManager.FightingPhaseState.CELEBRATION:
			fighting_state = FightingState.CELEBRATING
#endregion


func _on_stunned_changed(is_active: bool, _duration: float, _infinite: bool) -> void:
	_on_stunned(is_active)


func _on_stunned(_is_active: bool) -> void:
	pass
