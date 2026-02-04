class_name Hero
extends Entity

# == VIRTUAL CLASS ==

#region ============================== Enums ==============================
enum DisplayMode {
	BUYING_PHASE, # Interface cachée (buying phase / bench)
	FIGHTING_PHASE, # Interface visible (combat)
	PREVIEW # Mode prévisualisation (shop, etc.)
}
#endregion

#region ============================== Signal ==============================
signal aa_done()
signal ultimate_casted()
#endregion

#region ============================== Export ==============================
@export_group("Configuration")
@export var hero_desc: HeroDesc
@export_range(1, 10, 1) var level: int = 1

@export_group("Optional")
@export var _custom_deck: PlayerDeck

#region ============================== Public variables ==============================
var display_mode: DisplayMode = DisplayMode.PREVIEW
var fighting_area: FightingArea
var families_stats: FamiliesStats
var deck: PlayerDeck

# Controls whether auto-attack module should start when entering FIGHTING state
var auto_attack_enabled: bool = true
var family_managers_enabled: bool = true
#endregion

#region ============================== Private variables ==============================
# Typed reference to parent's _animation_module
var _hero_animation: HeroAnimationModule:
	get: return _animation_module as HeroAnimationModule

var _skill_manager: SkillManager
var _family_managers: Dictionary[Family.FamilyType, FamilyManager]
#endregion

#region ============================== Public functions ==============================
func init(hero_display_mode: DisplayMode = DisplayMode.PREVIEW, fighting_area_ref: FightingArea = null) -> Hero:
	display_mode = hero_display_mode
	
	if fighting_area_ref != null:
		connect_to_fighting_area(fighting_area_ref)
	
	return self


func set_display_mode(mode: DisplayMode) -> void:
	display_mode = mode
	_apply_display_mode()


func connect_to_fighting_area(fighting_area_ref: FightingArea) -> void:
	Verbose.debug("Connecting to fighting area", Verbose.Category.HERO)
	if fighting_area_ref == null:
		Verbose.error("Trying to connect a null fighting area to a Hero", Verbose.Category.HERO)
		return
	
	fighting_area = fighting_area_ref
	_action_module.connect_to_spawn_manager(fighting_area.spawn_manager)
	_action_module.connect_to_arena_zone_manager(fighting_area.arena_zone_manager)


func get_auto_attack_spawn() -> Node3D:
	return self


#func get_rank_changed_signal() -> Signal: # TODO
	#return _get_rank_changed_signal()
#endregion

#region ===== Actions (Hero-specific overrides) =====

# Instant projectile attack (spells, abilities) - no animation
func projectile_attack(target: Entity, projectile_type: Projectile.ProjectileType, projectile_spawn: Node3D, projectile_stats: ProjectileStats) -> void:
	_action_module.projectile_attack(target, projectile_type, projectile_spawn, projectile_stats)


func cast_ultimate() -> void:
	ultimate_casted.emit()
#endregion


#region ============================== Node base functions ==============================
func _init() -> void:
	_hero_init()
	_entity_init()

func _hero_init() -> void:
	# Stats initialization is deferred to _hero_ready() to properly detect manual base_stats override
	pass


func _enter_tree() -> void:
	_hero_enter_tree()
	_entity_enter_tree()


func _hero_enter_tree() -> void:
	# Add Family Managers and Family stats
	families_stats = FamiliesStats.new()
	for family_type: Family.FamilyType in Shared.FAMILY_MANAGER_SCENES.keys():
		var family_manager: FamilyManager = Shared.FAMILY_MANAGER_SCENES[family_type].instantiate() as FamilyManager
		_family_managers[family_type] = family_manager.init(self)
		add_child(_family_managers[family_type])
	
	# Add AutoAttack Module
	if _auto_attack_module == null:
		var module: AutoAttackModule = Shared.ENTITY_MODULE_SCENES[Module.ModuleType.AUTOATTACK].instantiate()
		_auto_attack_module = module.init(self)
		add_child(_auto_attack_module)


func _ready() -> void:
	_hero_ready()


