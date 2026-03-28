class_name ActionSenderSpellModule
extends ActionSenderModule

var _spawn_manager: SpawnManager

const METEOR_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Meteor/meteor.tscn")
const DARK_STORM_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/DarkStorm/dark_storm.tscn")
const CONTAGION_SPELL_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Poison/Contagion/contagion_spell_area.tscn")
const SHROOM_SPELL_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Poison/Shroom/shroom_spell.tscn")
const DEATH_FOG_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Poison/DeathFog/death_fog.tscn")
const LIGHTNING_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/Lightning/Lightning/spell_lightning.tscn")
const CHAIN_LIGHTNING_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/ChainLightning/spell_chain_lightning.tscn")

# ============================== Public functions ==============================

func connect_to_spawn_manager(spawn_manager: SpawnManager) -> void:
	if spawn_manager == null:
		Verbose.error("Trying to connect to a <null> SpawnManager", Verbose.Category.ENTITY_MODULE)
		return
	_spawn_manager = spawn_manager


func cast_spell(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary = {}) -> void:
	if _owner.status_module.has_status(Status.Type.STUN):
		return

	if _owner.status_module.has_status(Status.Type.SILENCE):
		Verbose.debug("Spell cast blocked by SILENCE on " + _owner.entity_name, Verbose.Category.ENTITY_MODULE)
		return

	var modifiers_data: Dictionary = _consume_before_action_modifiers(Utils.ActionCategory.SPELL, {
		ActionModifier.VarType.TARGET: target,
		ActionModifier.VarType.SPELL_TYPE: spell_type,
		ActionModifier.VarType.SPELL_MODIFIER: spell_modifier,
	})
	target = modifiers_data.get(ActionModifier.VarType.TARGET, target)
	spell_type = modifiers_data.get(ActionModifier.VarType.SPELL_TYPE, spell_type)
	spell_modifier = modifiers_data.get(ActionModifier.VarType.SPELL_MODIFIER, spell_modifier)

	match spell_type:
		Spell.Type.METEOR: _cast_meteor(target, spell_modifier)
		Spell.Type.DARK_STORM: _cast_dark_storm(target, spell_modifier)
		Spell.Type.CONTAGION: _cast_contagion(spell_modifier)
		Spell.Type.SHROOM: _cast_shroom(target, spell_modifier)
		Spell.Type.DEATH_FOG: _cast_death_fog(spell_modifier)
		Spell.Type.LIGHTNING: _cast_lightning(target, spell_modifier)
		Spell.Type.CHAIN_LIGHTNING: _cast_chain_lightning(target, spell_modifier)
		_: Verbose.error("Unknown spell type [" + str(spell_type) + "]", Verbose.Category.ENTITY_MODULE)

	_consume_after_action_modifiers(Utils.ActionCategory.SPELL, {
		ActionModifier.VarType.TARGET: target,
		ActionModifier.VarType.SPELL_TYPE: spell_type,
		ActionModifier.VarType.SPELL_MODIFIER: spell_modifier,
	})


# ============================== Private functions ==============================

func _cast_meteor(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null:
		Verbose.error("_cast_meteor() -> No target", Verbose.Category.ENTITY_MODULE)
		return
	var on_cast_callbacks: Array = spell_modifier.get(Spell.MeteorModifier.ON_CAST_CALLBACKS, [])
	for cb: Callable in on_cast_callbacks:
		if cb.is_valid():
			cb.call(spell_modifier)
	var meteor: Meteor = METEOR_SCENE.instantiate()
	var damage_percent: float = spell_modifier.get(Spell.MeteorModifier.DAMAGE_PERCENT, 0)
	var radius: float = spell_modifier.get(Spell.MeteorModifier.RADIUS, 1)
	var on_hit_callbacks: Array = spell_modifier.get(Spell.MeteorModifier.ON_HIT_CALLBACKS, [])
	meteor.init(target, damage_percent, radius, on_hit_callbacks, _owner)
	_spawn_manager.spawn_spell(meteor)


func _cast_dark_storm(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null:
		Verbose.error("_cast_dark_storm() -> No target", Verbose.Category.ENTITY_MODULE)
		return
	var dark_storm: DarkStorm = DARK_STORM_SCENE.instantiate()
	var damage: int = spell_modifier[Spell.DarkStormModifier.DAMAGE]
	var period: float = spell_modifier[Spell.DarkStormModifier.PERIOD]
	var lifespan: float = spell_modifier[Spell.DarkStormModifier.LIFESPAN]
	var pain_stack_percent: float = spell_modifier[Spell.DarkStormModifier.PAIN_STACK_PERCENT]
	dark_storm.init(target, damage, period, lifespan, _owner, pain_stack_percent)
	_spawn_manager.spawn_spell(dark_storm)


func _cast_contagion(spell_modifier: Dictionary) -> void:
	var contagion: ContagionSpellArea = CONTAGION_SPELL_SCENE.instantiate()
	var radius: float = spell_modifier[Spell.ContagionModifier.RADIUS]
	var spread_percent: float = spell_modifier[Spell.ContagionModifier.SPREAD_PERCENT]
	contagion.init(_owner, radius, spread_percent)
	_spawn_manager.spawn_spell(contagion)


func _cast_shroom(target: Entity, spell_modifier: Dictionary) -> void:
	var shroom: Shroom = SHROOM_SPELL_SCENE.instantiate()
	var radius: float = spell_modifier[Spell.ShroomModifier.RADIUS]
	var life_time: float = spell_modifier[Spell.ShroomModifier.LIFE_TIME]
	var damage: int = spell_modifier[Spell.ShroomModifier.DAMAGE]
	shroom.init(_owner, target, damage, radius, life_time)
	_spawn_manager.spawn_spell(shroom)


func _cast_death_fog(spell_modifier: Dictionary) -> void:
	var death_fog: DeathFog = DEATH_FOG_SCENE.instantiate()
	var grow_speed: float = spell_modifier[Spell.DeathFogModifier.GROW_SPEED]
	var tick_period: float = spell_modifier[Spell.DeathFogModifier.TICK_PERIOD]
	var damage_multiplier: float = spell_modifier[Spell.DeathFogModifier.DAMAGE_MULTIPLIER]
	death_fog.init(_owner, grow_speed, tick_period, damage_multiplier)
	_spawn_manager.spawn_spell(death_fog)


func _cast_lightning(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null:
		Verbose.error("_cast_lightning() -> No target", Verbose.Category.ENTITY_MODULE)
		return
	var lightning: SpellLightning = LIGHTNING_SCENE.instantiate()
	var damage: float = spell_modifier[Spell.LightningModifier.DAMAGE]
	lightning.init(_owner, target, damage)
	_spawn_manager.spawn_spell(lightning)


func _cast_chain_lightning(target: Entity, spell_modifier: Dictionary) -> void:
	if target == null:
		Verbose.error("_cast_chain_lightning() -> No target", Verbose.Category.ENTITY_MODULE)
		return
	var chain_lightning: SpellChainLightning = CHAIN_LIGHTNING_SCENE.instantiate()
	chain_lightning.init(_owner, target, spell_modifier)
	_spawn_manager.spawn_spell(chain_lightning)
