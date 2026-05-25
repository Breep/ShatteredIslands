class_name GoblinBerserker
extends Entity

@export_group("Passive - Ultimate")
@export_subgroup("Passive - XX")


@export_subgroup("Ultimate - Cleave")
@export var _cleave_damage_self_ad_percent: float = 200.0
@export var _cleave_damage_target_hpmax_percent: float = 10.0
@export var _cleave_size: bool = true

#@export_group("Level 3 Skills")
#@export_subgroup("Skill Bronze - XX")
#@export var _hawk_eye_activated: bool = false
#@export_subgroup("Skill Bronze 1 - XX / Paramètres")
#@export var _hawk_eye_range_bonus: float = 3.0
#@export var _hawk_eye_distance_threshold: float = 6.0
#@export var _hawk_eye_far_damage_percent: float = 30.0

@export_group("Level 5 Skills")
@export_subgroup("Skill Silver - Rage")
@export var _rage_activated: bool = false
@export_subgroup("Skill Silver 1 - Rage/Paramètres")
@export var _rage_hp_threshold_percent: float = 50.0
@export var _rage_force_flat: float = 25


@export_group("Level 7 Skills")
@export_subgroup("Skill Gold 1 - Big Game Hunter")
@export var _big_game_hunter_activated: bool = false
@export_subgroup("Skill Gold 1 - Big Game Hunter/Paramètres")
@export var _big_game_hunter_attack_number: int = 3
@export var _big_game_hunter_hpmax_percent: float = 5

var _aa_count: int = 1
var _rage_triggred: bool = false

func _ready() -> void:
	auto_attack.attack_completed.connect(_on_auto_attack_completed)
	super._ready()


func _on_stats_health_changed(new_health: float) -> void:
	super._on_stats_health_changed(new_health)
	if not _rage_activated or _rage_triggred: return
	if stats.health < stats.health_max * _rage_hp_threshold_percent / 100.0:
		_visual_3d.scale = Vector3(2, 2, 2)
		alterations.inflict_condition_stacks(self, _rage_force_flat, Alteration.Type.STRENGTH, &"Rage")
		_rage_triggred = true


func _on_auto_attack_completed() -> void:
	if not _big_game_hunter_activated: return
	_aa_count += 1
	if _aa_count % _big_game_hunter_attack_number != 0: return
	var mod := AutoAttackModifier.new()
	mod.id = &"BigGameHunter"
	mod.is_one_time_effect = true
	mod.damage_modifier_callback = func(cb_vars: Dictionary) -> void:
		var target_: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET) # TODO changer target component
		if not is_instance_valid(target_): return
		var damage_inc: float = target_.stats.health_max * _big_game_hunter_hpmax_percent / 100.0
		if cb_vars.has(AutoAttackModifier.VarType.DAMAGE_ADD):
			cb_vars[AutoAttackModifier.VarType.DAMAGE_ADD] += damage_inc
		else:
			cb_vars[AutoAttackModifier.VarType.DAMAGE_ADD] = damage_inc
		AudioManager.play_3d("thud", target.position)
	auto_attack_modifier_registry.register_modifier(mod)


func cast_ultimate() -> void:
	super.cast_ultimate()
	spell.cast_spell(self, Spell.Type.CLEAVE, {
		Cleave.Modifier.AD: _cleave_damage_self_ad_percent,
		Cleave.Modifier.HPMAX: _cleave_damage_target_hpmax_percent
	})
