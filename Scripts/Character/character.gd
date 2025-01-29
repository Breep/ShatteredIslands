class_name Character
extends StaticBody2D

# ============================== Signals ==============================

signal death(dead_player)

# ============================== Enums ==============================

enum DamageType {
	NORMAL,
	CRITIC,
	POISON,
	MAGIC,
}

# ============================== Export variables ==============================

@export var team: int
@export var hero: Hero

# ============================== Public variables ==============================

var player: Player
var stats: CharacterStats # Needs to be public for easier upgrades access

# ============================== Private variables ==============================

var _aa_projectile = load("res://Scenes/Prefabs/projectile.tscn")
var _fighting_area: FightingArea
var _characters: Array[Character]
var _enemies: Array[Character]
var _allies: Array[Character]
var _is_dead: bool = false
var _is_player_character: bool = false

var _poison_effects: Array[CharacterEffect]

# ============================== Local scene nodes ==============================

@onready var _timers_holder: Node = $Timers
@onready var _aa_timer: Timer = $Timers/AutoAttackTimer
@onready var _character_visual: CharacterVisual = $CharacterVisual
@onready var _multiplayerSynchroniser: MultiplayerSynchronizer = %MultiplayerSynchronizer

# ============================== Node base functions ==============================

func _ready() -> void:
	_fighting_area = get_tree().get_root().find_child("FightingArea", true, false)
	stats = hero.stats.duplicate(true) # Copy all hero base stats into a new stat resource
	_character_visual.update_health_bar(stats.health, hero.stats.health)
	# TMP !!!!!!!!!!!!!!!!!!!!!!!!!!!
	if team == 42: 
		_character_visual.update_name_displayed("Spide Ren'heure")
		return
	if team == 43: 
		_character_visual.update_name_displayed("Alex_Supertramp")
		return
	_multiplayerSynchroniser.set_multiplayer_authority(player.id)
	_is_player_character = _multiplayerSynchroniser.get_multiplayer_authority() == multiplayer.get_unique_id()
	_character_visual.update_name_displayed(player.name)
	
	#connect to all death signals
	for character in _characters:
		character.death.connect(_on_death)
	
	_apply_all_cards_upgrades()

# ============================== Public functions ==============================

func get_closest_enemy_from(from_character: Character) -> Character:
	if _enemies.is_empty():
		return null
	
	var closest_enemy: Character = _enemies[0]
	for enemy in _enemies:
		if enemy != from_character:
			var enemy_distance = (enemy.position - from_character.position).length_squared()
			var closest_enemy_distance = (closest_enemy.position - from_character.position).length_squared()
			if enemy_distance < closest_enemy_distance:
				closest_enemy = enemy
	
	return closest_enemy


func hit_by_auto_attack(src: Character, aa_stats: AutoAttackProjectileStats):
	stats.health -= aa_stats.damage # Normal Auto-Attack physical damage
	if aa_stats.isCritic:
		_character_visual.damage_popup(aa_stats.damage, DamageType.CRITIC)
	else:
		_character_visual.damage_popup(aa_stats.damage, DamageType.NORMAL)
	
	# Fire auto-attack magical damage
	if aa_stats.fire_active:
		var fire_damage: int = (aa_stats.fire_damage / 100) * stats.health
		stats.health -= fire_damage
		_character_visual.damage_popup(fire_damage, DamageType.MAGIC)
	
	stats.vulnerability_stacks += aa_stats.vulnerability_stacks
	
	_character_visual.update_health_bar(stats.health, hero.stats.health)
	
	# Boucing effect
	if aa_stats.is_bouncing:
		aa_stats.is_bouncing = false
		_create_aa_projectile_from_projectile(aa_stats, src, src.get_closest_enemy_from(self))
	
	# Poison stack
	_add_to_effects_buffer(aa_stats, src)
	
	if stats.health <= 0 and !_is_dead:
		death.emit(self)
		_is_dead = true


func connect_all_players_spawned_signal(node: Node, signal_name: String) -> void:
	node.connect(signal_name, _on_all_players_spawned, CONNECT_ONE_SHOT)


# ============================== Private functions ==============================

