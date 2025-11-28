class_name SpellChainLightning
extends Node3D

const MODIFIER_START_POS = "start_position"

# Temps entre deux rebonds
const BOUNCE_DELAY: float = 0.1 
const LIFETIME_MAX: float = 5.0

var _source: Entity
var _current_target: Entity
var _damage: float
var _bounces_remaining: int
var _bounce_range: float
var _damage_decay: float = 10

var _hit_history: Array[Entity] = []
var _custom_start_pos = null # Pour stocker la position de départ force

# [VISUAL] Récupération du Mesh dans ta scène
@onready var _beam_template: MeshInstance3D = %LightningBeam

# ============================== Init ==============================

func init(source: Entity, target: Entity, modifiers: Dictionary) -> void:
	_source = source
	_current_target = target
	
	_damage = modifiers.get(Spell.ChainLightningModifier.DAMAGE, 10.0)
	_bounces_remaining = int(modifiers.get(Spell.ChainLightningModifier.BOUNCE_COUNT, 3))
	_bounce_range = modifiers.get(Spell.ChainLightningModifier.BOUNCE_RANGE, 5.0)
	_damage_decay = modifiers.get(Spell.ChainLightningModifier.DAMAGE_DECAY_PERCENT, 0.0)
	if modifiers.has(MODIFIER_START_POS):
		_custom_start_pos = modifiers[MODIFIER_START_POS]
# ============================== Logic ==============================

func _ready() -> void:
	print("DEBUG: Spell Instancié !") # 5. Le sort est-il créé ?
	# [VISUAL] On cache le modèle original, on ne s'en sert que pour le dupliquer
	
	if _beam_template == null:
		print("ERREUR CRITIQUE: _beam_template est NULL ! Vérifie le %LightningBeam")
		
	if _beam_template:
		_beam_template.visible = false
		
	var start_pos: Vector3 = Vector3.ZERO
	if _custom_start_pos != null:
		start_pos = _custom_start_pos
	elif _source != null:
		start_pos = _source.global_position
		
	# On lance l'éclair initial
	if _current_target != null:
		_spawn_visual_beam(start_pos, _current_target.global_position)

	_process_zap(_current_target)
	
	var tween_life := create_tween()
	tween_life.tween_interval(LIFETIME_MAX)
	tween_life.finished.connect(queue_free)


func _process_zap(target: Entity) -> void:
	if target == null or not is_instance_valid(target) or target.is_dead:
		_finish()
		return
	
	_hit_history.append(target)
	
	# Le nœud se place sur la cible actuelle
	global_position = target.global_position
	
	# Dégâts
	if _source != null:
		_source.direct_attack(target, _damage, Utils.DamageType.MAGICAL, "Chain Lightning")
	else:
		target.take_damage(_damage, Utils.DamageType.MAGICAL, false, "Chain Lightning")
	
	# Gestion du rebond
	if _bounces_remaining > 0:
		_bounces_remaining -= 1
		
		if _damage_decay > 0:
			_damage -= (_damage * _damage_decay / 100.0)
		
		var next_target = _find_next_target(target)
		
		if next_target != null:
			# [VISUAL] C'est ici qu'on crée l'éclair entre A et B
			_spawn_visual_beam(target.global_position, next_target.global_position)
			
			await get_tree().create_timer(BOUNCE_DELAY).timeout
			_process_zap(next_target)
		else:
			_finish()
	else:
		_finish()


# [VISUAL] Fonction pour créer l'éclair
func _spawn_visual_beam(from_pos: Vector3, to_pos: Vector3) -> void:
	if _beam_template == null: return
	
	# 1. On duplique le modèle
	var beam = _beam_template.duplicate()
	get_tree().current_scene.add_child(beam) # On l'ajoute à la scène principale pour qu'il soit indépendant
	beam.visible = true
	
	# 2. Positionnement au centre
	var mid_point = (from_pos + to_pos) / 2.0
	beam.global_position = mid_point
	
	# 3. Orientation (LookAt)
	# On regarde vers la destination. Le UP vector assure qu'on ne se retourne pas bizarrement.
	if not from_pos.is_equal_approx(to_pos):
		beam.look_at(to_pos, Vector3.UP)
	
	# 4. Étirement (Scale)
	var distance = from_pos.distance_to(to_pos)
	beam.scale.z = distance # On suppose que ton Mesh est orienté sur Z
	
	# 5. Animation de disparition
	var tween = beam.create_tween()
	# L'éclair s'affine et disparaît
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(beam, "scale:x", 0.0, 1) # Devient tout fin
	tween.parallel().tween_property(beam, "scale:y", 0.0, 1)
	tween.parallel().tween_property(beam, "transparency", 1.0, 1) # Devient transparent (si le matériau le permet)
	
	tween.finished.connect(beam.queue_free)


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


func _finish() -> void:
	queue_free()
