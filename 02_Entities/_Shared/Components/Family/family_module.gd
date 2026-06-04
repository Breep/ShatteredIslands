# Container des FamilyManager d'une entité. Crée les managers comme enfants
# de lui-même. Pilote leur level (depuis le deck +
# overrides) et leur lifecycle (start/stop sur fighting_state).
class_name FamilyComponent
extends EntityComponent

#region ============================== Public variables ==============================
var families_stats: FamiliesStats
#endregion


#region ============================== Private variables ==============================
var _family_managers: Dictionary[Family.Type, FamilyManager]
#endregion


#region ============================== Node base functions ==============================
func _enter_tree() -> void:
	if not _owner.is_hero():
		# Module chargé universellement mais dormant pour les non-hero entities.
		return

	families_stats = FamiliesStats.new()
	for family_type: Family.Type in Shared.FAMILY_MANAGER_SCENES.keys():
		var fm: FamilyManager = Shared.FAMILY_MANAGER_SCENES[family_type].instantiate() as FamilyManager
		_family_managers[family_type] = fm.init(_owner)
		add_child(fm)
#endregion


#region ============================== Public functions ==============================
func get_families_level() -> Dictionary[Family.Type, int]:
	var levels: Dictionary[Family.Type, int] = {}
	for ft: Family.Type in _family_managers.keys():
		levels[ft] = _family_managers[ft].level
	return levels


# Applique les levels de family fournis en overrides. La dérivation depuis le
# deck a été retirée (la nouvelle mécanique de familles sera branchée plus tard).
func compute_levels(overrides: Dictionary[Family.Type, int]) -> void:
	for family_type: Family.Type in _family_managers:
		if overrides.has(family_type):
			_family_managers[family_type].level = overrides[family_type]
		Verbose.trace("<" + name + "> [ " + Family.Type.keys()[family_type] + " - " + str(_family_managers[family_type].level), Verbose.Category.HERO)


func start_all() -> void:
	for fm: FamilyManager in _family_managers.values():
		fm.start()


func stop_all() -> void:
	for fm: FamilyManager in _family_managers.values():
		fm.stop()


func apply_passive_all() -> void:
	for fm: FamilyManager in _family_managers.values():
		fm.apply_passive()
#endregion