func _hero_ready() -> void:
	Verbose.debug("Hero [" + entity_name + "] ready", Verbose.Category.HERO)
	# Custom Deck (must be assigned here, not in _enter_tree, because @export vars aren't loaded yet there)
	if _custom_deck != null:
		deck = _custom_deck
	
	# Validate hero configuration
	if hero_desc == null and custom_base_stats == null:
		Verbose.error("Hero instantiated without hero_desc AND without custom_base_stats!", Verbose.Category.HERO)
		return
	
	# Initialize base_stats from hero_desc if not using custom_base_stats
	if custom_base_stats == null and hero_desc != null and base_stats != null:
		base_stats.reset_from_hero_desc(hero_desc, level)
	
	if deck != null:
		_apply_all_cards_upgrades()
	
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)

	stats.health_changed.connect(_on_stats_health_changed)
	fighting_state_changed.connect(_on_hero_fighting_state_changed)
	_auto_attack_module.attack_done.connect(_on_aa_module_attack_done)

	_apply_display_mode()

	_entity_ready()


func _exit_tree() -> void:
	# Disconnect all signals to avoid ghost references
	if GlobalFightingManager.fighting_phase_state_changed.is_connected(_on_gfm_fighting_phase_state_changed):
		GlobalFightingManager.fighting_phase_state_changed.disconnect(_on_gfm_fighting_phase_state_changed)
	if stats != null and stats.health_changed.is_connected(_on_stats_health_changed):
		stats.health_changed.disconnect(_on_stats_health_changed)
	if fighting_state_changed.is_connected(_on_hero_fighting_state_changed):
		fighting_state_changed.disconnect(_on_hero_fighting_state_changed)
	if _auto_attack_module != null and _auto_attack_module.attack_done.is_connected(_on_aa_module_attack_done):
		_auto_attack_module.attack_done.disconnect(_on_aa_module_attack_done)
#endregion

#region ============================== Private functions ==============================
func _on_hero_fighting_state_changed(new_fighting_state: FightingState) -> void:
	match new_fighting_state:
		FightingState.IDLE:
			_auto_attack_module.stop()
			for family_manager: FamilyManager in _family_managers.values():
				family_manager.stop()
		FightingState.FIGHTING:
			if auto_attack_enabled:
				_auto_attack_module.start()
			if family_managers_enabled:
				for family_manager: FamilyManager in _family_managers.values():
					family_manager.start()
		FightingState.CELEBRATING: pass
		FightingState.DEAD: pass
		FightingState.UNDEF: pass
#endregion

#region ============================== Private ==============================
func _apply_display_mode() -> void:
	match display_mode:
		DisplayMode.BUYING_PHASE, DisplayMode.PREVIEW:
			_entity_info_panel_3d.hide()
		DisplayMode.FIGHTING_PHASE:
			_entity_info_panel_3d.show()
	
	# Update animator (weapons + animations)
	if _hero_animation != null:
		_hero_animation.apply_display_mode(display_mode)


func _apply_all_cards_upgrades() -> void:
	Verbose.debug("Applying all cards upgrades", Verbose.Category.HERO)
	if deck == null:
		Verbose.error("Can't apply card upgrade, the deck is null", Verbose.Category.HERO)
		return
	
	for card: Card in deck.get_active_deck():
		card.player_upgrade.apply(families_stats, card.lvl)


func _handle_death() -> void:
	died.emit(self)
	_is_dead = true
#endregion

#region ============================== Other callbacks ==============================
func _on_gfm_fighting_phase_state_changed(fighting_phase_state: GlobalFightingManager.FightingPhaseState) -> void:
	match fighting_phase_state:
		GlobalFightingManager.FightingPhaseState.POSITIONING:
			fighting_state = FightingState.IDLE
		GlobalFightingManager.FightingPhaseState.NORMAL:
			fighting_state = FightingState.FIGHTING
		GlobalFightingManager.FightingPhaseState.CELEBRATING:
			fighting_state = FightingState.CELEBRATING


func _on_stats_health_changed(new_health: int) -> void:
	if new_health <= 0:
		signal_death()

 
func _on_aa_module_attack_done() -> void:
	aa_done.emit()
#endregion
