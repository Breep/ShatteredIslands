# Modifier hérité par les summons via la chaîne d'invocation. Stocké sur
# l'entité invocatrice (héros, acolyte, building, summon) et collecté par
# chaque nouveau summon en remontant ses summoners.
class_name SummonModifier
extends Modifier

var auto_attack_modifier: AutoAttackModifier
var action_modifier: ActionModifier
var stat_modifier: StatModifier
