class_name Character
extends Entity

# ============================== Signals ==============================

signal dead(dead_character: Character)

# ============================== Public variables ==============================

var team: int
var hero: Hero
var player: Player
var stats: CharacterStats


# ============================== Private variables ==============================

var _fighting_area: FightingArea
var _is_dead: bool = false
var _is_local: bool = false
var _fighting_state: FightingManager.FightingState = FightingManager.FightingState.WAITING_FOR_PLAYERS

# ============================== Local scene nodes ==============================

@onready var _character_visual: CharacterVisual = $CharacterVisual

@onready var _multiplayerSynchroniser: MultiplayerSynchronizer = %MultiplayerSynchronizer

@onready var target_manager: TargetManager = %TargetManager # Needs to be public for easier access for other managers TODO Maybe rework ?

@onready var _movement_manager: MovementManager = %MovementManager

@onready var _attack_manager: AttackManager = %AttackManager
@onready var _defense_manager: DefenseManager = %DefenseManager
@onready var _fire_manager: FireManager = %FireManager
@onready var _storm_manager: StormManager = %StormManager
@onready var _serenity_manager: SerenityManager = %SerenityManager
@onready var _poison_manager: PoisonManager = %PoisonManager
@onready var _shadow_manager: ShadowManager = %ShadowManager
@onready var _life_manager: LifeManager = %LifeManager

var _families_managers: Dictionary # { Family.FamilyType: FamilyManager }

@onready var _action_module: ActionModule = %ActionModule
@onready var _interact_module: InteractModule = %InteractModule
@onready var _auto_attack_module: AutoAttackModule = %AutoAttackModule

# ============================== Node base functions ==============================

func _ready() -> void:
	_fighting_area = get_tree().get_root().find_child("FightingArea3D", true, false)
	
	_multiplayerSynchroniser.set_multiplayer_authority(player.id)
	_is_local = _multiplayerSynchroniser.get_multiplayer_authority() == multiplayer.get_unique_id()
	_character_visual.load_hero_model(hero)
	_character_visual.update_name_displayed(player.name)
	
	if _fighting_area != null and _is_local:
		_fighting_area.connect("map_clicked", _on_fighting_area_map_clicked)
	
	stats = player.character_stats
	_build_families_managers()
	_character_visual.update_health_bar(stats.health, stats.health_max)
	_character_visual.update_energy_bar(stats.energy, stats.energy_max)
	_character_visual.update_mana_bar(stats.mana, stats.mana_max)

	_recursive_propagate_spawn_signal(get_parent(), EntityManager.SIGNAL_NAME_ENTITY_SPAWNED)

# ============================== Notice critic ==============================

# The character needs to know how much damage he deals to the enemy for calculations with critical (mostly storm family)
# So character needs to notice the source of damage that he dealt a critical damage and tells him how much he dealt
# I don't like this solution, but I can't figure out something else
func notice_critical_damage(target: Character, damage: int) -> void:
	_storm_manager.notice_critical_damage(target, damage)

# ============================== Fighting States ==============================

func set_state(new_state: FightingManager.FightingState) -> void:
	match new_state:
		FightingManager.FightingState.STARTING:
			if _fighting_state != FightingManager.FightingState.WAITING_FOR_PLAYERS:
				printerr("Character: Can't change to starting phase if i'm not in WaitingForPlayers state")
				return
			_fighting_state = FightingManager.FightingState.STARTING
			_init_families_managers()
			_init_modules()
			_init_movement_manager(FightingManager.FightingState.STARTING)
			_movement_manager.start()
		FightingManager.FightingState.FIGHT:
			if _fighting_state != FightingManager.FightingState.STARTING:
				printerr("Character: Can't change to fighting phase if i'm not in starting state")
				return
			_fighting_state = FightingManager.FightingState.FIGHT
			_start_families_managers()
			_auto_attack_module.start()
			_movement_manager.set_fighting_state(FightingManager.FightingState.FIGHT)

# ============================== MovementManager ==============================

