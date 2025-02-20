extends Node

# Emitted when a character is spawned (or revived)
# who: Ref of the character
signal character_is_spawned(who: Character)


# Emitted when a character receive a critical damage
# source: Ref of the character who is the origin of the damage
# target: Ref of the character who is the victim of the critic
# source: Damage done
signal critical_damage_done(source: Character, target: Character, damage:int)


# ActionModule
signal damage_done(source, target, damage, damage_type, is_critical)
signal heal_done(source, target, heal_amount)
signal condition_stacks_done(source, target, stacks_number, stack_type, poison_duration)
