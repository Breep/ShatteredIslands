class_name FamilyArdentCelestialStats
extends FamilyStats

# Shared meteor modifier callbacks — cards append, ArdentCelestialManager reads when casting meteors
var meteor_on_hit_callbacks: Array[Callable] = []
var meteor_on_cast_callbacks: Array[Callable] = []

# [TITANS PROTECTION] cumulative HP increase tracking (reset by ArdentCelestialManager on stop)
var titans_protection_accumulated_hp: float = 0.0

# [METEOR] Family passive configuration — set by the Meteor card, defaults used by passive
var meteor_damage_percent: Array[float] = [0, 0.5, 0.7, 0.9, 1.2]
var meteor_radius: float = 3.0
var meteor_chance: Array[float] = [0, 2, 4.5, 7, 10]

var end_of_the_world_bonus_meteor_chance: float = 0
var apocalypse_bonus_meteor_chance: float = 0
