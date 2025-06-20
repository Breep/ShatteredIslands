class_name Character
extends Entity

# ============================== Editor-only tools ==============================

const _HEROES_3D: Dictionary[Hero.HeroId, PackedScene] = {
	Hero.HeroId.UNDEF: preload("res://Entities/Heroes/_Undef/undef.tscn"),
	Hero.HeroId.ANCIENT_TREE: preload("res://Entities/Heroes/AncientTree/ancient_tree.tscn"),
	Hero.HeroId.CYBORG: preload("res://Entities/Heroes/Cyborg/cyborg.tscn"),
	Hero.HeroId.DR_BOOM: preload("res://Entities/Heroes/DrBoom/dr_boom.tscn"),
	Hero.HeroId.LAURENT_KROFT: preload("res://Entities/Heroes/LaurentKroft/laurent_kroft.tscn"),
	Hero.HeroId.MR_KRUMB: preload("res://Entities/Heroes/MrKrumb/mr_krumb.tscn"),
	Hero.HeroId.SIR_REGINALD: preload("res://Entities/Heroes/SirReginald/sir_reginald.tscn"),
	Hero.HeroId.TONY_LE_BARDE: preload("res://Entities/Heroes/TonyLeBarde/tony_le_barde.tscn"),
	Hero.HeroId.RHINO: preload("res://Entities/Heroes/Rhino/rhino.tscn"),
	Hero.HeroId.DARK_KNIGHT: preload("res://Entities/Heroes/DarkKnight/dark_knight.tscn"),
	Hero.HeroId.ROCKY: preload("res://Entities/Heroes/Rocky/rocky.tscn")
}

# ============================== Signal ==============================

signal fight_is_won()
#signal fight_is_lost()

# ============================== Fighting State ==============================

signal fighting_state_changed(new_fighting_state: GlobalFightingManager.FightingState)
var fighting_state: GlobalFightingManager.FightingState:
	get: return _fighting_state
	set(value):
		if value != _fighting_state:
			_fighting_state = value
			fighting_state_changed.emit(_fighting_state)

# ============================== Export ==============================

@export_group("Network")
@export_subgroup("Variables")
@export var owner_player_id: int # ID of the player owner of this character
var _hero_id := Hero.HeroId.UNDEF
@export var hero_id: Hero.HeroId: # ID of the hero this character represent
	get: return _hero_id
	set(value):
		if value == _hero_id or value < 0: return
		_hero_id = value
		if Engine.is_editor_hint(): _update_hero()

@export_subgroup("Synchronizer")
@export var _movement_synchronizer: MultiplayerSynchronizer

@export_group("Local Nodes")
@export var _character_visual: CharacterVisual
@export var _character_logic: CharacterLogic
@export var _turret: Turret
@export var _hero_3D: Hero3D
@export var _collision_shape: CollisionShape3D
@export var _interact_module: InteractModule
@export var families_stats: FamiliesStats

# ============================== Public variables ==============================

var player: Player
var target_module: TargetModule

# ============================== Private variables ==============================

var _is_dead: bool = false
var _is_local: bool = false

var _fighting_state: GlobalFightingManager.FightingState = GlobalFightingManager.FightingState.UNDEF

# ============================== Public functions ==============================

func apply_cards_upgrade(deck: PlayerDeck) -> void:
	if not is_node_ready(): return
	stats.reset_from_hero(_hero_3D.hero)
	for card in deck.card_pile:
		card.player_upgrade.apply(families_stats, card.lvl)


func connect_to_fighting_area(fighting_area: FightingArea) -> void:
	_reset()
	_character_logic.connect_to_fighting_area(fighting_area)
	fighting_area.fighting_manager.fight_is_over.connect(_on_fighting_manager_fight_is_over, CONNECT_ONE_SHOT)


func set_lookat_camera(camera: Camera3D) -> void:
	_character_visual.set_camera(camera)


func on_active_island() -> void: # TODO Should be a signal no ?
	_character_visual.show()


func on_inactive_island() -> void:
	_character_visual.hide()


func get_auto_attack_spawn() -> Node3D:
	return _turret.get_projectile_spawn_point()


# ===== Actions

# ===== Interaction

func take_damage(damage: int, damage_type: Utils.DamageType, is_critical: bool, source: Entity = null) -> void:
	_interact_module.take_damage(damage, damage_type, is_critical, source)

func take_condition_stacks(stacks_number: int, stack_type: Utils.StackType, source: Character = null) -> void:
	_interact_module.take_condition_stacks(stacks_number, stack_type, source)

func take_heal(heal_amount: int, source: Character = null) -> void:
	_interact_module.take_heal(heal_amount, source)

# ============================== Node base functions ==============================

func _init() -> void:
	if Engine.is_editor_hint(): return
	_entity_init()


func _ready() -> void:
	if Engine.is_editor_hint(): return
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
	Events.player_won_a_fight.connect(_on_events_player_won_a_fight)
	
	_update_hero()
	if player != null: apply_cards_upgrade(player.deck)
	
	stats.health_changed.connect(_on_stats_health_changed)

# ============================== Private functions ==============================

func _reset() -> void:
	stats.reset_from_hero(_hero_3D.hero)


func _update_hero() -> void:
	if not Engine.is_editor_hint() and not is_inside_tree(): return
	if not Engine.is_editor_hint() and not is_node_ready(): return
	if _hero_3D != null: _hero_3D.queue_free()
	_hero_3D = _HEROES_3D[hero_id].instantiate()
	print("Character change hero to: ", _hero_3D.hero.name)
	_hero_3D.character_owner = self
	_collision_shape.shape = _hero_3D.collision_shape.shape.duplicate() # Update Collider
	var hero_height: float = (_collision_shape.shape as CapsuleShape3D).height
	_character_visual.position.y = hero_height + 1
	add_child(_hero_3D)

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

func _on_fighting_manager_fight_is_over(_fighting_manager, _winner_team) -> void:
	_character_logic.stop()


func _on_global_fighting_manager_state_changed(global_fighting_state: GlobalFightingManager.FightingState) -> void:
	fighting_state = global_fighting_state
	if global_fighting_state == GlobalFightingManager.FightingState.POSITIONING:
		if not player.is_bot:
			_movement_synchronizer.set_multiplayer_authority(player.id)
			set_multiplayer_authority(player.id)
		else:
			_movement_synchronizer.set_multiplayer_authority(1)
			set_multiplayer_authority(1)
	if global_fighting_state == GlobalFightingManager.FightingState.COUNTDOWN:
		_movement_synchronizer.set_multiplayer_authority(-1)
		set_multiplayer_authority(-1)


func _on_events_game_state_changed(new_state: Game.GameState) -> void:
	match new_state:
		Game.GameState.BUYING:
			_character_visual.hide()
			if _turret != null: _turret.hide()
		Game.GameState.FIGHTING:
			_character_visual.show()
			if _turret != null: _turret.show()


func _on_stats_health_changed(new_health: int) -> void:
	if _character_visual != null: _character_visual.update_health_bar(new_health, stats.health_max)
	if new_health <= 0:
		print("DEBUG | ", name, " | DEAD")
		signal_death()


func _on_events_player_won_a_fight(winner: Player) -> void:
	if winner == player:
		fight_is_won.emit()






 
