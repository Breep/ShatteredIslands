# Latika — DPS distance / carry mono-cible élevée par une meute de loups.
# Dualité de build : prédateur solitaire (sniper mobile) ou chef de meute
# (pression coordonnée via loups acolytes et marquage de cible).
@tool
class_name Latika
extends Hero

#region ============================== Signals ==============================
signal mark_target_changed(new_target: Entity)
signal wolves_count_changed(alive: int, total: int)
#endregion

#region ============================== Export - Skills constants ==============================
@export_group("Passive - Ultimate")
@export_subgroup("Passive - Chef de Meute")
@export var _initial_wolf_count: int = 1
@export var _focus_mark_damage_percent: float = 20.0

@export_subgroup("Ultimate - Flèche du Prédateur")
@export var _predator_arrow_damage: float = 50.0
@export var _predator_arrow_applies_on_hit: bool = true

@export_group("Level 3 Skills")
@export_subgroup("Skill Bronze 1 - Œil du Faucon")
@export var _hawk_eye_activated: bool = false:
	set(value):
		_hawk_eye_activated = value
		_refresh_skill_visuals()
@export_subgroup("Skill Bronze 1 - Œil du Faucon/Paramètres")
@export var _hawk_eye_range_bonus: float = 3.0
@export var _hawk_eye_distance_threshold: float = 6.0
@export var _hawk_eye_far_damage_percent: float = 30.0
@export_subgroup("Skill Bronze 1 - Œil du Faucon/Visuel")
@export var _hawk_eye_goggles_node: Node3D

@export_subgroup("Skill Bronze 2 - Traque Sauvage")
@export var _wild_tracking_activated: bool = false:
	set(value):
		_wild_tracking_activated = value
		_refresh_skill_visuals()
@export_subgroup("Skill Bronze 2 - Traque Sauvage/Paramètres")
@export var _wild_tracking_wolf_hp_percent: float = 25.0
@export var _wild_tracking_wolf_ms_bonus: float = 1.5
@export_subgroup("Skill Bronze 2 - Traque Sauvage/Visuel")
@export var _wild_tracking_wolf_eye_patch_node: Node3D

@export_group("Level 5 Skills")
@export_subgroup("Skill Silver 1 - Réflexe Bestial")
@export var _beast_reflex_activated: bool = false:
	set(value):
		_beast_reflex_activated = value
		_refresh_skill_visuals()
@export_subgroup("Skill Silver 1 - Réflexe Bestial/Paramètres")
@export var _beast_reflex_hp_threshold_percent: float = 50.0
@export var _beast_reflex_heal_amount: float = 1000.0
@export var _beast_reflex_dash_distance: float = 4.0
@export var _beast_reflex_untargetable_duration: float = 2.0
@export_subgroup("Skill Silver 1 - Réflexe Bestial/Visuel")
@export var _beast_reflex_node: Node3D

@export_subgroup("Skill Silver 2 - Furie de la Meute")
@export var _pack_fury_activated: bool = false:
	set(value):
		_pack_fury_activated = value
		_refresh_skill_visuals()
@export_subgroup("Skill Silver 2 - Furie de la Meute/Paramètres")
@export var _pack_fury_ad_per_ally: float = 5.0
@export_subgroup("Skill Silver 2 - Furie de la Meute/Visuel")
@export var _pack_fury_node: Node3D

@export_group("Level 7 Skills")
@export var _hair: Node3D
@export_subgroup("Skill Gold 1 - Loup Solitaire")
@export var _lone_wolf_activated: bool = false:
	set(value):
		_lone_wolf_activated = value
		_refresh_skill_visuals()
@export_subgroup("Skill Gold 1 - Loup Solitaire/Paramètres")
@export var _lone_wolf_damage_percent: float = 25.0
@export var _lone_wolf_crit_percent: float = 20.0
@export var _lone_wolf_range_bonus: float = 2.0
@export var _lone_wolf_isolation_radius: float = 3.0
@export_subgroup("Skill Gold 1 - Loup Solitaire/Visuel")
@export var _lone_wolf_helmet: Node3D
@export var _lone_wolf_shoulder: Node3D
@export var _lone_wolf_bow_visual: Node3D

@export_subgroup("Skill Gold 2 - Lien du Sang")
@export var _blood_bond_activated: bool = false:
	set(value):
		_blood_bond_activated = value
		_refresh_skill_visuals()
@export_subgroup("Skill Gold 2 - Lien du Sang/Paramètres")
@export var _blood_bond_extra_wolves: int = 2
@export var _blood_bond_global_as_percent: float = 20.0
@export var _blood_bond_rage_damage_percent: float = 25.0
@export_subgroup("Skill Gold 2 - Lien du Sang/Visuel")
@export var _blood_bond_node: Node3D

@export_group("Weapons")
@export var _bow: Node3D
@export var _normal_bow_visual: Node3D
#endregion

#region ============================== Private variables ==============================
var _marked_target: Entity = null
var _beast_reflex_used: bool = false
#endregion

#region ============================== Constants ==============================
# TODO: const PREDATOR_ARROW_VFX_SCENE: PackedScene = preload("res://...")
# TODO: const MARK_VFX_SCENE: PackedScene = preload("res://...")
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	if Engine.is_editor_hint():
		_refresh_skill_visuals()
		return

	auto_attack_completed.connect(_on_auto_attack_completed)

	if _skill_manager != null:
		_skill_manager.skill_picked.connect(_on_skill_manager_skill_picked)

	# TODO: spawn initial wolf companion (Chef de Meute) — requires Wolf summon

	super._ready()
	_refresh_skill_visuals()


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	super._enter_tree()


