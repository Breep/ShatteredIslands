# Variante héros du SkillComponent : déposée dans la scène d'un héros, elle remplace
# le composant par défaut (cf. mécanisme d'override dans SkillComponent._enter_tree).
# Passif et ultime sont chargés d'emblée ; bronze/silver/gold ne sont PAS auto-chargés
# mais font l'objet d'un choix joueur (2 candidats par tier) quand le niveau les
# débloque. La compta déblocage/choix est portée par l'entité elle-même.
class_name HeroSkillComponent
extends SkillComponent

#region ============================== Signals ==============================
# Le déblocage d'un tier et le choix joueur passent par le bus Events
# (hero_skill_unlocked / hero_skill_chosen), cf. _request_pending_choices /
# _on_skill_selected. Pratique pour une fenêtre globale filtrée sur le héros local.
#endregion

#region ============================== Constants ==============================
# Les deux slots fins (SkillID) ouverts au choix pour chaque tier sélectionnable.
const _TIER_SLOTS: Dictionary = {
	Skill.Type.BRONZE: [Skill.SkillID.BRONZE1, Skill.SkillID.BRONZE2],
	Skill.Type.SILVER: [Skill.SkillID.SILVER1, Skill.SkillID.SILVER2],
	Skill.Type.GOLD:   [Skill.SkillID.GOLD1, Skill.SkillID.GOLD2],
}
#endregion

#region ============================== Private variables ==============================
var _pending: Dictionary[Skill.Type, bool] = {
	Skill.Type.BRONZE: false,
	Skill.Type.SILVER: false,
	Skill.Type.GOLD:   false,
}
var _chosen: Dictionary[Skill.Type, Skill.SkillID] = {}
# Tiers à choix dont l'effet a déjà été appliqué (garde d'idempotence : un tier
# peut être choisi avant ou après son déblocage par niveau, on applique une fois).
var _applied: Dictionary[Skill.Type, bool] = {}
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	# super._ready() calcule les déblocages par niveau, puis appelle _load_skills()
	# (override ci-dessous) et _apply_skills() — déjà branchés en dispatch virtuel.
	super._ready()
	unlocked_skills_changed.connect(_on_unlocked_skills_changed)
	Events.skill_selected.connect(_on_skill_selected)
	# Cas d'un héros apparu déjà au-dessus d'un palier : le signal a été émis dans
	# super._ready() avant la connexion ci-dessus, on rattrape ici.
	_request_pending_choices()
#endregion

#region ============================== Public functions ==============================
# Candidats proposables pour un tier (vide si tier non sélectionnable ou non héros).
func get_tier_candidates(skill_type: Skill.Type) -> Array[Skill]:
	var result: Array[Skill] = []
	var hero_desc: HeroDesc = _owner.entity_desc as HeroDesc
	if hero_desc == null: return result
	for id: Skill.SkillID in _TIER_SLOTS.get(skill_type, []):
		var skill: Skill = hero_desc.hero_skills.get(id)
		if skill != null:
			result.append(skill)
	return result


# True si le tier est débloqué (par niveau) mais pas encore choisi → l'UI doit
# proposer le choix (et le portrait faire clignoter les candidats).
func is_choice_pending(skill_type: Skill.Type) -> bool:
	if not _TIER_SLOTS.has(skill_type): return false
	return unlocked_skills.get(skill_type, false) and not _chosen.has(skill_type)


# Skill retenue pour un tier à choix (null tant que non choisi).
func get_chosen_skill(skill_type: Skill.Type) -> Skill:
	return roaster.get(skill_type) if _chosen.has(skill_type) else null


# Redemande l'ouverture de la fenêtre de choix pour un tier toujours en attente
# (ex : le joueur avait fermé l'UI sans choisir). Contourne le garde anti-réémission
# _pending utilisé par _request_pending_choices.
func request_choice(skill_type: Skill.Type) -> void:
	if is_choice_pending(skill_type):
		Events.signal_hero_skill_unlocked(self, skill_type)


# True si au moins un tier sélectionnable est débloqué mais pas encore choisi.
func has_pending_choice() -> bool:
	for skill_type: Skill.Type in _TIER_SLOTS:
		if is_choice_pending(skill_type):
			return true
	return false


# (Ré)ouvre la fenêtre de choix pour chaque tier encore en attente.
func request_pending_choices() -> void:
	for skill_type: Skill.Type in _TIER_SLOTS:
		request_choice(skill_type)
