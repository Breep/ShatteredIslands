class_name FamilyAttackStats
extends FamilyStats

#region Common Card
# [PROTECTO'SPEAR]
var protectospear_activated: bool
var protectospear_chance: float
var protectospear_shield_amount: float

# [FIGHT BACK]
var fight_back_activated: bool # True if this skill is activated
var fight_back_increase_dodge: float # % dodge
var fight_back_increase_attack_damage: float # +AD

# [SCORCHING BLADE]
var scorching_blade_activated: bool # true if activated
var scorching_blade_damage_percent: float # Le % de dégâts convertis (ex: 10.0, 15.0, ...)0)

# [VENOMOUS STRIKE]
var rusty_dagger_activated: bool # true if activated
var rusty_dagger_chance: float # % chance to proc
var rusty_dagger_poison_stacks: float # amount stacks

# [DIAMOND SWORD]
var diamond_sword_activated: bool # True if this skill is activated
var diamond_sword_attack: int # Value of increased attack

# [ARCANE STAFF]
var arcane_staff_activated: bool
var arcane_staff_chance: float
var arcane_staff_mana_gain: float

# [TWIN BLADE]
var twin_blade_activated: bool # True if this skill is activated
var twin_blade_speed: float # Le pourcentage d'augmentation (ex: 10.0, 15.0) speed (in %)

# [TITAN AXE]
var titan_axe_activated: bool # True if this skill is activated
var titan_axe_attack_number: int # Number of attack needed to proc the skil
var titan_axe_damage_percent: float # % of target max hp damage buff

# [BLADE RUSH]
var blade_rush_activated: bool
var blade_rush_damage: float
var blade_rush_duration: float

# [HEALING CROSSBOW]
var healing_crossbow_activated: bool
var healing_crossbow_chance: float
var healing_crossbow_heal_amount: float


var double_edge_sword_activated: bool # True if this skill is activated

# [NECROTIC BULLET]
var necrotic_bullet_activated: bool
var necrotic_bullet_chance: float
var necrotic_bullet_necrosis_stacks: float
#endregion

#region Rare Card
# [SURGICAL KNIFE]
var surgical_knife_activated: bool # True if this skill is activated
var surgical_knife_chance: float # Chance to proc the curative knife
var surgical_knife_cleanse_amount: float # Number of negative stacks removed
#endregion

#region Epic Card
# [GATLING GUN]
var gatling_gun_activated: bool # True if this skill is activated
var gatling_gun_min: float # Min value of the attack speed increased overtime
var gatling_gun_max: float # Max value of the attack speed increased overtime
var gatling_gun_duration: float # Time needed to go from min to max attack speed increase

# [STORM HAMMER]
var storm_hammer_activated: bool # True if this skill is activated
var storm_hammer_chance: float # % of chance for an auto-attack to bounce
#endregion

#region Legendary Card
# [RUSSIAN ROULETTE]
var attack_russian_roulette_activated: bool
var attack_russian_roulette_min_percent: float
var attack_russian_roulette_max_percent: float

# [AIM ASSIST]
var attack_aim_assist_activated: bool
var attack_aim_assist_bonus_per_card: float
#endregion


# [DOUBLE EDGE SWORD]
var double_edge_sword_damage_percent: int # % of damage increased
var double_edge_sword_attacks_number: int # Number oof attacks boosted
