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
#endregion

#region ============================== Export ==============================
@export_group("Configuration")
@export var hero_desc: HeroDesc
@export_range(1, 10, 1) var level: int = 1

@export_group("Optional configuration")
@export_subgroup("Prototyping")
@export var _custom_deck: PlayerDeck
@export var family_managers_enabled: bool = true

#region ============================== Public variables ==============================
var display_mode: DisplayMode = DisplayMode.PREVIEW
var families_stats: FamiliesStats
var deck: PlayerDeck

# Controls whether family managers should start when entering FIGHTING state
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
#endregion

#region ===== Actions (Hero-specific overrides) =====

# Instant projectile attack (spells, abilities) - no animation
func cast_ultimate() -> void:
	ultimate_casted.emit()
#endregion


#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	# Add Family Managers and Family stats
	families_stats = FamiliesStats.new()
	for family_type: Family.FamilyType in Shared.FAMILY_MANAGER_SCENES.keys():
		var family_manager: FamilyManager = Shared.FAMILY_MANAGER_SCENES[family_type].instantiate() as FamilyManager
		_family_managers[family_type] = family_manager.init(self)
		add_child(_family_managers[family_type])
	
	super._enter_tree()


func _ready() -> void:
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

	_apply_display_mode()

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
		FightingState.CELEBRATING: pass
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
#endregion

#region ============================== Other callbacks ==============================
func _on_stunned(is_active: bool) -> void:
	if is_active:
		for family_manager: FamilyManager in _family_managers.values():
			family_manager.pause()
	else:
		for family_manager: FamilyManager in _family_managers.values():
			family_manager.resume()
#endregion
