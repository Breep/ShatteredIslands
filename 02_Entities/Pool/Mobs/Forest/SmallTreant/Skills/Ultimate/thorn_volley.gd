class_name SE_ThornVolley
extends SkillEffect

## Ultimate "Salve épineuse": inflige (_damage_per_thorn_percent % × stacks de Thorn)
## en PHYSICAL_DAMAGE et applique Stun aux ennemis adjacents, puis gagne des stacks
## de Thorn supplémentaires.

@export var _damage_per_thorn_percent: float = 150.0
@export var _stun_duration: float = 2.0
@export var _radius: float = 3.0
@export var _thorn_gain_on_cast: float = 15.0


func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity

	var thorn: float = _owner.alterations.get_stacks(Alteration.Type.THORN)
	var damage: float = thorn * _damage_per_thorn_percent / 100.0

	var enemies: Array[Entity] = _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES, _radius)
	for enemy in enemies:
		if not is_instance_valid(enemy): continue
		if damage > 0:
			_owner.damage.direct(enemy, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"Thorn Volley")
		_owner.alterations.inflict_status(enemy, Alteration.Type.STUN, _stun_duration, &"Thorn Volley")

	if _thorn_gain_on_cast > 0:
		_owner.alterations.add_stack(Alteration.Type.THORN, _thorn_gain_on_cast)
