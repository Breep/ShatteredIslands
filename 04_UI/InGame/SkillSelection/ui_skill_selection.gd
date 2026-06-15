# Fenêtre de choix de talent du héros LOCAL. Écoute le bus Events : quand un tier
# du héros local se débloque, elle s'ouvre en peuplant ses vignettes avec les
# candidats du tier ; le clic sur une vignette émet Events.skill_selected, le
# HeroSkillComponent tranche, et hero_skill_chosen referme la fenêtre. Plusieurs
# tiers débloqués d'un coup sont présentés un par un (file). Au retour en taverne,
# tout tier resté en attente est rouvert (cf. _on_tavern_phase_started).
class_name UISkillSelection
extends Control

#region ============================== Private variables ==============================
# File de {comp: HeroSkillComponent, type: Skill.Type} en attente de présentation.
var _queue: Array[Dictionary] = []
var _current_comp: HeroSkillComponent = null
#endregion

#region ============================== Onready ==============================
@onready var _windows: Array[UISkillWindow] = [%UiSkillWindow, %UiSkillWindow2]
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	hide()
	Events.hero_skill_unlocked.connect(_on_hero_skill_unlocked)
	Events.hero_skill_chosen.connect(_on_hero_skill_chosen)
	Events.tavern_phase_started.connect(_on_tavern_phase_started)
#endregion

#region ============================== Private functions ==============================
func _present_next() -> void:
	if _queue.is_empty():
		return
	var entry: Dictionary = _queue.pop_front()
	var comp: HeroSkillComponent = entry["comp"]
	var skill_type: Skill.Type = entry["type"]
	# Le tier a pu être tranché entre-temps (file) : on saute.
	if not is_instance_valid(comp) or not comp.is_choice_pending(skill_type):
		_present_next()
		return
	_current_comp = comp
	var candidates: Array[Skill] = comp.get_tier_candidates(skill_type)
	for i: int in _windows.size():
		if i < candidates.size():
			_windows[i].show()
			_windows[i].update(candidates[i])
		else:
			_windows[i].hide()
	show()


func _is_local_hero(comp: HeroSkillComponent) -> bool:
	var local_player: Player = PlayerManager.get_local_player()
	if local_player == null or not is_instance_valid(local_player.hero):
		return false
	return local_player.hero.skill == comp
#endregion

#region ============================== Callbacks ==============================
func _on_hero_skill_unlocked(comp: HeroSkillComponent, skill_type: Skill.Type) -> void:
	if not _is_local_hero(comp):
		return
	_queue.append({"comp": comp, "type": skill_type})
	if _current_comp == null:
		_present_next()


func _on_hero_skill_chosen(comp: HeroSkillComponent, _skill_id: Skill.SkillID) -> void:
	if comp != _current_comp:
		return
	_current_comp = null
	hide()
	_present_next()


# Au retour en taverne, on relance le choix de tout tier resté en attente.
func _on_tavern_phase_started() -> void:
	var local_player: Player = PlayerManager.get_local_player()
	if local_player == null or not is_instance_valid(local_player.hero):
		return
	var comp: HeroSkillComponent = local_player.hero.skill as HeroSkillComponent
	if comp != null:
		comp.request_pending_choices()
#endregion