func _move_to_cell(cell : Vector2):
	if _is_dead: return
	position = _fighting_area.get_global_cell_position(cell)


func _get_closest_enemy() -> Character:
	if _enemies.is_empty():
		return null
	
	var closest_enemy: Character = _enemies[0]
	for enemy in _enemies:
		if (enemy.position - position).length_squared() < (closest_enemy.position - position).length_squared():
			closest_enemy = enemy
	
	return closest_enemy


func _get_closest_ally() -> Character:
	if _allies.is_empty():
		return null
	
	var closest_ally: Character = _allies[0]
	for ally in _allies:
		if (ally.position - position).length_squared() < (closest_ally.position - position).length_squared():
			closest_ally = ally
	
	return closest_ally


var __aa_counter: int = 0
func _auto_attack():
	if _enemies.is_empty(): 
		return
	
	__aa_counter += 1
	if stats.auto_attack.fire_attack_activated:
		if __aa_counter % stats.auto_attack.fire_attack_period == 0:
			stats.auto_attack.fire_attack_triggered = true
	
	if stats.auto_attack.increase_max_hp_activated:
		if __aa_counter % stats.auto_attack.increase_max_hp_period == 0:
			stats.health_max += stats.auto_attack.increase_max_hp_amount
			stats.health += stats.auto_attack.increase_max_hp_amount
			print("Max hp = ", stats.health_max)
	
	if _is_randomize_modifier_active(stats.auto_attack.armor_stacks_chance):
		stats.armor_stacks += stats.auto_attack.armor_stacks_amount
		print("Current armor: ", stats.armor_stacks)
	
	if _is_randomize_modifier_active(stats.auto_attack.healing_attack_chance):
		_heal_ally(stats.auto_attack.healing_attack_heal_amount)
	
	_create_aa_projectile_from_character(stats, self, _get_closest_enemy())
	stats.auto_attack.fire_attack_triggered = false


# TODO Rework ces 3 fonctions Dé gueu lasse
func _create_aa_projectile_from_character(character_stats: CharacterStats, source: Character, target: Character) -> void:
	var projectile: Projectile = _aa_projectile.instantiate()
	projectile.target = target
	projectile.set_stats_from_character_stats(character_stats)
	_spawn_projectile(projectile, source, target)


func _create_aa_projectile_from_projectile(projectile_stats: AutoAttackProjectileStats, source: Character, target: Character) -> void:
	var projectile: Projectile = _aa_projectile.instantiate()
	projectile.stats = projectile_stats
	_spawn_projectile(projectile, source, target)


func _spawn_projectile(projectile: Projectile, source: Character, target: Character) -> void:
	if source == null:
		printerr("Can't create a projectile with no source character")
		return
	
	if target == null:
		printerr("Can't create a projectile with no target character")
		return
	
	projectile.target = target
	projectile.source = source
	_fighting_area.add_child(projectile)
	projectile.global_position = $ProjectileSpawn.global_position + Vector2(randf_range(-10,10), randf_range(-10,10))
	projectile.global_rotation = $ProjectileSpawn.global_rotation
 

func _get_all_scene_characters() -> Array[Character]:
	var ret: Array[Character]
	for node in get_tree().get_nodes_in_group("PLAYERS"):
		ret.append(node as Character)
	return ret


func _get_enemies_from_characters() -> Array[Character]:
	var ret: Array[Character]
	for character in _characters:
		if character.team != team:
			ret.append(character)
	
	return ret


func _get_allies_from_characters() -> Array[Character]:
	var ret: Array[Character]
	for character in _characters:
		if character.team == team:
			ret.append(character)
	
	return ret
 

func _apply_all_cards_upgrades() -> void:
	if player.deck == null:
		printerr("No deck on the player")
		return
	
	stats = hero.stats.duplicate(true) # Reset stats
	for card in player.deck.cardPile:
		card.player_upgrade.apply(self, card.lvl)
	
	_update_auto_attack_speed()
	_create_optional_timers()


