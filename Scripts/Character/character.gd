class_name Character
extends CharacterBody3D

# ============================== Signals ==============================

signal dead(dead_character: Character)

# ============================== Public variables ==============================

var team: int
var hero: Hero
var player: Player
var stats := CharacterStats.new() # Needs to be public for easier upgrades access

@onready var target_manager: TargetManager = %TargetManager # Needs to be public for easier access for other managers TODO Maybe rework ?

# ============================== Private variables ==============================

var _fighting_area: FightingArea
var _is_dead: bool = false
var _is_local: bool = false
var _fighting_state: FightingManager.FightingState = FightingManager.FightingState.WAITING_FOR_PLAYERS

# ============================== Local scene nodes ==============================

@onready var _character_visual: CharacterVisual = $CharacterVisual

@onready var _multiplayerSynchroniser: MultiplayerSynchronizer = %MultiplayerSynchronizer

# TODO Instantiate the manager dynamically with the game rules 
@onready var _auto_attack_manager: AutoAttackManager = %AutoAttackManager
@onready var _defense_manager: DefenseManager = %DefenseManager
@onready var _fire_manager: FireManager = %FireManager
@onready var _storm_manager: StormManager = %StormManager
@onready var _heal_manager: SerenityManager = %SerenityManager
@onready var _poison_manager: PoisonManager = %PoisonManager
@onready var _movement_manager: MovementManager = %MovementManager
@onready var _shadow_manager: ShadowManager = %ShadowManager
@onready var _life_manager: LifeManager = %LifeManager

# ============================== Node base functions ==============================

func _ready() -> void:
	_fighting_area = get_tree().get_root().find_child("FightingArea3D", true, false)
	
	_multiplayerSynchroniser.set_multiplayer_authority(player.id)
	_is_local = _multiplayerSynchroniser.get_multiplayer_authority() == multiplayer.get_unique_id()
	_character_visual.update_name_displayed(player.name)
	
	if _fighting_area != null and _is_local:
		_fighting_area.connect("map_clicked", _on_fighting_area_map_clicked)
	
	_apply_all_cards_upgrades()
	
	print(player.name, ": ", stats.health, "/", stats.health_max)

	_character_visual.update_health_bar(stats.health, stats.health_max)
	_character_visual.update_energy_bar(stats.energy, stats.energy_max)
	_character_visual.update_mana_bar(stats.mana, stats.mana_max)

# ============================== Damage and effect functions ==============================

# TODO Ajouter un percent_type pour savoir si on calcule les dégat sur base de vie max/ vie actuelle ou vie perdu
func take_damage_percent(source: Character, damage_percent: float, damage_type: Utils.DamageType) -> void:
	var damage = stats.health * damage_percent  / 100.0
	take_damage_flat(source, damage, damage_type)


func take_damage_flat(source: Character, damage: int, damage_type: Utils.DamageType) -> void:
	damage = _fire_manager.get_reduced_damage_taken_from(source, damage, damage_type) # Reduce % of MAGIC damage
	damage = _life_manager.get_reduced_damage_taken_from(source, damage, damage_type) # Reduce % of ALL damage
	damage = _defense_manager.get_reduced_damage_taken_from(source, damage, damage_type) # Reduce flat of PHYSIC AND MAGIC damage
	
	stats.health -= damage
	_character_visual.damage_popup(damage, damage_type)
	_character_visual.update_health_bar(stats.health, stats.health_max)
	if stats.health <= 0 and !_is_dead:
		dead.emit(self)
		_is_dead = true
		_auto_attack_manager.stop()


func take_poison_stacks(source: Character, poison_stacks: int, poison_duration: int) -> void:
	_poison_manager.add_to_poison_effects(source, poison_stacks, poison_duration)


func take_condition_stacks(_source: Character, stacks_number: int, stack_type: Utils.StackType) -> void:
	match stack_type:
		Utils.StackType.POISON:
			printerr("Should use take_poison_stacks()")
			return
		Utils.StackType.VULNERABILITY:
			stats.storm.vulnerability_stacks += stacks_number
			return

# ============================== Fighting States ==============================

func set_state(new_state: FightingManager.FightingState) -> void:
	match new_state:
		FightingManager.FightingState.STARTING:
			if _fighting_state != FightingManager.FightingState.WAITING_FOR_PLAYERS:
				printerr("Character: Can't change to starting phase if i'm not in WaitingForPlayers state")
				return
			_fighting_state = FightingManager.FightingState.STARTING
			target_manager.init(self)
			_start_movement_manager(FightingManager.FightingState.STARTING)
			for character in target_manager.get_all_characters():
				character.dead.connect(_on_character_dead)
		FightingManager.FightingState.FIGHT:
			if _fighting_state != FightingManager.FightingState.STARTING:
				printerr("Character: Can't change to fighting phase if i'm not in strating state")
				return
			_fighting_state = FightingManager.FightingState.FIGHT
			_movement_manager.set_fighting_state(FightingManager.FightingState.FIGHT)
			_start_auto_attack_manager()
			_start_defense_manager()
			_start_fire_manager()
			_start_storm_manager()
			_start_serenity_manager()
			_start_poison_manager()
			_start_shadow_manager()
			_start_life_manager()

