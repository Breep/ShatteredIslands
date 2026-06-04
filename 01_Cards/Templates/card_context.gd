class_name CardContext
extends RefCounted

## Context object passed to CardEffect.apply() / revert() — donne aux cartes
## l'accès au porteur de la carte. Tout le reste de l'entité (registres,
## composants) est accessible via `entity_owner`.
##
## `roaster` est posé depuis entity_owner.roaster : non-null quand le porteur
## est un héros (seul cas où une carte peut muter le roaster de son joueur),
## null sinon. Les CardEffect qui mutent le roaster doivent gérer le cas null
## (warn et skip), pas crasher.

var entity_owner: Entity
var roaster: Roaster

static func create(
		p_entity_owner: Entity,
) -> CardContext:
	var ctx := CardContext.new()
	ctx.entity_owner = p_entity_owner
	ctx.roaster = p_entity_owner.roaster if p_entity_owner != null else null
	return ctx
