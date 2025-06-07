extends Node

# Emitted when a character receive a critical damage
# source: Ref of the character who is the origin of the damage
# target: Ref of the character who is the victim of the critic
# source: Damage done
signal critical_damage_done(source: Character, target: Character, damage:int)


# ActionModule
signal damage_done(source, target, damage, damage_type, is_critical)
signal heal_done(source, target, heal_amount)
signal condition_stacks_done(source, target, stacks_number, stack_type)


# UI related events
signal ui_card_shop_opened(is_opened: bool)
signal ui_buying_area_opened(is_opened: bool)
signal ui_fighting_area_opened(is_opened: bool, battle_id: int) # battle_id=-1 if want to act on all ui_fighting_area
signal ui_main_countdown_triggered(countdown_value: int, endword: String)

signal new_game_started(game_node: Game)

signal game_state_changed(new_game_state: Game.GameState)
