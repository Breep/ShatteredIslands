class_name CardContext
extends RefCounted

## Context object passed to CardEffect.apply_card() — gives cards access to
## all registries they need without coupling directly to Hero internals.

var entity_owner: Entity

static func create(
		p_entity_owner: Entity,
) -> CardContext:
	var ctx := CardContext.new()
	ctx.entity_owner = p_entity_owner
	return ctx
