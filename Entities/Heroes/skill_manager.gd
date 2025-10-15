class_name SkillManager
extends Resource

# ============================== Signal ==============================

signal skill_unlocked(skill_type: Skill.SkillType)
signal skill_picked(skill_id: Skill.SkillID)

# ============================== Public variables ==============================

var skills_pending: Dictionary[Skill.SkillType, bool] = {
	Skill.SkillType.BRONZE: false,
	Skill.SkillType.SILVER: false,
	Skill.SkillType.GOLD: false
}
var skills_choosen: Dictionary[Skill.SkillType, Skill.SkillID]

# ============================== Private variables ==============================

var _player_owner: Player

# ============================== Public functions ==============================

func init(player: Player) -> void:
	if _player_owner != null:
		printerr("SkillManager: Already init [", _player_owner.name, "]")
		return
	
	_player_owner = player
	_check_skills(player.lvl)
	Events.ui_skill_picked.connect(_on_ui_skill_picked)

# ============================== Private functions ==============================

func _check_skills(lvl: int) -> void:
	if lvl >= GameManager.game_rules.bronze_skill_unlock_lvl:
		if not skills_choosen.has(Skill.SkillType.BRONZE) and not skills_pending.has(Skill.SkillType.BRONZE):
			skill_unlocked.emit(Skill.SkillType.BRONZE)
			skills_pending[Skill.SkillType.BRONZE] = true
	if lvl >= GameManager.game_rules.silver_skill_unlock_lvl:
		if not skills_choosen.has(Skill.SkillType.SILVER) and not skills_pending.has(Skill.SkillType.SILVER):
			skill_unlocked.emit(Skill.SkillType.SILVER)
			skills_pending[Skill.SkillType.SILVER] = true
	if lvl >= GameManager.game_rules.gold_skill_unlock_lvl:
		if not skills_choosen.has(Skill.SkillType.GOLD) and not skills_pending.has(Skill.SkillType.GOLD):
			skill_unlocked.emit(Skill.SkillType.GOLD)
			skills_pending[Skill.SkillType.GOLD] = true

# ============================== Callback ==============================

func _on_player_owner_lvl_changed(_player_ref: Player, lvl: int) -> void:
	_check_skills(lvl)


func _on_ui_skill_picked(skill_id: Skill.SkillID) -> void:
	var skill_type: Skill.SkillType
	if skill_id == Skill.SkillID.BRONZE1 or skill_id == Skill.SkillID.BRONZE2:
		skill_type = Skill.SkillType.BRONZE
	if skill_id == Skill.SkillID.SILVER1 or skill_id == Skill.SkillID.SILVER2:
		skill_type = Skill.SkillType.SILVER
	if skill_id == Skill.SkillID.GOLD1 or skill_id == Skill.SkillID.GOLD2:
		skill_type = Skill.SkillType.GOLD
	if skills_pending[skill_type] == false:
		printerr("SkillManager: Can't pick this skill")
		return
	skills_choosen[skill_type] = skill_id
	skills_pending[skill_type] = false
	skill_picked.emit(skill_id)
