class_name Character
extends Entity

# ============================== Signal ==============================

signal fight_is_won()
signal fight_is_lost()

# ============================== Export variables (Network) ==============================

@export var owner_player_id: int # ID of the player owner of this character

# ============================== Fighting State ==============================

signal fighting_state_changed(new_fighting_state: GlobalFightingManager.FightingState)
var fighting_state: GlobalFightingManager.FightingState:
	get: return _fighting_state
	set(value):
		if value != _fighting_state:
			_fighting_state = value
			fighting_state_changed.emit(_fighting_state)

# ============================== Export ==============================

@export var _hero: Hero
@export var _is_prototype: bool # 

# ============================== Public variables ==============================

var player: Player
var stats: CharacterStats

var target_module: TargetModule

# ============================== Private variables ==============================

var _is_dead: bool = false
var _is_local: bool = false

var _fighting_state: GlobalFightingManager.FightingState = GlobalFightingManager.FightingState.UNDEF

# ============================== Local scene nodes ==============================

@onready var _character_visual: CharacterVisual = $CharacterVisual
@onready var _server_synchronizer: MultiplayerSynchronizer = %ServerSynchronizer

@export var _character_logic: CharacterLogic
@export var _turret: Turret

@export var _interact_module: InteractModule # TODO TMP

# ============================== Public functions ==============================

func apply_cards_upgrade(deck: PlayerDeck) -> void:
	stats.reset_stats(_hero.stats)
	for card in deck.card_pile:
		card.player_upgrade.apply(stats, card.lvl)


func connect_to_fighting_area(fighting_area: FightingArea) -> void:
	_reset()
	_character_logic.connect_to_fighting_area(fighting_area)
	fighting_area.fighting_manager.fight_is_over.connect(_on_fighting_manager_fight_is_over, CONNECT_ONE_SHOT)


func set_lookat_camera(camera: Camera3D) -> void:
	_character_visual.set_camera(camera)


func on_active_island() -> void:
	_character_visual.show()


func on_inactive_island() -> void:
	_character_visual.hide()

# ============================== Node base functions ==============================

func _init() -> void:
	stats = CharacterStats.new()
	stats.health_changed.connect(_on_stats_health_changed)
	_entity_init()


func _ready() -> void:
	printerr("Character is a virtual class and shouldn't be instantiated")


func _character_ready() -> void:
	stats.reset_stats(_hero.stats)
	target_module = _character_logic.target_module
	
	if owner_player_id != 0:
		player = PlayerManager.players[owner_player_id]
		player.character = self
		_is_local = player.id == multiplayer.get_unique_id()
	
	if battle_id == -1:
		_character_visual.hide()
		if _turret != null: _turret.hide()
	
	_character_visual.update_health_bar(stats.health, stats.health_max)
	_character_visual.update_mana_bar(stats.mana, stats.mana_max)
	_character_visual.update_name_displayed(player.name)
	
	GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)
	Events.game_state_changed.connect(_on_events_game_state_changed)
	
	#_interact_module.damage_taken.connect(_on_interact_module_damage_taken)
	#_interact_module.heal_received.connect(_on_interact_module_heal_received)
	
	#

# ============================== Private functions ==============================

func _reset() -> void:
	stats.reset_stats(_hero.stats)

# ============================== Private ==============================

func _handle_death() -> void:
	dead.emit(self)
	_is_dead = true

# ============================== Family callbacks ==============================

func _on_life_manager_revived(life_after_revived: int) -> void:
	stats.health = life_after_revived
	_character_visual.update_health_bar(stats.health, stats.health_max)
	_is_dead = false
	Events.character_is_spawned.emit(self)


func _on_shadow_manager_gain_max_hp_triggered(hp: int) -> void:
	stats.health_max += hp
	stats.health += hp
	_character_visual.update_health_bar(stats.health, stats.health_max)

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
	_character_logic.stop()


func _on_global_fighting_manager_state_changed(new_state: GlobalFightingManager.FightingState) -> void:
	fighting_state = new_state


func _on_events_game_state_changed(new_state: Game.GameState) -> void:
	match new_state:
		Game.GameState.BUYING:
			_character_visual.hide()
			if _turret != null: _turret.hide()
		Game.GameState.FIGHTING:
			if not player.is_bot: _server_synchronizer.set_multiplayer_authority(player.id)
			_character_visual.show()
			if _turret != null: _turret.show()


func _on_stats_health_changed(new_health: int) -> void:
	if _character_visual != null: _character_visual.update_health_bar(new_health, stats.health_max)
	if new_health <= 0:
		print("DEBUG | ", name, " | DEAD")
		dead.emit(self)









 
