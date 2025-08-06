extends Node

# ActionModule TODO ActionModule and InteractModule whould be able to interact without this, bnut it's still usefull for stats and log
signal damage_done(source, target, damage, damage_type, is_critical)
func signal_damage_done(source: Entity, target: Entity, damage: int, damage_type, is_critical) -> void:
	damage_done.emit(source, target, damage, damage_type, is_critical)

signal heal_done(source, target, heal_amount)
func signal_heal_done(source, target, heal_amount) -> void:
	heal_done.emit(source, target, heal_amount)

signal condition_stacks_done(source, target, stacks_number, stack_type)
func signal_condition_stacks_done(source, target, stacks_number, stack_type) -> void:
	condition_stacks_done.emit(source, target, stacks_number, stack_type)



signal game_state_changed(new_game_state: Game.GameState)
func signal_game_state_changed(new_game_state: Game.GameState) -> void:
	game_state_changed.emit(new_game_state)



signal fighting_island_spawned(fighting_island_ref: FightingIsland, player_id: int)
func signal_fighting_island_spawned(fighting_island_ref: FightingIsland, player_id: int) -> void:
	fighting_island_spawned.emit(fighting_island_ref, player_id)

signal player_won_a_fight(player: Player)
func signal_player_won_a_fight(player: Player) -> void:
	player_won_a_fight.emit(player)



signal entity_cliked(entity: Entity)
func signal_clickable_cliked(clickable: Node3D) -> void:
	if clickable is Entity:
		entity_cliked.emit(clickable)

signal nothing_clicked()
func signal_nothing_clicked() -> void:
	nothing_clicked.emit()