# ============================== Private functions ==============================

func _apply_all_cards_upgrades() -> void:
	if player.deck == null:
		printerr("No deck on the player")
		return
	
	stats.init(hero.stats) # Reset stats
	for card in player.deck.cardPile:
		card.player_upgrade.apply(self.stats, card.lvl)

# ============================== AutoAttackManager ==============================

func _start_auto_attack_manager() -> void:
	if _auto_attack_manager == null:
		printerr("No AutoAttackManager")
		return
	
	_auto_attack_manager.heal_ally_triggered.connect(_on_auto_attack_manager_heal_ally_triggered)
	_auto_attack_manager.armor_gained.connect(_on_auto_attack_manager_armor_gained)
	_auto_attack_manager.max_health_gained.connect(_on_auto_attack_manager_max_health_gained)
	_auto_attack_manager.start(self, stats.auto_attack, hero.aa_projectile, hero)


func _on_auto_attack_manager_heal_ally_triggered(heal_amount: int) -> void:
	print("Heal ally for ", heal_amount)


func _on_auto_attack_manager_armor_gained(armor_stacks: int) -> void:
	stats.defense.armor_stacks += armor_stacks


func _on_auto_attack_manager_max_health_gained(health_amount: int) -> void:
	stats.health_max += health_amount
	stats.health += health_amount

# ============================== DefenseManager ==============================

func _start_defense_manager() -> void:
	if _defense_manager == null:
		printerr("No DefenseManager")
		return
	
	_defense_manager.armor_based_on_lost_hp_gained.connect(_on_defense_manager_armor_based_on_lost_hp_gained)
	_defense_manager.start(self, stats.defense)


func _on_defense_manager_armor_based_on_lost_hp_gained(percent_of_lost_hp: float) -> void:
	var lost_hp: float = stats.health_max - stats.health
	stats.defense.armor_stacks += (lost_hp * percent_of_lost_hp / 100.0) as int

# ============================== FireManager ==============================

func _start_fire_manager() -> void:
	if _fire_manager == null:
		printerr("No FireManager")
		return
	
	_fire_manager.start(self, stats.fire)

# ============================== StormManager ==============================

func _start_storm_manager() -> void:
	if _storm_manager == null:
		printerr("No StormManager")
		return
	
	_storm_manager.start(self, stats.storm)

# ============================== SerenityManager ==============================

func _start_serenity_manager() -> void:
	if _heal_manager == null:
		printerr("No SerenityManager")
		return
	
	_heal_manager.start(self, stats.heal)

# ============================== LifeManager ==============================

func _start_life_manager() -> void:
	if _life_manager == null:
		printerr("No LifeManager")
		return
	
	_life_manager.start(self, stats.hp)

# ============================== PoisonManager ==============================

func _start_poison_manager() -> void:
	if _poison_manager == null:
		printerr("No PoisonManager")
		return
	
	_poison_manager.start(self, stats.poison)

# ============================== MovementManager ==============================

func _start_movement_manager(fighting_state: FightingManager.FightingState) -> void:
	if _movement_manager == null:
		printerr("No MovementManager")
		return
	
	_movement_manager.connect("energy_changed", _on_movement_manager_energy_changed)
	_movement_manager.start(self, fighting_state)


func _on_movement_manager_energy_changed(energy: float) -> void:
	_character_visual.update_energy_bar(energy, stats.energy_max)

# ============================== ShadowManager ==============================

func _start_shadow_manager() -> void:
	if _movement_manager == null:
		printerr("No ShadowManager")
		return
	
	_shadow_manager.connect("heal_ally_triggered", _on_shadow_manager_heal_ally_triggered)
	_shadow_manager.connect("gain_max_hp_triggered", _on_shadow_manager_gain_max_hp_triggered)
	_shadow_manager.start(self, stats.shadow)


func _on_shadow_manager_heal_ally_triggered(heal_amount: int) -> void:
	print("Heal ally for", heal_amount)


func _on_shadow_manager_gain_max_hp_triggered(hp: int) -> void:
	stats.health_max += hp
	stats.health += hp
	_character_visual.update_health_bar(stats.health, stats.health_max)

# ============================== Signals callbacks ==============================

func _on_fighting_area_map_clicked(new_position: Vector3) -> void:
	if _is_dead or not _is_local:
		return
	_movement_manager.set_target_position(new_position)


func _on_character_dead(dead_character: Character) -> void:
	print("Oh no! ", dead_character.player.name, " is dead :(")
	target_manager.remove_character(dead_character)
