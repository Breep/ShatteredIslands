extends Node

const HEROES: Dictionary [Hero.HeroType, Hero] = {
	Hero.HeroType.ANCIENT_TREE: preload("res://Resources/Heroes/ancient_tree.tres"),
	Hero.HeroType.CYBORG: preload("res://Resources/Heroes/cyborg.tres"),
	Hero.HeroType.DR_BOOM: preload("res://Resources/Heroes/dr_boom.tres"),
	Hero.HeroType.ENERGY_MAN: preload("res://Resources/Heroes/energy_man.tres"),
	Hero.HeroType.LAURENT_KROFT: preload("res://Resources/Heroes/laurent_kroft.tres"),
	Hero.HeroType.MR_KRUMB: preload("res://Resources/Heroes/mr_krumb.tres"),
	Hero.HeroType.SIR_REGINALD: preload("res://Resources/Heroes/sir_reginald.tres"),
	Hero.HeroType.TONY_LE_BARDE: preload("res://Resources/Heroes/tony_le_barde.tres")
}

const PROJECTILES = {
	Projectile.ProjectileType.AA_ANCIENT_TREE: preload("res://Scenes/Heroes/AncientTree/projectile.tscn"),
	Projectile.ProjectileType.AA_CYBORG: preload("res://Scenes/Heroes/Cyborg/projectile.tscn"),
	Projectile.ProjectileType.AA_DR_BOOM: preload("res://Scenes/Heroes/DrBoom/projectile.tscn"),
	Projectile.ProjectileType.AA_ENERGY_MAN: preload("res://Scenes/Heroes/EnergyMan/projectile.tscn"),
	Projectile.ProjectileType.AA_LAURENT_KROFT: preload("res://Scenes/Heroes/LaurentKroft/projectile.tscn"),
	Projectile.ProjectileType.AA_MR_KRUMB: preload("res://Scenes/Heroes/MrKrumb/projectile.tscn"),
	Projectile.ProjectileType.AA_SIR_REGINALD: preload("res://Scenes/Heroes/SirReginald/projectile.tscn"),
	Projectile.ProjectileType.AA_TONY_LE_BARDE: preload("res://Scenes/Heroes/TonyLeBarde/projectile.tscn"),
	Projectile.ProjectileType.SPELL_FIRBOLT: preload("res://Scenes/SpellsAndProjectiles/default_projectile.tscn"),
	Projectile.ProjectileType.SPELL_SHADOW_BOLT: preload("res://Scenes/SpellsAndProjectiles/default_projectile.tscn")
}

#[Server only]
var _is_ready: bool = false
signal _heroes_choosen()

# [Client only] Is emit when server has answered the local client request
signal _server_answered()

var _random_heroes_ref: Array[Hero.HeroType]

func get_n_random_heroes(heroes_number: int) -> Array[Hero]:
	if multiplayer.is_server():
		_init_current_current_game_heroes(heroes_number)
	else:
		_ask_get_n_random_heroes.rpc_id(1, multiplayer.get_unique_id(), heroes_number)
		await _server_answered
	
	var random_heroes: Array[Hero]
	for hero_ref in _random_heroes_ref:
		random_heroes.append(HEROES[hero_ref])
	
	return random_heroes

# ============================== RPC - Ask/Answer current round battle ==============================

@rpc("any_peer", "call_remote")
func _ask_get_n_random_heroes(peer_id: int, heroes_number: int) -> void:
	if not multiplayer.is_server():
		printerr("Only server should be asked for random heroes")
		return
	
	if not _is_ready:
		await _heroes_choosen
	
	_answer_get_n_random_heroes.rpc_id(peer_id, _random_heroes_ref)


@rpc("authority", "call_remote")
func _answer_get_n_random_heroes(heroes_ref: Array[Hero.HeroType]) -> void:
	_random_heroes_ref = heroes_ref
	_server_answered.emit()
	pass

# ============================== Private functions ==============================

func _init_current_current_game_heroes(heroes_number: int) -> void:
	if heroes_number <= 0 or heroes_number > HEROES.size():
		printerr("Hero: Wrong heroes_number: ", heroes_number)
		return
	
	var heroes_ref: Array[Hero.HeroType]
	for hero_ref in HEROES.keys():
		heroes_ref.append(hero_ref)
	
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in heroes_number:
		var random_index: int = rng.randi_range(0, heroes_ref.size() - 1)
		_random_heroes_ref.append(heroes_ref.get(random_index))
		heroes_ref.remove_at(random_index)
	
	_heroes_choosen.emit()
	_is_ready = true






















 
