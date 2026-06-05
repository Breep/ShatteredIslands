# Classe de base de tous les modifiers (Stat, Action, AutoAttack, Summon, Death).
# Porte l'identité commune (id, tags) et l'enum de provenance (TagType).
class_name Modifier
extends Resource

enum TagType {
	CARD,
	SKILL,
	QUEST,
	EVENT,
	FAMILY
}

var id: StringName
var tags: Array[TagType]
