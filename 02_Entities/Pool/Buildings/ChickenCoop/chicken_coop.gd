class_name ChickenCoop
extends Entity

# Poulailler : bâtiment qui invoque des poulets. La logique d'invocation (niveau hérité,
# block à l'apparition) est centralisée dans summon_chicken() et pilotée par ses skills
# (Skills/) via meta. Les valeurs (période, block, nombre…) vivent dans les ressources.

# Meta posées par les talents pour moduler summon_chicken().
const META_SPAWN_BLOCK := &"coop_spawn_block"  # Talent "Couvée blindée"

@export var _spawn_distance: float = 2.0


## Invoque un poulet en appliquant les règles du poulailler. Appelé par le Passif
## (périodique), le Rush et l'Ultimate.
func summon_chicken() -> void:
	if summon == null:
		return
	var spawn_cfg := SpawnLocationConfig.create_entity_relative(self, _spawn_distance)
	for chicken: Entity in _summon_and_capture(spawn_cfg, {}):
		_apply_coop_rules(chicken)


# Capture le(s) poulet(s) spawné(s) pendant l'appel : SpawnManager.spawn_entity émet
# entity_spawned de façon synchrone, donc connect → summon → disconnect les isole.
func _summon_and_capture(spawn_cfg: SpawnLocationConfig, mods: Dictionary) -> Array[Entity]:
	var spawned: Array[Entity] = []
	if _spawn_manager == null:
		summon.summon_entity(Entity.EntityType.CHICKEN, spawn_cfg, mods)
		return spawned
	var capture := func(entity: Entity) -> void: spawned.append(entity)
	_spawn_manager.entity_spawned.connect(capture)
	summon.summon_entity(Entity.EntityType.CHICKEN, spawn_cfg, mods)
	_spawn_manager.entity_spawned.disconnect(capture)
	return spawned


func _apply_coop_rules(chicken: Entity) -> void:
	if not is_instance_valid(chicken) or not (chicken is Chicken):
		return
	# "Production continue" (poulets au niveau du poulailler) est désormais géré
	# par l'héritage de niveau de la chaîne summon (Entity._apply_inherited_summon_modifiers),
	# qui ancre le niveau de base du poulet sur le poulailler et y ajoute les bonus de chaîne.
	# Talent "Couvée blindée" : block à l'apparition.
	var block: float = get_meta(META_SPAWN_BLOCK, 0.0)
	if block > 0.0:
		self.alterations.direct_stack(chicken, block, Alteration.Type.BLOCK, &"Couvée blindée")
