class_name SkillContext
extends Resource

var entity: Entity
var roaster: Roaster

static func create(
		p_entity_owner: Entity,
) -> SkillContext:
	var ctx := SkillContext.new()
	ctx.entity = p_entity_owner
	ctx.roaster = p_entity_owner.roaster if p_entity_owner != null else null
	return ctx
