class_name SkillComponent
extends EntityComponent

signal unlocked_skills_changed()

const SKILL_UNLOCK_LEVEL: Dictionary[Skill.Type, int] = {
	Skill.Type.PASSIVE:  1,
	Skill.Type.BRONZE:   3,
	Skill.Type.SILVER:   5,
	Skill.Type.GOLD:     7,
	Skill.Type.ULTIMATE: 1,
}

var unlocked_skills: Dictionary[Skill.Type, bool] = {
	Skill.Type.PASSIVE:  false,
	Skill.Type.BRONZE:   false,
	Skill.Type.SILVER:   false,
	Skill.Type.GOLD:     false,
	Skill.Type.ULTIMATE: false,
}

var roaster: Dictionary[Skill.Type, Skill] = {
	Skill.Type.PASSIVE:  null,
	Skill.Type.BRONZE:   null,
	Skill.Type.SILVER:   null,
	Skill.Type.GOLD:     null,
	Skill.Type.ULTIMATE: null,
}

var _skill_context: SkillContext

func _enter_tree() -> void:
	if _owner == null: return
	if _owner.skill != null and _owner.skill != self:
		Verbose.trace("Override: SkillComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.skill.queue_free()
	_owner.skill = self


func _ready() -> void:
	super._ready()
	_skill_context = SkillContext.create(_owner)
	_owner.progression.level_changed.connect(_on_owner_progression_level_changed)
	_update_unlocked_skills(_owner.progression.level)
	_load_skills()
	_apply_skills()


func cast_ultimate() -> void:
	if not unlocked_skills[Skill.Type.ULTIMATE]:
		Verbose.debug("Trying to cast ultimate but is not unlocked", Verbose.Category.ENTITY_MODULE)
		return
	var ultimate: Skill = roaster.get(Skill.Type.ULTIMATE)
	if ultimate == null:
		Verbose.debug("No ultimate skill loaded", Verbose.Category.ENTITY_MODULE)
		return
	ultimate.skill_effect.apply(_skill_context)
	_owner.ultimate_casted.emit()


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


func _load_skills() -> void:
	if _owner.entity_desc == null:
		Verbose.warn("No entity_desc: can't load skills", Verbose.Category.ENTITY_MODULE)
		return
	
	for skill_type: Skill.Type in roaster:
		if not _owner.entity_desc.skills.has(skill_type):
			Verbose.warn("Skill not found in entity_desc [" + str(Skill.Type.keys()[skill_type]) + "]", Verbose.Category.ENTITY_MODULE)
			return
		roaster[skill_type] = _owner.entity_desc.skills[skill_type]


func _apply_skills() -> void:
	for skill_type: Skill.Type in roaster:
		if skill_type == Skill.Type.ULTIMATE: continue
		if unlocked_skills[skill_type] == false: continue
		if roaster.get(skill_type) == null: continue
		roaster[skill_type].skill_effect.apply(_skill_context)
 
