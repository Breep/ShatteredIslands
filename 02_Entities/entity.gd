class_name Entity
extends CharacterBody3D

# == VIRTUAL CLASS ==

#region ============================== Signals ==============================
signal died(self_ref: Entity)
signal action_received(source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool)
signal action_done(target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool)
signal action_dodged(source: Entity, action_type: Utils.ActionType, value: float, is_critical: bool)
signal action_blocked(source: Entity, action_type: Utils.ActionType, value: float)
signal critical_action_done(target: Entity, action_type: Utils.ActionType, value_before_crit: float, value_after_crit: float)
signal action_overhealed(target: Entity, amount: float)
signal damage_taken(damage: float, damage_type: Utils.ActionType, is_critical: bool, blocked_by_armor: bool)
signal heal_taken(heal_amount: float, is_critical: bool)
signal stack_taken(stack_type: Alteration.Type, stack_number: float, is_critical: bool)
signal auto_attack_completed() # TODO: A virer
signal auto_attack_launched(target: Entity) # Swing déclenché (serveur) → loggé pour replay client
signal spell_casted(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary)
signal spawn_completed()
signal resurrected()
signal ultimate_casted()
signal fight_is_won()
signal fight_is_lost()
#endregion

##region ============================== Enums ==============================
enum LifeState { ALIVE, DEAD }
enum FightRole { MAIN, SECONDARY, EXTRA }
enum Category { HERO, SUMMON, ACOLYTE, ANTAGONIST, BUILDING, MOB }
enum DisplayMode { BUYING_PHASE, FIGHTING_PHASE, PREVIEW }
enum FightingState { SPAWNING, IDLE, FIGHTING, CELEBRATING, UNDEF }
#TODO Bouger ça ailleurs => ça va devenir très gros
enum EntityType {
	HERO, # TODO remove this
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
	CHICKEN_EGG,
	MOLTEN_GOLEM
}
#endregion

#region ============================== Export ==============================
@export var entity_name: String = "<entity name>"
@export var category: Category = Category.MOB
@export var entity_desc: EntityDesc

@export_group("Visual")
@export var _visual_3d: Node3D
@export var _health_bar_marker: Marker3D
@export_subgroup("Auto Attack")
@export var _attack_spawn_marker: Marker3D # TODO A bouger dans le projectile component ? Ou attack component ?
@export var _projectile_type: Projectile.Type

@export_group("Formation")
@export_range(1, 20, 1) var level: int = 1
@export var fight_role: FightRole = FightRole.EXTRA

@export_group("Optional configuration")
@export var invisible: bool = false

@export_group("Prototyping")
@export_subgroup("Context")
@export var team: int = -1 # Team number of the entity
@export var battle_id: int = -1 # The id of the battle the entity is in
@export var _spawn_manager: SpawnManager
@export var _arena_zone_manager: ArenaZoneManager
@export_subgroup("Overrides")
@export var override_base_stats: EntityStats
@export var override_custom_hand: Hand
@export var override_data_memory: Dictionary
@export var override_family_levels: Dictionary[Family.Type, int] = {}
@export_subgroup("Behaviour")
@export var auto_attack_enabled: bool = true
@export var family_managers_enabled: bool = true
@export var initial_controller_mode: EntityController.Mode = EntityController.Mode.AUTO
#endregion

#region ============================== Constants ==============================
const TICKS_PER_SECOND: int = 60
## Cap appliqué aux bonus de level cumulés sur summons/acolytes/buildings
## via les *_modifiers_registry.register_level_bonus(). Aligné sur le
## @export_range de `level` et sur la couverture de ProgressionComponent.DEFAULT_LEVEL_REFS.
const MAX_LEVEL: int = 20
#endregion

