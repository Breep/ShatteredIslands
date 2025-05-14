class_name Character
extends Entity

# ============================== Export variables (Network) ==============================

@export var owner_player_id: int # ID of the player owner of this character
@export var fighting_state: GlobalFightingManager.FightingState:
	get: return _fighting_state
	set(value):
		_set_state(value)

# ============================== Public variables ==============================

var hero: Hero
var player: Player
var stats: CharacterStats

# ============================== Private variables ==============================

var _fighting_area: FightingArea
var _is_dead: bool = false
var _is_local: bool = false

var _fighting_state: GlobalFightingManager.FightingState = GlobalFightingManager.FightingState.UNDEF

# ============================== Local scene nodes ==============================

@onready var _character_visual: CharacterVisual = $CharacterVisual

@onready var _server_synchronizer: MultiplayerSynchronizer = %ServerSynchronizer

@onready var target_manager: TargetManager = %TargetManager # Needs to be public for easier access for other managers TODO Maybe rework ?

@onready var _movement_module: MovementModule = %MovementManager

@onready var _attack_manager: AttackManager = %AttackManager
@onready var _defense_manager: DefenseManager = %DefenseManager
@onready var _fire_manager: FireManager = %FireManager
@onready var _storm_manager: StormManager = %StormManager
@onready var _serenity_manager: SerenityManager = %SerenityManager
@onready var _poison_manager: PoisonManager = %PoisonManager
@onready var _life_manager: LifeManager = %LifeManager
@onready var _shadow_manager: ShadowManager = %ShadowManager

var _families_managers: Dictionary # { Family.FamilyType: FamilyManager }

@onready var _action_module: ActionModule = %ActionModule
@onready var _interact_module: InteractModule = %InteractModule
@onready var _auto_attack_module: AutoAttackModule = %AutoAttackModule

# ============================== Node base functions ==============================

func _ready() -> void:
	player = PlayerManager.players[owner_player_id]
	hero = player.hero
	stats = player.character_stats
	
	_is_local = player.id == multiplayer.get_unique_id()
	
	_fighting_area = get_tree().get_root().find_child("FightingArea3D", true, false)
	
	#_server_synchronizer.set_multiplayer_authority(player.id)
	_character_visual.load_hero_model(hero)
	_character_visual.update_name_displayed(player.name)
	_character_visual.attach_to_attack_done_signal(_auto_attack_module.attack_done)
	
	if _fighting_area != null and _is_local:
		_fighting_area.connect("map_clicked", _on_fighting_area_map_clicked)
	
	_build_families_managers()
	_character_visual.update_health_bar(stats.health, stats.health_max)
	_character_visual.update_energy_bar(stats.energy, stats.energy_max)
	_character_visual.update_mana_bar(stats.mana, stats.mana_max)
	
	Shared.fighting_managers_ref[battle_id].fight_is_over.connect(_on_fighting_manager_fight_is_over)
	GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)
	
	_recursive_propagate_signal(get_parent(), Entity.SIGNAL_NAME_SPAWNED)

# ============================== Fighting States ==============================
   
func _set_state(new_state: GlobalFightingManager.FightingState) -> void:
	#print("[", multiplayer.get_unique_id(), "] DEBUG : ", id, " - ", _fighting_state, " - ", new_state)
	match new_state:
		GlobalFightingManager.FightingState.STARTING:
			if _fighting_state != GlobalFightingManager.FightingState.UNDEF:
				printerr("Character: Can't change to starting phase if i'm not in WaitingForPlayers state")
				return
			_fighting_state = GlobalFightingManager.FightingState.STARTING
			_init_families_managers()
			_init_modules()
			_init_movement_module(GlobalFightingManager.FightingState.STARTING)
			_movement_module.start()
		GlobalFightingManager.FightingState.FIGHT:
			if _fighting_state != GlobalFightingManager.FightingState.STARTING:
				printerr("Character: Can't change to fighting phase if i'm not in starting state")
				return
			_fighting_state = GlobalFightingManager.FightingState.FIGHT
			_start_families_managers()
			_auto_attack_module.start()
			_movement_module.set_fighting_state(new_state)

# ============================== MovementManager ==============================

func _init_movement_module(fighting_state: GlobalFightingManager.FightingState) -> void:
	if _movement_module == null:
		printerr("No MovementManager")
		return
	
	_movement_module.energy_changed.connect(_on_movement_module_energy_changed)
	_movement_module.init(self, fighting_state)

# ============================== MovementManager ==============================

func _on_movement_module_energy_changed(energy: float) -> void:
	_character_visual.update_energy_bar(energy, stats.energy_max)

# ============================== Families Managers ==============================

func _build_families_managers() -> void:
	_families_managers[Family.FamilyType.ATTACK] = _attack_manager
	_families_managers[Family.FamilyType.DEFENSE] = _defense_manager
	_families_managers[Family.FamilyType.FIRE] = _fire_manager
	_families_managers[Family.FamilyType.STORM] = _storm_manager
	_families_managers[Family.FamilyType.SERENITY] = _serenity_manager
	_families_managers[Family.FamilyType.POISON] = _poison_manager
	_families_managers[Family.FamilyType.LIFE] = _life_manager
	_families_managers[Family.FamilyType.SHADOW] = _shadow_manager


func _init_families_managers() -> void:
	for family_manager in _families_managers.values():
		family_manager.init(self)
	
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
	_movement_module.stop()
	_auto_attack_module.stop()
	dead.emit(self)
	_is_dead = true

# ============================== Signals callbacks ==============================

func _on_fighting_area_map_clicked(new_position: Vector3) -> void:
	if _is_dead or not _is_local:
		return
	_movement_module.set_target_position(new_position)


# ============================== Family callbacks ==============================

func _on_life_manager_revived(life_after_revived: int) -> void:
	stats.health = life_after_revived
	_character_visual.update_health_bar(stats.health, stats.health_max)
	_start_families_managers()
	_movement_module.start()
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


# ============================== Other callbacks ==============================

func _on_fighting_manager_fight_is_over(_winner_team) -> void:
	_stop_families_managers()
	_movement_module.stop()
	_auto_attack_module.stop()


func _on_global_fighting_manager_state_changed(new_state: GlobalFightingManager.FightingState) -> void:
	fighting_state = new_state












 
