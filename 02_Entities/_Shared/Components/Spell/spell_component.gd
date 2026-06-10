class_name SpellComponent
extends EntityComponent

var _spawn_manager: SpawnManager

const DARK_STORM_SCENE: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/DarkStorm/dark_storm.tscn")
const CONTAGION_SPELL_SCENE: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/Poison/Contagion/contagion_spell_area.tscn")
const SHROOM_SPELL_SCENE: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/Poison/Shroom/shroom_spell.tscn")
const DEATH_FOG_SCENE: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/Poison/DeathFog/death_fog.tscn")
const LIGHTNING_SCENE: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/Lightning/Lightning/spell_lightning.tscn")
const CHAIN_LIGHTNING_SCENE: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/ChainLightning/spell_chain_lightning.tscn")
const CLEAVE_SCENE: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/Cleave/spell_cleave.tscn")
const GOBLIN_FOCUS_SCENE: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/GoblinFocus/spell_goblin_focus.tscn")
const CLEARING_OF_LIFE: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/ClearingOfLife/spell_clearing_of_life.tscn")
const FIRE_GROUND_SCENE: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/FireGround/fire_ground.tscn")

func _enter_tree() -> void:
	if _owner == null: return
	if _owner.spell != null and _owner.spell != self:
		Verbose.trace("Override: SpellComponent on [" + _owner.entity_name + "]", Verbose.Category.ENTITY_MODULE)
		_owner.spell.queue_free()
	_owner.spell = self


func _ready() -> void:
	super._ready()
	if _owner == null or _owner.spell != self:
		return

# ============================== Public functions ==============================

func connect_to_spawn_manager(spawn_manager: SpawnManager) -> void:
	if spawn_manager == null:
		Verbose.error("Trying to connect to a <null> SpawnManager", Verbose.Category.ENTITY_MODULE)
		return
	_spawn_manager = spawn_manager


func cast_spell(target: Entity, spell_type: Spell.Type, spell_modifier: Dictionary = {}) -> void:
	if _owner.alterations.has_timed(Alteration.Type.STUN):
		return

	if _owner.alterations.has_timed(Alteration.Type.SILENCE):
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
		Spell.Type.DARK_STORM: _cast_dark_storm(target, spell_modifier)
		Spell.Type.CONTAGION: _cast_contagion(spell_modifier)
		Spell.Type.SHROOM: _cast_shroom(target, spell_modifier)
		Spell.Type.DEATH_FOG: _cast_death_fog(spell_modifier)
		Spell.Type.LIGHTNING: _cast_lightning(target, spell_modifier)
		Spell.Type.CHAIN_LIGHTNING: _cast_chain_lightning(target, spell_modifier)
		Spell.Type.CLEAVE: _cast_cleave(spell_modifier)
		Spell.Type.GOBLIN_FOCUS: _cast_goblin_focus(target, spell_modifier)
		Spell.Type.CLEARING_OF_LIFE: _cast_clearing_of_life(spell_modifier)
		Spell.Type.FIRE_GROUND: _cast_fire_ground(spell_modifier)
		_: Verbose.error("Unknown spell type [" + str(spell_type) + "]", Verbose.Category.ENTITY_MODULE)

	_consume_after_action_modifiers(Utils.ActionCategory.SPELL, {
		ActionModifier.VarType.TARGET: target,
		ActionModifier.VarType.SPELL_TYPE: spell_type,
		ActionModifier.VarType.SPELL_MODIFIER: spell_modifier,
	})

	_owner.spell_casted.emit(target, spell_type, spell_modifier)


# ============================== Private functions ==============================

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


func _cast_cleave(spell_modifier: Dictionary) -> void:
	var cleave: Cleave = CLEAVE_SCENE.instantiate()
	cleave.init(_owner, spell_modifier)
	_spawn_manager.spawn_spell(cleave)


func _cast_goblin_focus(target_: Entity, spell_modifier: Dictionary) -> void:
	if target_ == null:
		Verbose.error("_cast_goblin_focus() -> No target", Verbose.Category.ENTITY_MODULE)
		return
	var goblin_focus: GoblinFocus = GOBLIN_FOCUS_SCENE.instantiate()
	goblin_focus.init(_owner, spell_modifier, target_)
	_spawn_manager.spawn_spell(goblin_focus)

func _cast_clearing_of_life(spell_modifier: Dictionary) -> void:
	var clearing_of_life: ClearingOfLife = CLEARING_OF_LIFE.instantiate()
	clearing_of_life.init(_owner, spell_modifier)
	_spawn_manager.spawn_spell(clearing_of_life)


func _cast_fire_ground(spell_modifier: Dictionary) -> void:
	var fire_ground: FireGround = FIRE_GROUND_SCENE.instantiate()
	var pos: Vector3 = spell_modifier.get(Spell.FireGroundModifier.POSITION, _owner.global_position)
	var radius: float = spell_modifier.get(Spell.FireGroundModifier.RADIUS, 2.0)
	var duration: float = spell_modifier.get(Spell.FireGroundModifier.DURATION, 4.0)
	var ignite_per_tick: float = spell_modifier.get(Spell.FireGroundModifier.IGNITE_PER_TICK, 5.0)
	var tick_period: float = spell_modifier.get(Spell.FireGroundModifier.TICK_PERIOD, 1.0)
	fire_ground.init(_owner, pos, radius, duration, ignite_per_tick, tick_period)
	_spawn_manager.spawn_spell(fire_ground)