var uid: int = -1 # Multiplayer ID of the entity
var stats: EntityStats
var summoner: Entity # Set via apply_context si l'entité a été invoquée par une autre
# Roaster du joueur propriétaire. Posé au spawn pour les héros uniquement
# (sert de source pour CardContext quand le héros joue une carte qui mute le
# roaster). null pour acolytes/summons/buildings/mobs.
var roaster: Roaster
# RoasterEntry dont cette Entity est l'instance runtime. Posée au spawn par
# EntitySpec.spawn_into. Sert au snapshot de positions (POSITIONING→COUNTDOWN)
# et à toute logique qui doit remonter de l'entité vers sa donnée persistante.
var entry: RoasterEntry

#region ============================== Components ==============================
var damage: DamageComponent
var heal: HealComponent
var projectile: ProjectileComponent
var spell: SpellComponent
var summon: SummonComponent
var auto_attack: AutoAttackComponent
var alterations: AlterationsComponent
var target: TargetComponent
var movement: MovementComponent
var label_popup: LabelPopupComponent
var animation: AnimationComponent
var spawn: SpawnAnimationComponent
var despawn: DespawnAnimationComponent
var clickable: ClickableComponent
var draggable: DraggableComponent
var controller: EntityController
var display_mode_module: DisplayModeModule # TODO ça à l'air inutil ça à virer je pense
var deck_holder: DeckHolderComponent
var family: FamilyComponent
var mana: ManaComponent
var health_bar: HealthBarComponent
var progression: ProgressionComponent
var skill: SkillComponent
var aura: AuraComponent
var hit_marker: HitMarkerComponent

var _auto_loaded_components: Array[EntityComponent.Type] = [
	EntityComponent.Type.DAMAGE,
	EntityComponent.Type.HEAL,
	EntityComponent.Type.PROJECTILE,
	EntityComponent.Type.SPELL,
	EntityComponent.Type.SUMMON,
	EntityComponent.Type.AUTO_ATTACK,
	EntityComponent.Type.ALTERATIONS,
	EntityComponent.Type.TARGET,
	EntityComponent.Type.MOVEMENT,
	EntityComponent.Type.LABEL_POPUP,
	EntityComponent.Type.ANIMATION,
	EntityComponent.Type.SPAWN_ANIMATION,
	EntityComponent.Type.DESPAWN_ANIMATION,
	EntityComponent.Type.CLICKABLE,
	EntityComponent.Type.DRAGGABLE,
	EntityComponent.Type.CONTROLLER,
	EntityComponent.Type.MANA,
	EntityComponent.Type.PROGRESSION,
	EntityComponent.Type.SKILL,
	EntityComponent.Type.DECK_HOLDER,
	EntityComponent.Type.AURA,
	EntityComponent.Type.HIT_MARKER
]

#var display_mode: DisplayMode = DisplayMode.PREVIEW
var data_memory: NestedRegistry
#endregion

#region ============================== Modifiers ==============================
var auto_attack_modifier_registry: AutoAttackModifierRegistry
var action_modifiers_registry: ActionModifiersRegistry
var stat_modifiers_registry: EntityStatModifiersRegistry
var death_modifiers_registry: DeathModifiersRegistry
var battle_callback_registry: BattleCallbackRegistry
var summon_modifiers_registry: SummonModifiersRegistry
var acolyte_modifiers_registry: AcolyteModifiersRegistry
var building_modifiers_registry: BuildingModifiersRegistry
var projectile_modifiers_registry: ProjectileModifiersRegistry
#endregion

##region ============================== Context ============================== 
# TODO Checker si c'est normal d'exposer ça public
var spawn_manager: SpawnManager:
	get: return _spawn_manager
#endregion

#region ============================== Private variables ==============================


# Spawn system # TODO Checker que'est-ce que ça fait ici plutôt que dans le spawn component ?
var _original_fighting_state: FightingState = FightingState.UNDEF
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

## Quand true, l'entité morte ne disparaît pas (pas de despawn) et n'élimine pas
## son équipe : elle attend une résurrection (ex: légendaire Colossus). Posé/retiré
## par l'effet de carte qui gère la renaissance.
var can_revive: bool = false

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

