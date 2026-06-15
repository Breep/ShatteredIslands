## Latika — DPS distance / carry mono-cible élevée par une meute de loups.
## Dualité de build : prédateur solitaire (sniper mobile) ou chef de meute
## (pression coordonnée via loups acolytes et marquage de cible).
class_name Latika
extends Entity

func _ready() -> void:
	super._ready()
	progression.level_changed.connect(_progression_level_changed)
	_sync_wolf_level()


func _progression_level_changed(_unused) -> void:
	_sync_wolf_level()


func _sync_wolf_level() -> void:
	if roaster == null: return
	var roaster_entries: Array[RoasterEntry] = roaster.all_entries()
	for roaster_entry in roaster_entries:
		if _is_a_wolf_roaster_entry(roaster_entry):
			roaster_entry.level = progression.level
	for wolf: Entity in _scan_pack():
		wolf.progression.level = progression.level


func _is_a_wolf_roaster_entry(roaster_entry: RoasterEntry) -> bool:
	if roaster_entry.desc == null: return false
	return roaster_entry.desc.name == "Vrock" or \
			roaster_entry.desc.name == "Geri" or \
			roaster_entry.desc.name == "Freki"


func _is_a_wolf_entity(entity: Entity) -> bool:
	if not is_instance_valid(entity): return false
	return entity is Vrock and entity.summoner == self or \
			entity is Freki and entity.summoner == self or \
			entity is Geri and entity.summoner == self


func _scan_pack() -> Array[Entity]:
	var pack: Array[Entity] = []
	for ally: Entity in target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
		if _is_a_wolf_entity(ally):
			pack.append(ally)
	return pack