func _update_auto_attack_speed() -> void:
	stats.auto_attack.attack_speed = hero.stats.auto_attack.attack_speed # Get default hero attack speed
	var attack_speed_boost: float = stats.auto_attack.attack_speed_boost + stats.auto_attack.attack_speed_overtime_current
	var multiply_boost: float = remap(attack_speed_boost, 0, 100, 1, 2) # Convert % in proportional multiple (100% = x2 | 150% = x2.5)
	stats.auto_attack.attack_speed *= multiply_boost
	
	if stats.auto_attack.attack_speed == 0:
		printerr("attack speed is equal to 0 !")
		_aa_timer.wait_time = 1.0
	else:
		_aa_timer.wait_time = 1.0 / stats.auto_attack.attack_speed


func _create_optional_timers() -> void:
	# Gatling Gun
	if stats.auto_attack.attack_speed_overtime_min != 0:
		_create_auto_attack_speed_overtime_timer()


func _create_auto_attack_speed_overtime_timer() -> void:
	var timer := Timer.new()
	timer.wait_time = 1
	timer.one_shot = false
	_timers_holder.add_child(timer)
	timer.connect("timeout", _on_aa_speed_overtime_timer)
	timer.start()


# TODO Améliorer cette immonde fonction
func _add_to_effects_buffer(aa_stats: AutoAttackProjectileStats, src: Character) -> void:
	if aa_stats.poison_stacks != 0:
		for effect in _poison_effects:
			if (effect.type == CharacterEffect.EffectType.POISON and effect.source == src) and effect.ticks_left == aa_stats.poison_duration:
				effect.number += aa_stats.poison_stacks
				return
		
		var new_effect := CharacterEffect.new()
		new_effect.type = CharacterEffect.EffectType.POISON
		new_effect.number = aa_stats.poison_stacks
		new_effect.ticks_left = aa_stats.poison_duration
		new_effect.source = src
		_poison_effects.append(new_effect)


# TODO move to lib
func _is_randomize_modifier_active(chance: float) -> bool:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf_range(0, 100) <= chance


# TODO code heal function
func _heal_ally(heal_amount: int) -> void:
	print("Heal ally")

# ============================== Signals callbacks ==============================

func _on_all_players_spawned() -> void:
	_characters = _get_all_scene_characters()
	_enemies = _get_enemies_from_characters()
	_allies = _get_allies_from_characters()


func _on_auto_attack_timer_timeout() -> void:
	if _is_dead:
		return
	
	_auto_attack()


func _on_moving_timer_timeout() -> void:
	if _is_dead or not _is_player_character:
		return
	
	# TMP !!!!!!!!!!!!!!!!!!!!!!!!!!!
	if team == 42: return
	# TMP !!!!!!!!!!!!!!!!!!!!!!!!!!!
	if team == 43: return
	
	if _fighting_area.is_selection_active:
		_move_to_cell(_fighting_area.selection_cell)


func _on_poison_tick_timer_timeout() -> void:
	var poison_damage: int = 0
	for effect in _poison_effects:
		if effect.ticks_left > 0:
			effect.ticks_left -= 1
			poison_damage += effect.number
		else:
			_poison_effects.erase(effect)
	
	if poison_damage > 0:
		stats.health -= poison_damage
		_character_visual.damage_popup(poison_damage, DamageType.POISON)


func _on_vulnerability_tick_timer_timeout() -> void:
	stats.vulnerability_stacks -= 0.1 * stats.vulnerability_stacks


func _on_death(dead_player: Character) -> void:
	print("Oh no! ", dead_player.name, " is dead :(")
	_characters.erase(dead_player)
	_enemies.erase(dead_player)
	_allies.erase(dead_player)

# ============================== Optional callbacks ==============================

var __aa_speed_overtime_ticks: int = 0 # static variable for _on_aa_speed_overtime_timer()
func _on_aa_speed_overtime_timer() -> void:
	var attack_speed_overtime_current = remap(__aa_speed_overtime_ticks, \
			0, stats.auto_attack.attack_speed_overtime_duration, \
			stats.auto_attack.attack_speed_overtime_min, stats.auto_attack.attack_speed_overtime_max)
	stats.auto_attack.attack_speed_overtime_current = clampf(attack_speed_overtime_current, \
			stats.auto_attack.attack_speed_overtime_min, stats.auto_attack.attack_speed_overtime_max)
	_update_auto_attack_speed()
	__aa_speed_overtime_ticks += 1
