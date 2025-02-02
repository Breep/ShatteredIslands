class_name Character
extends StaticBody2D

# ============================== Signals ==============================

signal dead(dead_character: Character)

# ============================== Public variables ==============================

var team: int
var hero: Hero
var player: Player
var stats: CharacterStats # Needs to be public for easier upgrades access

@onready var target_manager: TargetManager = %TargetManager # Needs to be public for easier access for other managers TODO Maybe rework ?

# ============================== Private variables ==============================

var _aa_projectile = load("res://Scenes/Prefabs/projectile.tscn") # TODO move to hero
var _fighting_area: FightingArea # TODO remove
var _is_dead: bool = false
var _is_player_character: bool = false

# ============================== Local scene nodes ==============================

@onready var _timers_holder: Node = $Timers # TODO remove
@onready var _character_visual: CharacterVisual = $CharacterVisual

@onready var _multiplayerSynchroniser: MultiplayerSynchronizer = %MultiplayerSynchronizer

# TODO Instantiate the manager dynamically with the game rules 
@onready var _auto_attack_manager: AutoAttackManager = %AutoAttackManager
@onready var _defense_manager: DefenseManager = %DefenseManager
@onready var _fire_manager: FireManager = %FireManager
@onready var _storm_manager: StormManager = %StormManager
@onready var _heal_manager: SerenityManager = %SerenityManager
@onready var _poison_manager: PoisonManager = %PoisonManager

# ============================== Node base functions ==============================

func _ready() -> void:
	_fighting_area = get_tree().get_root().find_child("FightingArea", true, false)
	stats = hero.stats.duplicate(true) # Copy all hero base stats into a new stat resource
	stats.health = stats.health_max
	_character_visual.update_health_bar(stats.health, stats.health_max)
	_multiplayerSynchroniser.set_multiplayer_authority(player.id)
	_is_player_character = _multiplayerSynchroniser.get_multiplayer_authority() == multiplayer.get_unique_id()
	_character_visual.update_name_displayed(player.name)

	_apply_all_cards_upgrades()

# ============================== Public functions ==============================

# TODO Ajouter un percent_type pour savoir si on calcule les dégat sur base de vie max/ vie actuelle ou vie perdu
func take_damage_percent(source: Character, damage_percent: float, damage_type: Utils.DamageType) -> void:
	var damage = stats.health * damage_percent  / 100.0
	take_damage_flat(source, damage, damage_type)


func take_damage_flat(source: Character, damage: int, damage_type: Utils.DamageType) -> void:
	if _fire_manager != null:
		damage = _fire_manager.get_reduced_damage_taken_from(source, damage, damage_type)
	
	if _defense_manager != null:
		damage = _defense_manager.get_reduced_damage_taken_from(source, damage, damage_type)
	
	stats.health -= damage
	_character_visual.damage_popup(damage, damage_type)
	_character_visual.update_health_bar(stats.health, stats.health_max)
	if stats.health <= 0 and !_is_dead:
		dead.emit(self)
		_is_dead = true
		_auto_attack_manager.stop()


func take_poison_stacks(source: Character, poison_stacks: int, poison_duration: int) -> void:
	_add_to_poison_effects(source, poison_stacks, poison_duration)


func take_condition_stacks(source: Character, stacks_number: int, stack_type: Utils.StackType) -> void:
	match stack_type:
		Utils.StackType.POISON:
			printerr("Should use take_poison_stacks()")
			return
		Utils.StackType.VULNERABILITY:
			stats.storm.vulnerability_stacks += stacks_number
			return


# So the SpawnManager can notify when all characters are spawned
func connect_all_players_spawned_signal(node: Node, signal_name: String) -> void:
	node.connect(signal_name, _on_all_players_spawned, CONNECT_ONE_SHOT)


# ============================== Private functions ==============================

func _move_to_cell(cell : Vector2):
	if _is_dead: return
	position = _fighting_area.get_global_cell_position(cell)


func _apply_all_cards_upgrades() -> void:
	if player.deck == null:
		printerr("No deck on the player")
		return
	
	stats = hero.stats.duplicate(true) # Reset stats
	stats.health = stats.health_max
	for card in player.deck.cardPile:
		card.player_upgrade.apply(self, card.lvl)
	
	_update_auto_attack_speed()
	_create_optional_timers()