func _init_movement_manager(fighting_state: FightingManager.FightingState) -> void:
	if _movement_manager == null:
		printerr("No MovementManager")
		return
	
	_movement_manager.connect("energy_changed", _on_movement_manager_energy_changed)
	_movement_manager.init(self, fighting_state)
# ============================== MovementManager ==============================

func _on_movement_manager_energy_changed(energy: float) -> void:
	_character_visual.update_energy_bar(energy, stats.energy_max)

# ============================== Families Managers ==============================

func _build_families_managers() -> void:
	_families_managers[Family.FamilyType.Attack] = _attack_manager
	_families_managers[Family.FamilyType.Defense] = _defense_manager
	_families_managers[Family.FamilyType.Fire] = _fire_manager
	_families_managers[Family.FamilyType.Storm] = _storm_manager
	_families_managers[Family.FamilyType.Serenity] = _serenity_manager
	_families_managers[Family.FamilyType.Poison] = _poison_manager
	_families_managers[Family.FamilyType.Life] = _life_manager
	_families_managers[Family.FamilyType.Shadow] = _shadow_manager


func _init_families_managers() -> void:
	for family_manager in _families_managers.values():
		family_manager.init(self)
	
	_defense_manager.armor_based_on_lost_hp_gained.connect(_on_defense_manager_armor_based_on_lost_hp_gained)
	_life_manager.revived.connect(_on_life_manager_revived)
	_shadow_manager.gain_max_hp_triggered.connect(_on_shadow_manager_gain_max_hp_triggered)
	_attack_manager.focus_changed.connect(_on_auto_attack_manager_focus_changed)


func _start_families_managers() -> void:
	for family_manager in _families_managers.values():
		family_manager.start()


func _stop_families_managers() -> void:
	for family_manager in _families_managers.values():
		family_manager.stop()

# ============================== Modules ==============================

func _init_modules() -> void:
	_auto_attack_module.init(self, _families_managers)
	_action_module.init(self, _families_managers)
	_interact_module.init(self, _families_managers)
	
	_interact_module.damage_taken.connect(_on_interact_module_damage_taken)
	_interact_module.heal_received.connect(_on_interact_module_heal_received)
	
	_auto_attack_module.set_projectile(hero.aa_projectile_type)

# ============================== Private ==============================

func _handle_death() -> void:
	_stop_families_managers()
	_life_manager.source_is_dead()
	_movement_manager.stop()
	dead.emit(self, false)
	_is_dead = true

# ============================== Signals callbacks ==============================

func _on_fighting_area_map_clicked(new_position: Vector3) -> void:
	if _is_dead or not _is_local:
		return
	_movement_manager.set_target_position(new_position)


# ============================== Family callbacks ==============================

func _on_defense_manager_armor_based_on_lost_hp_gained(percent_of_lost_hp: float) -> void:
	var lost_hp: float = stats.health_max - stats.health
	stats.defense.armor_stacks += (lost_hp * percent_of_lost_hp / 100.0) as int


func _on_life_manager_revived(life_after_revived: int) -> void:
	stats.health = life_after_revived
	_character_visual.update_health_bar(stats.health, stats.health_max)
	_start_families_managers()
	_movement_manager.start()
	_is_dead = false
	Events.character_is_spawned.emit(self)


func _on_shadow_manager_gain_max_hp_triggered(hp: int) -> void:
	stats.health_max += hp
	stats.health += hp
	_character_visual.update_health_bar(stats.health, stats.health_max)


func _on_auto_attack_manager_focus_changed(focused: bool) -> void:
	_storm_manager.focus_changed(focused)

# ============================== Module callbacks ==============================

func _on_interact_module_damage_taken(damage: int, damage_type: Utils.DamageType, is_critical: bool) -> void:
	_character_visual.damage_popup(damage, damage_type, is_critical)
	_character_visual.update_health_bar(stats.health, stats.health_max)
	if stats.health <= 0 and !_is_dead:
		_handle_death()


func _on_interact_module_heal_received(heal_amount: int) -> void:
	if heal_amount != 0:
		_character_visual.damage_popup(heal_amount, Utils.DamageType.HEAL, false)
		_character_visual.update_health_bar(stats.health, stats.health_max)




















 
