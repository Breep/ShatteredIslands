class_name DarkKnight
extends Hero3D

func cast_ultimate() -> void:
	var target = _character_owner.target_module.get_target(TargetModule.TargettingStrategy.CLOSEST_ENEMY)
	if target == null:
		return
	var spell_modifier: Dictionary = {
		Spell.DarkStormModifier.DAMAGE: 10,
		Spell.DarkStormModifier.PERIOD: 0.2,
		Spell.DarkStormModifier.LIFESPAN: 1
	}
	_character_owner.cast_spell(target, Spell.Type.DARK_STORM, spell_modifier)
