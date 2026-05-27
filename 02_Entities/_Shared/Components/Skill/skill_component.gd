class_name SkillComponent
extends EntityComponent

signal unlocked_skills_changed()

const SKILL_UNLOCK_LEVEL: Dictionary [Skill.Type, int] = {
	Skill.Type.PASSIVE:  1,
	Skill.Type.BRONZE:   3,
	Skill.Type.SILVER:   5,
	Skill.Type.GOLD:     7,
	Skill.Type.ULTIMATE: 1
}

var unlocked_skills: Dictionary [Skill.Type, bool] = {
	Skill.Type.PASSIVE:  false,
	Skill.Type.BRONZE:   false,
	Skill.Type.SILVER:   false,
	Skill.Type.GOLD:     false,
	Skill.Type.ULTIMATE: false
}


func _enter_tree() -> void:
	if _owner == null: return
	if _owner.skill != null and _owner.skill != self:
		Verbose.trace("Override: SkillComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.skill.queue_free()
	_owner.skill = self


func _ready() -> void:
	super._ready()
	_owner.progression.level_changed.connect(_on_owner_progression_level_changed)
	_update_unlocked_skills(_owner.progression.level)


func _on_owner_progression_level_changed(level: int) -> void:
	_update_unlocked_skills(level)


func _update_unlocked_skills(level: int) -> void:
	var has_changed: bool = false
	for skill_type: Skill.Type in unlocked_skills:
		var is_skill_active: bool = level >= SKILL_UNLOCK_LEVEL[skill_type]
		if unlocked_skills[skill_type] != is_skill_active:
			unlocked_skills[skill_type] = is_skill_active
			has_changed = true
	if has_changed:
		unlocked_skills_changed.emit()




 
