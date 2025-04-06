extends Node

# Emitted when a character is spawned (or revived)
# who: Ref of the character
signal entity_is_spawned(who: Entity)


# Emitted when a character receive a critical damage
# source: Ref of the character who is the origin of the damage
# target: Ref of the character who is the victim of the critic
# source: Damage done
signal critical_damage_done(source: Character, target: Character, damage:int)


# ActionModule
signal damage_done(source, target, damage, damage_type, is_critical)
signal heal_done(source, target, heal_amount)
signal condition_stacks_done(source, target, stacks_number, stack_type, poison_duration)


# UI related events
signal ui_card_shop_opened(is_opened: bool)
signal ui_buying_area_opened(is_opened: bool)
signal ui_fighting_area_opened(is_opened: bool, battle_id: int) # battle_id=-1 if want to act on all ui_fighting_area

# Hero related events
signal hero_interacted(hero_id: Hero.HeroId)
