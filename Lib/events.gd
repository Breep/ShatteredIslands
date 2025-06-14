extends Node

# ActionModule TODO REMOVE
signal damage_done(source, target, damage, damage_type, is_critical)
signal heal_done(source, target, heal_amount)
signal condition_stacks_done(source, target, stacks_number, stack_type)

signal game_state_changed(new_game_state: Game.GameState)

signal fighting_island_spawned(fighting_island_ref: FightingIsland, player_id: int)

func change_game_state(game_state: Game.GameState) -> void:
	game_state_changed.emit(game_state)
