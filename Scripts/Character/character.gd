extends StaticBody2D
class_name Character

# ============================== Signals ==============================

signal death(deadPlayer)

# ============================== Export variables ==============================

@export var team: int
@export var hero: Hero

# ============================== Public variables ==============================

var player: Player
var stats: CharacterStats # Needs to be public for easier upgrades access

# ============================== Private variables ==============================

@onready var damage_popup_node = preload("res://Scenes/Character/damage_pop_up.tscn")
var _aa_projectile = load("res://Scenes/Prefabs/projectile.tscn")
var _fighting_area: FightingArea
var _characters: Array[Character]
var _enemies: Array[Character]
var _allies: Array[Character]
var _is_dead: bool = false
var _is_player_character: bool = false

# ============================== Local scene nodes ==============================

@onready var _aa_timer: Timer = $Timers/AutoAttackTimer
@onready var _character_visual: CharacterVisual = $CharacterVisual
@onready var _multiplayerSynchroniser: MultiplayerSynchronizer = %MultiplayerSynchronizer

# ============================== Node base functions ==============================

func _ready() -> void:
	_fighting_area = get_tree().get_root().find_child("FightingArea", true, false)
	stats = hero.stats.duplicate(true) # Copy all hero base stats into a new stat resource
	_character_visual.update_health_bar(stats.health, hero.stats.health)
	_multiplayerSynchroniser.set_multiplayer_authority(player.id)
	_is_player_character = _multiplayerSynchroniser.get_multiplayer_authority() == multiplayer.get_unique_id()
	_character_visual.update_name_displayed(player.name)
	
	#connect to all death signals
	for character in _characters:
		character.death.connect(_on_death)
	
	_apply_all_cards_upgrades()

# ============================== Public functions ==============================

func hit_by_auto_attack(_src: Character, aaStats: AutoAttackProjectileStats):
	stats.health -= aaStats.damage
	damage_popup(aaStats.damage,1)
	_character_visual.update_health_bar(stats.health, hero.stats.health)
	if stats.health <= 0 and !_is_dead:
		death.emit(self)
		_is_dead = true


func damage_popup(amount: float, _modifier: int = 1):
	var popup = damage_popup_node.instantiate()
	var target_position = Vector2(randf_range(10,30), randf_range(10,-30)) 
	popup.text = str(amount)
	get_tree().current_scene.add_child(popup)
	popup.global_position = global_position + target_position
	popup.z_index = 1
	#popup.position = position + Vector2(20,-20)
	#if modifier == 1:
	#ParticleFXSingleton.add_effect("poison", position)
	#popup.set("theme_override_colors/font_color", Color.AQUAMARINE)


func connect_all_players_spawned_signal(node: Node, signal_name: String) -> void:
	node.connect(signal_name, _on_all_players_spawned, CONNECT_ONE_SHOT)


# ============================== Private functions ==============================

func _move_to_cell(cell : Vector2):
	if _is_dead: return
	position = _fighting_area.get_global_cell_position(cell)


func _get_closest_enemy() -> Character:
	if _enemies.is_empty():
		return null
	
	var closestEnemy: Character = _enemies[0]
	for enemy in _enemies:
		if (enemy.position - position).length_squared() < (closestEnemy.position - position).length_squared():
			closestEnemy = enemy
	
	return closestEnemy


func _auto_attack(target: Character):
	if target == null: 
		print("[", multiplayer.get_unique_id(), "] noone to attack")
		return
	
	var projectile: Projectile = _aa_projectile.instantiate()
	projectile.set_stats_from_player_stats(stats)
	projectile.target = target
	projectile.source = self
	_fighting_area.add_child(projectile)
	projectile.global_position = $ProjectileSpawn.global_position
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
		if character.team != team:
			ret.append(character)
	
	return ret
 

func _apply_all_cards_upgrades() -> void:
	if player.deck == null:
		printerr("No deck on the player")
		return
	
	stats = hero.stats.duplicate(true) # Reset stats
	for card in player.deck.cardPile:
		card.player_upgrade.apply(self, card.lvl)
	
	_aa_timer.wait_time = 1.0 / stats.auto_attack.attack_speed_flat

# ============================== Signals callback ==============================

func _on_all_players_spawned() -> void:
	_characters = _get_all_scene_characters()
	_enemies = _get_enemies_from_characters()
	_allies = _get_allies_from_characters()

func _on_auto_attack_timer_timeout() -> void:
	if _is_dead:
		return
	
	_auto_attack(_get_closest_enemy())


func _on_moving_timer_timeout() -> void:
	if _is_dead or not _is_player_character:
		return
	
	if _fighting_area.is_selection_active:
		_move_to_cell(_fighting_area.selection_cell)


func _on_death(deadPlayer: Character):
	print("Oh no! ", deadPlayer.name, " is dead :(")
	_characters.erase(deadPlayer)
	_enemies.erase(deadPlayer)
	_allies.erase(deadPlayer)