#region ============================== Helpers ==============================
func is_alive() -> bool: return life_state == LifeState.ALIVE
func is_dead() -> bool: return life_state == LifeState.DEAD
func is_summoned() -> bool: return category == Category.SUMMON
func is_hero() -> bool: return category == Category.HERO
#endregion

#region ============================== Init ==============================
func _init() -> void:
	# Stats
	stats = EntityStats.new()
	
	# Default Modifier Registries
	auto_attack_modifier_registry = AutoAttackModifierRegistry.new()
	action_modifiers_registry = ActionModifiersRegistry.new()
	death_modifiers_registry = DeathModifiersRegistry.new()
	stat_modifiers_registry = EntityStatModifiersRegistry.new(stats)
	summon_modifiers_registry = SummonModifiersRegistry.new()
	acolyte_modifiers_registry = AcolyteModifiersRegistry.new()
	building_modifiers_registry = BuildingModifiersRegistry.new()
	projectile_modifiers_registry = ProjectileModifiersRegistry.new()
	Verbose.trace("Entity [" + entity_name + "_" + str(uid) + "] init", Verbose.Category.ENTITY)


func _enter_tree() -> void:
	Verbose.trace("Entity [" + entity_name + "_" + str(uid) + "] enter_tree", Verbose.Category.ENTITY)
	
	_auto_load_components()
	
	battle_callback_registry = BattleCallbackRegistry.new()
	
	if is_hero() and data_memory == null:
		data_memory = NestedRegistry.new()


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

	spawn.spawn_finished.connect(_on_spawn_finished)

	# Connect module interdependencies
	_connect_module_dependencies()

	match category:
		Category.SUMMON: _apply_inherited_summon_modifiers()
		Category.ACOLYTE: _apply_inherited_acolyte_modifiers()
		Category.BUILDING: _apply_inherited_building_modifiers()

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


# Rayon horizontal (plan XZ) du corps de collision, mise à l'échelle du node incluse
# (donc sensible au SCALE dès lors que celui-ci redimensionne l'entité, pas que le visuel).
# Sert à la détection de portée corps-à-corps des auto-attaques mélée. On impose la
# CapsuleShape3D comme shape de corps unique pour l'instant : tout autre type loggue
# et renvoie 0.
func get_body_radius() -> float:
	for child in get_children():
		if not child is CollisionShape3D:
			continue
		var collision_shape: CollisionShape3D = child
		if collision_shape.shape == null:
			continue
		var shape_scale: Vector3 = collision_shape.global_transform.basis.get_scale()
		var scale_xz: float = maxf(absf(shape_scale.x), absf(shape_scale.z))
		if collision_shape.shape is CapsuleShape3D:
			return (collision_shape.shape as CapsuleShape3D).radius * scale_xz
		Verbose.warn("Entity [" + entity_name + "] : get_body_radius attend une CapsuleShape3D, type [" + collision_shape.shape.get_class() + "] non géré", Verbose.Category.ENTITY)
		return 0.0
	return 0.0


# La cible est-elle à portée d'auto-attaque de cette entité ?
# Ranged : distance centre-à-centre vs attack_range (≤ 0 = portée infinie).
# Mélée : on tient compte des rayons de corps des DEUX entités — attack_range devient
# l'allonge AU-DELÀ des corps. Sans ça, le body-block d'une grosse cible la rend
# inatteignable : les centres ne peuvent jamais se rejoindre à moins de la somme des
# rayons, donc un attack_range mélée plus petit que cette somme n'est jamais satisfait.
func is_target_in_attack_range(target: Entity) -> bool:
	if not is_instance_valid(target):
		return false
	var range_stat: float = stats.attack_range
	var distance_sq: float = global_position.distance_squared_to(target.global_position)
	if stats.auto_attack_type == EntityStats.AutoAttackType.MELEE:
		var reach: float = get_body_radius() + target.get_body_radius() + maxf(range_stat, 0.0)
		return distance_sq <= reach * reach
	if range_stat <= 0.0:
		return true
	return distance_sq <= range_stat * range_stat


