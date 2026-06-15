class_name SE_PackLeader
extends SkillEffect

# Passif "Chef de Meute" — Synergie de focus : l'auto-attaque de Latika marque sa
# cible courante. La marque ajoute de l'EXPOSURE à l'ennemi visé ; comme seuls les
# alliés de Latika infligent des dégâts à un ennemi, cela revient à un bonus de
# dégâts alliés sur la cible focus. Mono-cible et suit le focus : la marque quitte
# l'ancienne cible dès que Latika en vise une nouvelle.
# La marque n'est PAS un effet on-hit (elle ne doit pas être rejouée par les capacités
# qui appliquent les effets on-hit de l'AA, ex: l'ultimate). On l'écoute donc via le
# signal action_done filtré sur l'auto-attaque, et non via un AutoAttackModifier.
# (Le loup acolyte de base est purement data : HeroDesc.starting_companions.)

const MARK_MODIFIER_ID := &"LatikaFocusMark"
const META_MARKED_TARGET := &"latika_marked_target"

## Exposure ajoutée à la cible marquée (≈ +X% dégâts subis avant résistance).
@export var _mark_exposure: float = 20.0

const _MARKED_ACTIONS: Array[Utils.ActionType] = [
	Utils.ActionType.DAMAGE_PHYSICAL,
	Utils.ActionType.DAMAGE_MAGICAL,
	Utils.ActionType.DAMAGE_POISON,
]


func apply(ctx: SkillContext) -> void:
	var latika: Entity = ctx.entity
	if latika == null:
		Verbose.error("SE_PackLeader: null owner", Verbose.Category.ENTITY_MODULE)
		return

	latika.action_done.connect(func(target: Entity, _action_type: Utils.ActionType, action_id: StringName, _value: float, _is_critical: bool) -> void:
		if action_id != &"auto_attack":
			return
		if not is_instance_valid(target):
			return
		_move_mark(latika, target))

	# Co-op : la mort de Latika n'est pas synonyme de défaite. On retire la marque
	# pour ne pas laisser un ennemi amplifié sans marqueuse en vie.
	latika.died.connect(func(_self_ref: Entity) -> void:
		var marked: Entity = latika.get_meta(META_MARKED_TARGET, null)
		if is_instance_valid(marked):
			_clear_mark(marked)
		latika.set_meta(META_MARKED_TARGET, null))


func get_description() -> String:
	return "Son auto-attaque marque sa cible : celle-ci subit +" + _value(_mark_exposure) \
		+ "% de dégâts. La marque suit son focus (une seule cible à la fois)."


# Déplace la marque de l'ancienne cible vers la nouvelle (no-op si identique).
func _move_mark(latika: Entity, new_target: Entity) -> void:
	var previous = latika.get_meta(META_MARKED_TARGET, null)
	if previous == new_target:
		return
	if is_instance_valid(previous):
		_clear_mark(previous)
	_apply_mark(new_target)
	latika.set_meta(META_MARKED_TARGET, new_target)


func _apply_mark(target: Entity) -> void:
	if not is_instance_valid(target) or target.stat_modifiers_registry == null:
		return
	for action_type: Utils.ActionType in _MARKED_ACTIONS:
		var modifier := StatModifier.new()
		modifier.id = MARK_MODIFIER_ID
		modifier.stat_type = EntityStats.StatType.M_EXPOSURE
		modifier.action_type = action_type
		modifier.value = _mark_exposure
		target.stat_modifiers_registry.register_modifier(modifier)


func _clear_mark(target: Entity) -> void:
	if not is_instance_valid(target) or target.stat_modifiers_registry == null:
		return
	for action_type: Utils.ActionType in _MARKED_ACTIONS:
		target.stat_modifiers_registry.remove_modifier(
			EntityStats.StatType.M_EXPOSURE, MARK_MODIFIER_ID, action_type)