func _update_auto_attack_speed() -> void:
	stats.auto_attack.attack_speed = hero.stats.auto_attack.attack_speed # Get default hero attack speed
	var attack_speed_boost: float = stats.auto_attack.attack_speed_boost + stats.auto_attack.attack_speed_overtime_current
	var multiply_boost: float = remap(attack_speed_boost, 0, 100, 1, 2) # Convert % in proportional multiple (100% = x2 | 150% = x2.5)
	stats.auto_attack.attack_speed *= multiply_boost
	_auto_attack_manager.set_auto_attack_speed(stats.auto_attack.attack_speed)


func _create_optional_timers() -> void:
	# Gatling Gun
	if stats.auto_attack.attack_speed_overtime_min != 0:
		Utils.create_optional_timer(_timers_holder, 1, _on_aa_speed_overtime_timer)


func _add_to_poison_effects(source: Character, poison_stacks: int, poison_duration: int) -> void:
	if poison_stacks == 0:
		return
	
	for effect in stats.poison.poison_effects:
		if effect.source == source and effect.ticks_left == poison_duration:
			effect.stacks_number += poison_stacks
			return
	
	var new_effect := PoisonEffect.new()
	new_effect.stacks_number = poison_stacks
	new_effect.ticks_left = poison_duration
	new_effect.source = source
	stats.poison.poison_effects.append(new_effect)


# TODO code heal function
func _heal_ally(heal_amount: int) -> void:
	print("Heal ally")


# ============================== AutoAttackManager ==============================

func _start_auto_attack_manager() -> void:
	if _auto_attack_manager == null:
		printerr("No AutoAttackManager")
		return
	
	_auto_attack_manager.heal_ally_triggered.connect(_on_auto_attack_manager_heal_ally_triggered)
	_auto_attack_manager.armor_gained.connect(_on_auto_attack_manager_armor_gained)
	_auto_attack_manager.max_health_gained.connect(_on_auto_attack_manager_max_health_gained)
	_auto_attack_manager.start(self, stats.auto_attack, _aa_projectile)


func _on_auto_attack_manager_heal_ally_triggered(heal_amount: int) -> void:
	print("Heal ally")


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

# ============================== PoisonManager ==============================

func _start_poison_manager() -> void:
	if _poison_manager == null:
		printerr("No PoisonManager")
		return
	
	_poison_manager.start(self, stats.poison)

# ============================== Signals callbacks ==============================

func _on_all_players_spawned() -> void:
	target_manager.init(self)
	
	for character in target_manager.get_all_characters():
		character.dead.connect(_on_character_dead)
	
	_start_auto_attack_manager()
	_start_defense_manager()
	_start_fire_manager()
	_start_storm_manager()
	_start_serenity_manager()
	_start_poison_manager()


func _on_moving_timer_timeout() -> void:
	if _is_dead or not _is_player_character:
		return
	
	if _fighting_area.is_selection_active:
		_move_to_cell(_fighting_area.selection_cell)


func _on_poison_tick_timer_timeout() -> void:
	var poison_damage: int = 0
	for effect in stats.poison.poison_effects:
		if effect.ticks_left > 0:
			effect.ticks_left -= 1
			poison_damage += effect.stacks_number
		else:
			stats.poison.poison_effects.erase(effect)
	
	if poison_damage > 0:
		take_damage_flat(null, _poison_manager.get_reduced_damage_taken_from(poison_damage), Utils.DamageType.POISON)


func _on_vulnerability_tick_timer_timeout() -> void:
	stats.storm.vulnerability_stacks -= 0.1 * stats.storm.vulnerability_stacks


func _on_character_dead(dead_character: Character) -> void:
	print("Oh no! ", dead_character.player.name, " is dead :(")
	target_manager.remove_character(dead_character)

# ============================== Optional callbacks ==============================

# TODO Move this to the auto attack manager
var __aa_speed_overtime_ticks: int = 0 # static variable for _on_aa_speed_overtime_timer()
func _on_aa_speed_overtime_timer() -> void:
	var attack_speed_overtime_current = remap(__aa_speed_overtime_ticks, \
			0, stats.auto_attack.attack_speed_overtime_duration, \
			stats.auto_attack.attack_speed_overtime_min, stats.auto_attack.attack_speed_overtime_max)
	stats.auto_attack.attack_speed_overtime_current = clampf(attack_speed_overtime_current, \
			stats.auto_attack.attack_speed_overtime_min, stats.auto_attack.attack_speed_overtime_max)
	_update_auto_attack_speed()
	__aa_speed_overtime_ticks += 1
