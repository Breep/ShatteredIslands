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


# Crée une copie profonde de ce modifier. Override obligatoire par les sous-classes :
# Resource.duplicate() ne copie pas les `var` non-@export, donc on doit copier
# chaque champ explicitement. Utilisé par SummonModifiersRegistry.apply_to pour
# propager les modifiers sans partager d'instance avec le registry source.
func clone() -> Modifier:
	push_warning("[Modifier] virtual clone() called — sous-classe doit override")
	return null
