class_name CharacterShadowStats
extends Resource

var untargetable: bool # Tru if the target is untargetable (with the card In The Shadow)

var shadow_bolt_activated: bool # If this skill is activated
var shadow_bolt_damage: int # Damage of the shadow bolt
var shadow_bolt_distance: float # Distance needed to trigger shadow bolt (in m)

var increase_aa_damage_activated: bool # If this skill is activated
var increase_aa_damage_value: int # Value of increased damage
var increase_aa_damage_distance: float # Distance needed to trigger increase_aa_damage (in m)

var gain_armor_stacks_activated: bool # If this skill is activated
var gain_armor_stacks_value: int # Stacks of armor gained
var gain_armor_stacks_distance: float # Distance needed to trigger gain_armor_stacks (in m)

var heal_ally_activated: bool # If this skill is activated
var heal_ally_value: int # Value of heal done to ally
var heal_ally_distance: float # Distance needed to trigger heal_ally (in m)

var gain_max_hp_activated: bool # If this skill is activated
var gain_max_hp_value: int # Amount of hp gained
var gain_max_hp_distance: float # Distance needed to trigger gain_max_hp (in m)

var inflict_poison_stacks_activated: bool # If this skill is activated
var inflict_poison_stacks_value: int # Stacks of poison inflicted
var inflict_poison_stacks_distance: float # Distance needed to trigger inflict_poison_stacks (in m)

var untargetable_activated: bool # If the skill is activated
var untargetable_time: float # Duration of untargetable when moving
var untargetable_distance: float # Distance needed to trigger untargetable

var shadow_step_activated: bool # If the epic is activated
var shadow_step_period: float # Period of time between 2 shadow steps