#endregion

#region ============================== Private functions ==============================
# Override : ne charge que passif + ultime depuis hero_skills. Les tiers à choix
# restent null dans le roaster jusqu'au pick joueur (la base tolère ces trous).
func _load_skills() -> void:
	var hero_desc: HeroDesc = _owner.entity_desc as HeroDesc
	if hero_desc == null:
		Verbose.warn("HeroSkillComponent sur une entité sans HeroDesc, fallback base", Verbose.Category.ENTITY_MODULE)
		super._load_skills()
		return
	roaster[Skill.Type.PASSIVE] = hero_desc.hero_skills.get(Skill.SkillID.PASSIVE)
	roaster[Skill.Type.ULTIMATE] = hero_desc.hero_skills.get(Skill.SkillID.ULTIMATE)
	_hydrate_chosen_from_entry(hero_desc)


# Recharge les tiers déjà tranchés (run en cours) : pré-remplit _chosen + roaster
# pour qu'ils soient appliqués par _apply_skills et ne soient pas re-proposés.
func _hydrate_chosen_from_entry(hero_desc: HeroDesc) -> void:
	if _owner.entry == null: return
	for skill_type: Skill.Type in _owner.entry.chosen_skills:
		var skill: Skill = hero_desc.hero_skills.get(_owner.entry.chosen_skills[skill_type])
		if skill == null: continue
		_chosen[skill_type] = skill.skill_id
		roaster[skill_type] = skill


func _request_pending_choices() -> void:
	for skill_type: Skill.Type in _TIER_SLOTS:
		if not unlocked_skills[skill_type]: continue
		if _chosen.has(skill_type): continue
		if _pending[skill_type]: continue
		_pending[skill_type] = true
		Events.signal_hero_skill_unlocked(self, skill_type)


# La skill choisie appartient-elle bien à CE héros (comparaison par ressource, pas
# par SkillID) ? Évite qu'un pick destiné à un autre héros soit capté ici.
func _owns(skill_type: Skill.Type, skill: Skill) -> bool:
	var hero_desc: HeroDesc = _owner.entity_desc as HeroDesc
	if hero_desc == null: return false
	for id: Skill.SkillID in _TIER_SLOTS.get(skill_type, []):
		if hero_desc.hero_skills.get(id) == skill:
			return true
	return false


func _type_of(skill_id: Skill.SkillID) -> Variant:
	for skill_type: Skill.Type in _TIER_SLOTS:
		if skill_id in _TIER_SLOTS[skill_type]:
			return skill_type
	return null


# Override : pour les tiers à choix, applique l'effet au plus une fois (garde
# _applied). Choix et déblocage par niveau peuvent arriver dans n'importe quel
# ordre — le premier moment où le tier est à la fois choisi (roaster rempli) et
# débloqué déclenche l'application ; les appels suivants sont absorbés.
func _apply_skill(skill_type: Skill.Type) -> void:
	if _TIER_SLOTS.has(skill_type):
		if _applied.get(skill_type, false): return
		if not unlocked_skills.get(skill_type, false): return
		if roaster.get(skill_type) == null: return
		_applied[skill_type] = true
	super._apply_skill(skill_type)
#endregion

#region ============================== Callbacks ==============================
func _on_unlocked_skills_changed() -> void:
	# Un tier déjà choisi (hydraté depuis l'entry) qui se débloque seulement
	# maintenant doit voir son effet appliqué ; _apply_skill est idempotent et
	# ne fait rien pour les tiers non encore choisis (roaster null).
	for skill_type: Skill.Type in _TIER_SLOTS:
		_apply_skill(skill_type)
	_request_pending_choices()


func _on_skill_selected(skill: Skill) -> void:
	if skill == null: return
	var skill_type: Variant = _type_of(skill.skill_id)
	if skill_type == null: return # passif/ultime : pas de choix
	if not _pending[skill_type]: return # pas de choix en attente sur ce tier
	if not _owns(skill_type, skill): return # pick d'un autre héros
	_pending[skill_type] = false
	_chosen[skill_type] = skill.skill_id
	if _owner.entry != null:
		_owner.entry.chosen_skills[skill_type] = skill.skill_id
	roaster[skill_type] = skill
	_apply_skill(skill_type)
	Events.signal_hero_skill_chosen(self, skill.skill_id)
#endregion
