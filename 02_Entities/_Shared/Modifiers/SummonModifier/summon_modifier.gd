class_name SummonModifier
extends Resource

enum TagType {
	CARD,
	HERO,
	QUEST,
	EVENT,
	FAMILY
}

var id: StringName
var tags: Array[TagType]

var auto_attack_modifier: AutoAttackModifier
var action_modifier: ActionModifier
var stat_modifier: StatModifier
