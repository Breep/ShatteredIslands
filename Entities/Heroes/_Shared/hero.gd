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
signal ultimate_casted()
signal fight_is_won()
signal fight_is_lost()
#endregion

#region ============================== Export ==============================
@export_group("Configuration")
@export var hero_desc: HeroDesc
@export_range(1, 10, 1) var level: int = 1

@export_group("Optional configuration")
@export_subgroup("Prototyping")
@export var _custom_deck: PlayerDeck
@export var family_managers_enabled: bool = true
@export var _override_family_levels: Dictionary[Family.Type, int] = {}
@export var _custom_data_memory: Dictionary

#region ============================== Public variables ==============================
var display_mode: DisplayMode = DisplayMode.PREVIEW
var families_stats: FamiliesStats
var deck: PlayerDeck
var data_memory: NestedRegistry

var _card_context: CardContext
#endregion

#region ============================== Private variables ==============================
# Typed reference to parent's _animation_module
var _hero_animation: HeroAnimationModule:
	get: return _animation_module as HeroAnimationModule

var _skill_manager: SkillManager
var _family_managers: Dictionary[Family.Type, FamilyManager]
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


func get_families_level() -> Dictionary[Family.Type, int]:
	var families_level: Dictionary[Family.Type, int]
	for family_type in _family_managers.keys():
		families_level[family_type] = _family_managers[family_type].level
	return families_level
	

func get_card_context() -> CardContext:
	return _card_context


func handle_end_of_fight(is_winner: bool) -> void:
	if is_winner: fight_is_won.emit()
	else: fight_is_lost.emit()
#endregion

#region ===== Actions (Hero-specific overrides) =====
func cast_ultimate() -> void:
	ultimate_casted.emit()
#endregion

func process_tick() -> void:
	super.process_tick()

#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	# Add Family Managers and Family stats
	families_stats = FamiliesStats.new()
	for family_type: Family.Type in Shared.FAMILY_MANAGER_SCENES.keys():
		var family_manager: FamilyManager = Shared.FAMILY_MANAGER_SCENES[family_type].instantiate() as FamilyManager
		_family_managers[family_type] = family_manager.init(self)
		add_child(_family_managers[family_type])
	
	if data_memory == null: data_memory = NestedRegistry.new()
	super._enter_tree()


func _ready() -> void:
	Verbose.debug("Hero [" + entity_name + "] ready", Verbose.Category.HERO)
	
	# CUSTOM CONF
	if _custom_deck != null: deck = _custom_deck
	if not _custom_data_memory.is_empty(): data_memory.override(_custom_data_memory)

	# Validate hero configuration
	if hero_desc == null and custom_base_stats == null:
		Verbose.error("Hero instantiated without hero_desc AND without custom_base_stats!", Verbose.Category.HERO)
		return

	# Initialize base_stats from hero_desc if not using custom_base_stats
	if custom_base_stats == null and hero_desc != null and base_stats != null:
		base_stats.reset_from_hero_desc(hero_desc, level)

	# Compute family levels from deck (or use overrides for prototyping)
	_compute_family_levels()

	# Build card context for the new card system
	_card_context = CardContext.create(self, stat_modifiers_registry, action_modifiers_registry, auto_attack_modifier_registry, periodic_timer_registry, battle_callback_registry)

	if deck != null:
		_apply_all_cards_upgrades()

	_apply_display_mode()
	for family_manager: FamilyManager in _family_managers.values():
		family_manager.apply_passive()

	super._ready()
#endregion

#region ============================== Private functions ==============================
func _on_fighting_state_changed(new_fighting_state: FightingState) -> void:
	super._on_fighting_state_changed(new_fighting_state)
	match new_fighting_state:
		FightingState.IDLE:
			for family_manager: FamilyManager in _family_managers.values():
				family_manager.stop()
		FightingState.FIGHTING:
			if family_managers_enabled:
				for family_manager: FamilyManager in _family_managers.values():
					family_manager.start()
		FightingState.CELEBRATING:
			for family_manager: FamilyManager in _family_managers.values():
				family_manager.stop()
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


func _compute_family_levels() -> void:
	for family_type: Family.Type in _family_managers:
		if _override_family_levels.has(family_type):
			_family_managers[family_type].level = _override_family_levels[family_type]
		elif deck != null:
			var points: int = deck.get_family_points(family_type)
			if GameManager.game_rules != null:
				_family_managers[family_type].level = GameManager.game_rules.get_family_level(points)


func _apply_all_cards_upgrades() -> void:
	Verbose.debug("Applying all cards upgrades", Verbose.Category.HERO)
	if deck == null:
		Verbose.error("Can't apply card upgrade, the deck is null", Verbose.Category.HERO)
		return

	for card: Card in deck.get_active_deck():
		card.player_upgrade.apply_card(_card_context, card.lvl)
#endregion

#region ============================== Other callbacks ==============================
func _on_stunned(is_active: bool) -> void:
	if is_active:
		periodic_timer_registry.pause_all()
		for family_manager: FamilyManager in _family_managers.values():
			family_manager.pause()
	else:
		periodic_timer_registry.resume_all()
		for family_manager: FamilyManager in _family_managers.values():
			family_manager.resume()
#endregion
