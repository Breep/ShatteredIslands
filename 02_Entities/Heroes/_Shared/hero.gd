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

@export_group("Optional configuration")
@export var player: Player

@export_subgroup("Prototyping")
@export var _custom_deck: PlayerDeck
@export var family_managers_enabled: bool = true
@export var _override_family_levels: Dictionary[Family.Type, int] = {}
@export var _custom_data_memory: Dictionary

#region ============================== Public variables ==============================
var display_mode: DisplayMode = DisplayMode.PREVIEW
var deck: PlayerDeck
var data_memory: NestedRegistry

# Delegate vers FamilyModule.families_stats (lecture seule via Hero pour back-compat
# avec les nombreux call sites `hero.families_stats.X` côté cards/UI).
var families_stats: FamiliesStats:
	get:
		if _family_module == null:
			return null
		return _family_module.families_stats
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
	if _family_module == null:
		return {}
	return _family_module.get_families_level()



func get_card_context() -> CardContext:
	if _deck_holder == null:
		return null
	return _deck_holder.get_card_context()


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
	if data_memory == null: data_memory = NestedRegistry.new()
	# super._enter_tree() charge les modules (dont FamilyModule, qui crée les
	# FamilyManagers comme ses enfants).
	super._enter_tree()


func _ready() -> void:
	Verbose.debug("Hero [" + entity_name + "] ready", Verbose.Category.HERO)

	# CUSTOM CONF
	if _custom_deck != null: deck = _custom_deck
	if not _custom_data_memory.is_empty(): data_memory.override(_custom_data_memory)

	# Sync entity_desc ← hero_desc pendant la transition (Hero garde son export
	# hero_desc, mais le code générique lit via Entity.entity_desc).
	if entity_desc == null and hero_desc != null:
		entity_desc = hero_desc

	# Validate hero configuration
	if hero_desc == null and custom_base_stats == null:
		Verbose.error("Hero instantiated without hero_desc AND without custom_base_stats!", Verbose.Category.HERO)
		return

	# Initialize base_stats from hero_desc if not using custom_base_stats
	if custom_base_stats == null and hero_desc != null and base_stats != null:
		base_stats.reset_from_hero_desc(hero_desc, level)

	# Compute family levels from deck (or use overrides for prototyping)
	_family_module.compute_levels(deck, _override_family_levels)

	# Build card context via DeckHolder module (création indépendante du deck)
	_deck_holder.setup()

	if deck != null:
		_deck_holder.apply_all_cards_upgrades(deck)
		deck.has_changed.connect(_on_deck_has_changed)

	_apply_display_mode()
	_family_module.apply_passive_all()

	super._ready()
	
	# Automatically select play hero on spawn
	if player == PlayerManager.get_local_player():
		Events.entity_clicked.emit(self)
#endregion

#region ============================== Private functions ==============================
func _on_fighting_state_changed(new_fighting_state: FightingState) -> void:
	super._on_fighting_state_changed(new_fighting_state)
	match new_fighting_state:
		FightingState.IDLE:
			_family_module.stop_all()
		FightingState.FIGHTING:
			if family_managers_enabled:
				_family_module.start_all()
		FightingState.CELEBRATING:
			_family_module.stop_all()
		FightingState.UNDEF: pass
#endregion

#region ============================== Private ==============================
func _apply_display_mode() -> void:
	if _display_mode_module != null:
		_display_mode_module.apply(display_mode)
#endregion

#region ============================== Other callbacks ==============================
func _on_deck_has_changed() -> void:
	_family_module.compute_levels(deck, _override_family_levels)
#endregion
