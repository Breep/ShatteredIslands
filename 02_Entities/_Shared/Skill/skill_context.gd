class_name SkillContext
extends Resource

var entity: Entity

static func create(p_entity: Entity) -> SkillContext:
	var ctx:= SkillContext.new()
	ctx.entity = p_entity
	return ctx