func process_tick() -> void:
	if movement != null:
		movement.process_tick()
	if auto_attack != null:
		auto_attack.process_tick()
	if alterations != null:
		alterations.process_tick()
	spawn.process_tick()
	# Effets périodiques (timers de cartes/familles, tick de mana…) = simulation :
	# serveur uniquement. Le client les rejoue via le BattleReader, il ne les tire pas.
	if battle_callback_registry != null and multiplayer.is_server():
		battle_callback_registry.process_tick()
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

	# Si le contexte porte un entity_owner, il devient notre summoner. Cas couverts :
	# - summon-via-summon_component (cat = SUMMON) → register dans le BDS registry
	#   du summoner pour que l'action meter compte le summon.
	# - acolyte/building spawné depuis le Roaster (cat = ACOLYTE/BUILDING) → on
	#   ferme la chaîne sur le héros propriétaire pour le SummonModifiersRegistry,
	#   mais on n'inscrit PAS au BDS (un acolyte n'est pas un summon de gameplay).
	# Pour heroes/mobs/antagonists/etc., entity_owner est null → pas de summoner.
	if context.entity_owner != null:
		summoner = context.entity_owner
		if summoner.bds_registry != null and is_summoned():
			summoner.bds_registry.register_summon(self)

	# Composants potentiellement encore null si apply_context est appelé avant
	# add_child (cf SpawnManager.spawn_entity). Les guards évitent le crash ;
	# _enter_tree rejouera _connect_components_to_managers une fois auto-loaded.
	_connect_components_to_managers()

	Verbose.debug("Entity [" + entity_name + "] received fighting_state [" + str(FightingState.keys()[context.fighting_state]) + "] from context", Verbose.Category.ENTITY)


# Câble les composants au spawn_manager / arena_zone_manager. Idempotent et
# null-safe : peut être appelé plusieurs fois (avant et après auto-loading).
func _connect_components_to_managers() -> void:
	if _spawn_manager == null: return
	if projectile != null:
		projectile.connect_to_spawn_manager(_spawn_manager)
	if spell != null:
		spell.connect_to_spawn_manager(_spawn_manager)
	if summon != null:
		summon.connect_to_spawn_manager(_spawn_manager)
		summon.connect_to_arena_zone_manager(_arena_zone_manager)
	if target != null:
		target.connect_to_spawn_manager(_spawn_manager)


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
	ultimate_casted.emit()


# Hook appelé par FightingManager sur chaque entité vivante quand le combat se termine.
func handle_end_of_fight(is_winner: bool) -> void:
	if is_winner: fight_is_won.emit()
	else: fight_is_lost.emit()


func resurrect(hp_percent: float) -> void:
	if life_state != LifeState.DEAD:
		Verbose.error("Entity [" + entity_name + "] try to resurrect while not dead.", Verbose.Category.ENTITY)
		return

	stats.health = stats.health_max * (hp_percent / 100)
	life_state = LifeState.ALIVE
	_state_machine.start_combat_modules()
	resurrected.emit()
	AudioManager.play_3d("resurrection", global_position, 0.95)
#endregion

#region ============================== Hero archetype API ==============================
# Set le display_mode et connecte la fighting area. Appelé en chaîne après
# instantiate() par les call sites de prototyping.
#func init_display(hero_display_mode: DisplayMode = DisplayMode.PREVIEW, fighting_area_ref: FightingArea = null) -> Entity:
	#display_mode = hero_display_mode
	#if fighting_area_ref != null:
		#connect_to_fighting_area(fighting_area_ref)
	#return self
#
#
#func set_display_mode(mode: DisplayMode) -> void:
	#display_mode = mode


func get_families_level() -> Dictionary[Family.Type, int]:
	if family == null:
		return {}
	return family.get_families_level()


func get_card_context() -> CardContext:
	if deck_holder == null:
		return null
	return deck_holder.get_card_context()
