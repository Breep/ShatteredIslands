class_name SpellChainLightning
extends Node3D

const VISUAL_SCENE = preload("res://SpellsAndProjectiles/Spells/ChainLightning/Visual/spell_chain_lightning_visual.tscn")
const HEIGHT_OFFSET: Vector3 = Vector3(0, 1.0, 0)
const MODIFIER_START_POS = "start_position"
const BOUNCE_DELAY: float = 0.2 
const LIFETIME_MAX: float = 5.0

var _source: Entity
var _current_target: Entity
var _damage: float
var _bounces_remaining: int
var _bounce_range: float
var _damage_decay: float = 0.0
var _custom_start_pos = null

func init(source: Entity, target: Entity, modifiers: Dictionary) -> void:
	_source = source
	_current_target = target
	_damage = modifiers.get(Spell.ChainLightningModifier.DAMAGE, 10.0)
	_bounces_remaining = int(modifiers.get(Spell.ChainLightningModifier.BOUNCE_COUNT, 3))
	_bounce_range = modifiers.get(Spell.ChainLightningModifier.BOUNCE_RANGE, 5.0)
	_damage_decay = modifiers.get(Spell.ChainLightningModifier.DAMAGE_DECAY_PERCENT, 0.0)
	if modifiers.has(MODIFIER_START_POS):
		_custom_start_pos = modifiers[MODIFIER_START_POS]

func _ready() -> void:
	var start_pos: Vector3 = Vector3.ZERO
	if _custom_start_pos != null:
		start_pos = _custom_start_pos
	elif _source != null:
		start_pos = _source.global_position
	if _current_target != null:
		_spawn_beam_effect(start_pos + HEIGHT_OFFSET, _current_target.global_position + HEIGHT_OFFSET)
		_process_zap(_current_target)
	else:
		queue_free()
	get_tree().create_timer(LIFETIME_MAX).timeout.connect(queue_free)

func _process_zap(target: Entity) -> void:
	if target == null or not is_instance_valid(target) or target.is_dead:
		queue_free()
		return
	
	# Dégâts
	if _source != null:
		_source.direct_attack(target, _damage, Utils.DamageType.MAGICAL, "Chain Lightning")
	else:
		target.take_damage(_damage, Utils.DamageType.MAGICAL, false, "Chain Lightning")
	
	# Rebond
	if _bounces_remaining > 0:
		_bounces_remaining -= 1
		if _damage_decay > 0: _damage -= (_damage * _damage_decay / 100.0)
		
		var next_target = _find_next_target(target)
		
		if next_target != null:
			_spawn_beam_effect(target.global_position + HEIGHT_OFFSET, next_target.global_position + HEIGHT_OFFSET)	
			await get_tree().create_timer(BOUNCE_DELAY).timeout
			_process_zap(next_target)
		else:
			queue_free()
	else:
		queue_free()

func _find_next_target(current_pos_entity: Entity) -> Entity:
	if _source == null: return null
	var enemies = _source.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
	var possible_targets: Array[Entity] = []
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_dead and enemy != current_pos_entity:
			var dist_sq = current_pos_entity.global_position.distance_squared_to(enemy.global_position)
			if dist_sq <= (_bounce_range * _bounce_range):
				possible_targets.append(enemy)
	if possible_targets.size() > 0:
		return possible_targets.pick_random()
	return null

func _spawn_beam_effect(pos_a: Vector3, pos_b: Vector3) -> void:
	if VISUAL_SCENE:
		var beam_visual = VISUAL_SCENE.instantiate()
		get_tree().current_scene.add_child(beam_visual)
		beam_visual.fire(pos_a, pos_b)
		if beam_visual.has_method("fire"):
			beam_visual.fire(pos_a, pos_b)
