class_name FamilyArdentCelestialStats
extends FamilyStats

# Shared meteor modifier callbacks — cards append, ArdentCelestialManager reads when casting meteors
var meteor_modifiers: Array[Callable] = []

# [TITANS PROTECTION] cumulative HP increase tracking (reset by ArdentCelestialManager on stop)
var titans_protection_accumulated_hp: float = 0.0

# [METEOR] Family passive configuration — set by the Meteor card, defaults used by passive
var meteor_damage_percent: float = 5.0
var meteor_radius: float = 3.0