#endregion

# ============================== Private functions ==============================

#region ============================== Summon modifiers ==============================
# Remonte la chaîne summoner et apply le summon_modifiers_registry de chaque
# ancêtre sur cette entité (clone + register). Snapshot au moment du spawn :
# les modifiers ajoutés à un ancêtre après ce point ne se propageront pas
# aux summons déjà nés.
#
# Niveau : un summon naît au niveau de son ancre — le premier ancêtre non-summon
# en remontant la chaîne (poulailler, tour, héros…) — auquel s'ajoute le bonus de
# chaîne complet. On vise l'ancre plutôt que le summoner direct car un maillon
# summon intermédiaire a déjà le bonus de chaîne dans son propre niveau : le
# prendre comme base le compterait deux fois.
func _apply_inherited_summon_modifiers() -> void:
	var visited: Array[Entity] = []
	var ancestor: Entity = summoner
	var total_level_bonus: int = 0
	var base_level: int = level
	var base_level_found: bool = false
	while ancestor != null:
		if ancestor in visited:
			Verbose.error("Cycle in summoner chain for [" + entity_name + "] at [" + ancestor.entity_name + "]", Verbose.Category.ENTITY)
			return
		visited.append(ancestor)
		if ancestor.summon_modifiers_registry != null:
			ancestor.summon_modifiers_registry.apply_to(self, ancestor)
			total_level_bonus += ancestor.summon_modifiers_registry.get_total_level_bonus()
		if not base_level_found and ancestor.category != Category.SUMMON:
			base_level = ancestor.progression.level if ancestor.progression != null else ancestor.level
			base_level_found = true
		ancestor = ancestor.summoner
	_set_inherited_level(base_level + total_level_bonus)


func _apply_inherited_acolyte_modifiers() -> void:
	var visited: Array[Entity] = []
	var ancestor: Entity = summoner
	var total_level_bonus: int = 0
	while ancestor != null:
		if ancestor in visited:
			Verbose.error("Cycle in summoner chain for [" + entity_name + "] at [" + ancestor.entity_name + "]", Verbose.Category.ENTITY)
			return
		visited.append(ancestor)
		if ancestor.acolyte_modifiers_registry != null:
			ancestor.acolyte_modifiers_registry.apply_to(self, ancestor)
			total_level_bonus += ancestor.acolyte_modifiers_registry.get_total_level_bonus()
		ancestor = ancestor.summoner
	_apply_inherited_level_bonus(total_level_bonus)


func _apply_inherited_building_modifiers() -> void:
	var visited: Array[Entity] = []
	var ancestor: Entity = summoner
	var total_level_bonus: int = 0
	while ancestor != null:
		if ancestor in visited:
			Verbose.error("Cycle in summoner chain for [" + entity_name + "] at [" + ancestor.entity_name + "]", Verbose.Category.ENTITY)
			return
		visited.append(ancestor)
		if ancestor.building_modifiers_registry != null:
			ancestor.building_modifiers_registry.apply_to(self, ancestor)
			total_level_bonus += ancestor.building_modifiers_registry.get_total_level_bonus()
		ancestor = ancestor.summoner
	_apply_inherited_level_bonus(total_level_bonus)


# Applique un bonus de level cumulé (sommé sur la chaîne summoner via les
# *_modifiers_registry.get_total_level_bonus()). Push sur progression.level
# pour déclencher le recompute des base stats via _handle_level_up().
# Utilisé par les acolytes / buildings : ils ajoutent au niveau propre issu de
# leur entry roaster (≠ summons, qui posent un niveau absolu via _set_inherited_level).
func _apply_inherited_level_bonus(bonus: int) -> void:
	if bonus <= 0: return
	var new_level: int = clampi(level + bonus, 1, MAX_LEVEL)
	level = new_level
	if progression != null:
		progression.level = new_level