func _init() -> void:
	if Engine.is_editor_hint():
		return
	super._init()
#endregion

#region ============================== Public functions ==============================
func cast_ultimate() -> void:
	# TODO: cast Spell.Type.PREDATOR_ARROW once added to Spell enum + SpellComponent.
	# Behavior: pierces all enemies in a straight line, deals _predator_arrow_damage
	# physical damage, and applies AA on-hit effects if _predator_arrow_applies_on_hit.
	#var spell_modifier: Dictionary = {
		#Spell.PredatorArrowModifier.DAMAGE: _predator_arrow_damage,
		#Spell.PredatorArrowModifier.APPLIES_ON_HIT: _predator_arrow_applies_on_hit,
	#}
	#var aim_target: Entity = target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	#if aim_target == null: return
	#spell.cast_spell(aim_target, Spell.Type.PREDATOR_ARROW, spell_modifier)
	ultimate_casted.emit()
#endregion

#region ============================== Private functions ==============================
func _refresh_skill_visuals() -> void:
	if not is_inside_tree(): return

	if _hawk_eye_goggles_node != null:
		_hawk_eye_goggles_node.visible = _hawk_eye_activated

	if _wild_tracking_wolf_eye_patch_node != null:
		_wild_tracking_wolf_eye_patch_node.visible = _wild_tracking_activated

	if _beast_reflex_node != null:
		_beast_reflex_node.visible = _beast_reflex_activated

	if _pack_fury_node != null:
		_pack_fury_node.visible = _pack_fury_activated

	if _lone_wolf_helmet != null:
		_lone_wolf_helmet.visible = _lone_wolf_activated
	if _lone_wolf_shoulder != null:
		_lone_wolf_shoulder.visible = _lone_wolf_activated
	if _lone_wolf_bow_visual != null:
		_lone_wolf_bow_visual.visible = _lone_wolf_activated
	if _normal_bow_visual != null:
		_normal_bow_visual.visible = !_lone_wolf_activated

	if _hair != null:
		_hair.visible = !(_lone_wolf_activated or _blood_bond_activated)

	if _blood_bond_node != null:
		_blood_bond_node.visible = _blood_bond_activated


func _register_hawk_eye() -> void:
	return
	# TODO: register a permanent StatModifier(ATTACK_RANGE, +_hawk_eye_range_bonus)
	# and an AutoAttackModifier that adds +_hawk_eye_far_damage_percent% damage when
	# distance(self, target) > _hawk_eye_distance_threshold.


func _register_wild_tracking() -> void:
	return
	# TODO: hook into the SUMMON action pipeline (ActionModifier on summon spawn) to
	# inject +_wild_tracking_wolf_hp_percent% HP and +_wild_tracking_wolf_ms_bonus MS
	# on every wolf summoned by Latika.


func _register_beast_reflex() -> void:
	return
	# TODO: connect to health_changed; when self.stats.health drops below
	# _beast_reflex_hp_threshold_percent% of HEALTH_MAX and _beast_reflex_used == false,
	# heal _beast_reflex_heal_amount, movement.rush() backwards by _beast_reflex_dash_distance,
	# apply UntargetableAlteration for _beast_reflex_untargetable_duration sec, then
	# set _beast_reflex_used = true. Reset on fight start.


func _register_pack_fury() -> void:
	return
	# TODO: on fight start, count alive allies and push a StatModifier(AD,
	# _pack_fury_ad_per_ally * ally_count) to every ally entity (including self?).


func _register_lone_wolf() -> void:
	return
	# TODO: periodic check (or proximity callback) — if no ally is within
	# _lone_wolf_isolation_radius m, register conditional StatModifiers:
	# +_lone_wolf_damage_percent% AD, +_lone_wolf_crit_percent% CRIT_CHANCE,
	# +_lone_wolf_range_bonus ATTACK_RANGE. Remove modifiers when an ally enters range.


func _register_blood_bond() -> void:
	return
	# TODO: spawn _blood_bond_extra_wolves additional wolves (Sköll, Hati). Register a
	# BattleCallback: while all 3 wolves alive, +_blood_bond_global_as_percent% AS to all
	# allied entities; on wolf death, give +_blood_bond_rage_damage_percent% damage to
	# surviving wolves.
#endregion

#region ============================== Callbacks ==============================
func _on_auto_attack_completed(_entity: Entity) -> void:
	# TODO: Synergie de focus — mark the current AA target so allies deal
	# +_focus_mark_damage_percent% damage to it. Open question: reuse
	# VulnerabilityAlteration (no ally-only filter) vs new MarkAlteration (clean
	# semantic). Decide before implementing.
	#var current_target: Entity = target.get_target(TargetComponent.TargettingStrategy.CURRENT)
	#if current_target == _marked_target: return
	#_marked_target = current_target
	#mark_target_changed.emit(_marked_target)
	pass


func _on_skill_manager_skill_picked(skill_id: Skill.SkillID) -> void:
	match skill_id:
		Skill.SkillID.BRONZE1:
			_hawk_eye_activated = true
			_register_hawk_eye()
		Skill.SkillID.BRONZE2:
			_wild_tracking_activated = true
			_register_wild_tracking()
		Skill.SkillID.SILVER1:
			_beast_reflex_activated = true
			_register_beast_reflex()
		Skill.SkillID.SILVER2:
			_pack_fury_activated = true
			_register_pack_fury()
		Skill.SkillID.GOLD1:
			_lone_wolf_activated = true
			_register_lone_wolf()
		Skill.SkillID.GOLD2:
			_blood_bond_activated = true
			_register_blood_bond()
#endregion
