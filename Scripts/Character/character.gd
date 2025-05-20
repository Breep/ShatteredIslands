class_name Character
extends Entity

# ============================== Export variables (Network) ==============================

@export var owner_player_id: int # ID of the player owner of this character
@export var fighting_state: GlobalFightingManager.FightingState:
	get: return _fighting_state
	set(value):
		_set_state(value)

# ============================== Export ==============================

@export var _hero: Hero
@export var _is_prototype: bool # 

# ============================== Public variables ==============================

var player: Player
var stats: CharacterStats

@onready var target_manager: TargetManager = %TargetManager # Needs to be public for easier access for other managers TODO Maybe rework ?

# ============================== Private variables ==============================

var _is_dead: bool = false
var _is_local: bool = false

var _fighting_state: GlobalFightingManager.FightingState = GlobalFightingManager.FightingState.UNDEF

# ============================== Local scene nodes ==============================

@onready var _character_visual: CharacterVisual = $CharacterVisual
@onready var _server_synchronizer: MultiplayerSynchronizer = %ServerSynchronizer

var _families_managers: Dictionary # { Family.FamilyType: FamilyManager }
@export var _attack_manager: AttackManager
@export var _defense_manager: DefenseManager
@export var _fire_manager: FireManager
@export var _storm_manager: StormManager
@export var _serenity_manager: SerenityManager
@export var _poison_manager: PoisonManager
@export var _life_manager: LifeManager

@export var _movement_module: MovementModule
@export var _action_module: ActionModule
@export var _interact_module: InteractModule
@export var _auto_attack_module: AutoAttackModule

@export var _turret: Turret

# ============================== Public functions ==============================

func apply_cards_upgrade(deck: PlayerDeck) -> void:
	stats.reset_stats(_hero.stats)
	for card in deck.card_pile:
		card.player_upgrade.apply(stats, card.lvl)

# ============================== Node base functions ==============================

func _init() -> void:
	stats = CharacterStats.new()


func _enter_tree() -> void:
	_build_families_managers()


func _ready() -> void:
	printerr("Character is a virtual class and shouldn't be instanciated")


func _character_ready() -> void:
	stats.reset_stats(_hero.stats)
	
	if _is_prototype:
		fighting_state = GlobalFightingManager.FightingState.STARTING
		fighting_state = GlobalFightingManager.FightingState.FIGHT
		_recursive_propagate_signal(get_parent(), Entity.SIGNAL_NAME_SPAWNED)
	else:
		player = PlayerManager.players[owner_player_id]
		if battle_id != -1:
			Shared.fighting_managers_ref[battle_id].fight_is_over.connect(_on_fighting_manager_fight_is_over)
			_recursive_propagate_signal(get_parent(), Entity.SIGNAL_NAME_SPAWNED)
			_character_visual.update_health_bar(stats.health, stats.health_max)
			_character_visual.update_mana_bar(stats.mana, stats.mana_max)
			_character_visual.update_name_displayed(player.name)
			GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)
		else:
			_character_visual.queue_free()
			if _turret != null: _turret.queue_free()
	
	_is_local = player.id == multiplayer.get_unique_id()
	
	#_server_synchronizer.set_multiplayer_authority(player.id)

# ============================== Fighting States ==============================

func _set_state(new_state: GlobalFightingManager.FightingState) -> void:
	print("[", multiplayer.get_unique_id(), "] DEBUG : ", id, " - ", _fighting_state, " - ", new_state)
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
	
	_movement_module.init(self, fighting_state)

# ============================== Families Managers ==============================

func _build_families_managers() -> void:
	_families_managers[Family.FamilyType.ATTACK] = _attack_manager
	_families_managers[Family.FamilyType.DEFENSE] = _defense_manager
	_families_managers[Family.FamilyType.FIRE] = _fire_manager
	_families_managers[Family.FamilyType.STORM] = _storm_manager
	_families_managers[Family.FamilyType.SERENITY] = _serenity_manager
	_families_managers[Family.FamilyType.POISON] = _poison_manager
	_families_managers[Family.FamilyType.LIFE] = _life_manager


func _init_families_managers() -> void:
	for family_manager in _families_managers.values():
		family_manager.init(self)
	
	_life_manager.revived.connect(_on_life_manager_revived)
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
	target_manager.init()
	await get_tree().create_timer(1.0).timeout
	var target: Entity = target_manager.get_target(TargetManager.TargettingStrategy.CLOSEST_ENEMY)
	if target != null:
		if _turret != null:
			_turret.target = target
	else:
		printerr("NO TARGET")
	
	_interact_module.damage_taken.connect(_on_interact_module_damage_taken)
	_interact_module.heal_received.connect(_on_interact_module_heal_received)
	
	_auto_attack_module.set_projectile(_hero.aa_projectile_type)

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












 