# Pose le niveau absolu d'un summon (niveau de l'ancre + bonus de chaîne),
# clampé. Push sur progression.level pour déclencher le recompute des base stats.
func _set_inherited_level(new_level: int) -> void:
	var clamped: int = clampi(new_level, 1, MAX_LEVEL)
	level = clamped
	if progression != null:
		progression.level = clamped
#endregion

#region ============================== Spawn system ==============================
func _start_spawn() -> void:
	fighting_state = FightingState.SPAWNING
	Verbose.debug("Entity [" + entity_name + "] starting spawn", Verbose.Category.ENTITY)
	spawn.start_spawn()


func _on_spawn_finished() -> void:
	Verbose.debug("Entity [" + entity_name + "] completing spawn", Verbose.Category.ENTITY)
	if _fighting_state != FightingState.FIGHTING:
		fighting_state = _original_fighting_state
	spawn_completed.emit()
#endregion

#region ============================== Auto loading ==============================
func _auto_load_components() -> void:
	for ect: EntityComponent.Type in _auto_loaded_components:
		# Les buildings sont statiques : pas de MovementComponent. Sans lui, l'approche
		# de l'auto-attaque échoue proprement (cf. AutoAttackComponent "fixed turret"),
		# donc plus de translation parasite ni de dérive par dépénétration. L'orientation
		# de tir reste gérée par l'auto-attaque / les skills (look_at direct), pas par le
		# mouvement.
		if ect == EntityComponent.Type.MOVEMENT and category == Category.BUILDING:
			continue
		EntityComponent.add(ect, self)

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

	if animation != null:
		animation.connect_modules(auto_attack)
	
	if label_popup != null:
		label_popup.connect_marker(_health_bar_marker)

	# Controller en dernier — il a besoin que les autres modules (auto_attack, target,
	# battle_callback_registry) soient prêts avant de commencer à prendre des décisions.
	# set_mode active aussi l'enfant correspondant (AIController ou PlayerController).
	if controller != null:
		controller.set_mode(initial_controller_mode)
#endregion

#region ============================== Callbacks ==============================
func _on_fighting_state_changed(new_fighting_state: FightingState) -> void:
	Verbose.debug("Entity [" + entity_name + "] fighting state changed to [" + str(FightingState.keys()[new_fighting_state]) + "]", Verbose.Category.ENTITY)
	_state_machine.transition_to(new_fighting_state)

	#match new_fighting_state:
		#FightingState.IDLE:
			#family.stop_all()
		#FightingState.FIGHTING:
			#if family_managers_enabled:
				#family.start_all()
		#FightingState.CELEBRATING:
			#family.stop_all()
		#FightingState.UNDEF:
			#pass


func _on_stats_health_changed(new_health: float) -> void:
	if new_health < 1:
		died.emit()


func _on_stats_scale_changed(new_scale: float) -> void:
	# Un scale <= 0 rend le visuel invisible tout en gardant la collision active :
	# symptôme silencieux d'une stat SCALE mal renseignée. On log et on n'applique pas.
	if new_scale <= 0.0:
		Verbose.warn("Entity [" + entity_name + "] scale <= 0 ignoré (donnée SCALE invalide)", Verbose.Category.ENTITY)
		return
	if is_instance_valid(_visual_3d):
		_visual_3d.scale = Vector3(new_scale, new_scale, new_scale)


func _on_died() -> void:
	Verbose.debug("Entity [" + entity_name + "] died", Verbose.Category.ENTITY)

	life_state = LifeState.DEAD
	_state_machine.stop_combat_modules()

	for death_modifier in death_modifiers_registry.consume_all_modifiers():
		if death_modifier.after_action_logic_callback.is_valid():
			death_modifier.after_action_logic_callback.call({})
	
	collision_layer = 0


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


func _on_stunned(is_active: bool) -> void:
	# AutoAttackComponent gère lui-même son pause/resume via stunned_changed.
	# Ici on s'occupe juste du registry de callbacks.
	if is_active:
		battle_callback_registry.pause_timers()
	else:
		battle_callback_registry.resume_timers()

#endregion
