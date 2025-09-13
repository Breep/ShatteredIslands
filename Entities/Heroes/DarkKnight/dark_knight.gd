class_name DarkKnight
extends Hero3D

func cast_ultimate() -> void:
	var target = _character_owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null:
		return
	var spell_modifier: Dictionary = {
		Spell.DarkStormModifier.DAMAGE: _character_owner.stats.attack_damage * 0.5,
		Spell.DarkStormModifier.PERIOD: 0.2,
		Spell.DarkStormModifier.LIFESPAN: 2.4
	}
	_character_owner.cast_spell(target, Spell.Type.DARK_STORM, spell_modifier)
