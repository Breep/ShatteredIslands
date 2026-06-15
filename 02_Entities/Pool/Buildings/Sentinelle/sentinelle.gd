class_name Sentinelle
extends Entity

# Bâtiment de soutien. Émet un "Rayon protecteur" (beams) qui donne du Shield aux alliés les
# plus proches. Toute la logique de jeu vit dans ses skills (Skills/) ; ce script ne gère que
# le visuel des beams (réutilisés du Fortification Drone) — un faisceau par allié protégé.

const BEAM_SCENE: PackedScene = preload("res://02_Entities/Pool/Mobs/FortificationDrone/Visual/fortification_drone_beam.tscn")

var _beams: Array[FortificationDroneBeam] = []
var _beam_targets: Array[Entity] = []


func process_tick() -> void:
	super.process_tick()
	_update_beams()


## Appelé par les skills à chaque pulse : oriente un faisceau vers chacun des alliés protégés
## et les fait clignoter.
func flash_beams_to(allies: Array[Entity]) -> void:
	_beam_targets = allies
	for i: int in _beam_targets.size():
		_get_or_create_beam(i).blink()


func _get_or_create_beam(index: int) -> FortificationDroneBeam:
	while _beams.size() <= index:
		var beam: FortificationDroneBeam = BEAM_SCENE.instantiate()
		add_child(beam)
		_beams.append(beam)
	return _beams[index]


func _update_beams() -> void:
	var start: Vector3 = _visual_3d.global_position if _visual_3d != null else global_position
	for i: int in _beams.size():
		var beam: FortificationDroneBeam = _beams[i]
		var target: Entity = _beam_targets[i] if i < _beam_targets.size() else null
		if not is_instance_valid(target):
			beam.visible = false
			continue
		beam.visible = true
		beam.update_beam(start, target.get_collision_center())
