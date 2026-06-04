class_name CardContext
extends RefCounted

## Context object passed to CardEffect.apply() / revert() — donne aux cartes
## l'accès au porteur de la carte. Tout le reste de l'entité (registres,
## composants) est accessible via `entity_owner`.

var entity_owner: Entity

static func create(
		p_entity_owner: Entity,
) -> CardContext:
	var ctx := CardContext.new()
	ctx.entity_owner = p_entity_owner
	return ctx
