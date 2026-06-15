extends Control

## Proto harness for BossHealthBarComponent. Drives the bar through a detached
## stand-in Entity (stats + alterations + progression only — no auto-loaded combat
## modules, no spawn) and a button panel exercising the boss-facing API: name,
## phases, max HP, damage/heal and level.

const BOSS_BAR_SCENE: PackedScene = preload("res://02_Entities/_Shared/Components/HealthBar/BossHealthBar/boss_health_bar_component.tscn")

const BOSS_NAMES: Array[String] = ["Forest Drake", "Berserker King", "The Hollow Tyrant"]

var _owner_entity: Entity
var _bar: BossHealthBarComponent
var _phase_count: int = 1
var _name_index: int = 0
var _status_label: Label
var _rng := RandomNumberGenerator.new()


#region ============================== Node base functions ==============================
func _ready() -> void:
	_owner_entity = _build_proto_owner()

	_bar = BOSS_BAR_SCENE.instantiate() as BossHealthBarComponent
	_bar._owner = _owner_entity
	add_child(_bar)
	_bar.setup_phases(_phase_count)

	_owner_entity.stats.health_changed.connect(func(_h: float) -> void: _refresh_status())
	_owner_entity.stats.health_max_changed.connect(func(_h: float) -> void: _refresh_status())

	_build_panel()
	_refresh_status()


func _exit_tree() -> void:
	if is_instance_valid(_owner_entity):
		_owner_entity.queue_free()
#endregion


#region ============================== Proto owner ==============================
# A bare Entity kept out of the SceneTree: Entity._init() builds its stats and
# registries, but _enter_tree/_ready never fire so none of the combat modules
# auto-load and no spawn runs. We hand-wire just the two components the bar reads.
func _build_proto_owner() -> Entity:
	var ent := Entity.new()
	ent.entity_name = BOSS_NAMES[_name_index]
	ent.stats.health_max = 5000
	ent.stats.health = 5000

	var alt := AlterationsComponent.new()
	alt.init(ent)
	alt._build_alterations()
	ent.alterations = alt
	ent.add_child(alt)

	var prog := ProgressionComponent.new()
	prog.init(ent)
	ent.progression = prog
	ent.add_child(prog)

	return ent
#endregion


#region ============================== Panel ==============================
func _build_panel() -> void:
	var panel := VBoxContainer.new()
	panel.position = Vector2(24, 96)
	panel.add_theme_constant_override("separation", 6)
	add_child(panel)

	_status_label = Label.new()
	panel.add_child(_status_label)

	_add_button(panel, "Damage 250", func() -> void: _damage(250))
	_add_button(panel, "Damage 1000", func() -> void: _damage(1000))
	_add_button(panel, "Heal 500", func() -> void: _heal(500))
	_add_button(panel, "Random hit", func() -> void: _damage(_rng.randi_range(100, 1200)))
	_add_button(panel, "Max HP 5000", func() -> void: _set_max(5000))
	_add_button(panel, "Max HP 12000", func() -> void: _set_max(12000))
	_add_button(panel, "Cycle phases (1-4)", func() -> void: _cycle_phases())
	_add_button(panel, "Level +1", func() -> void: _change_level(1))
	_add_button(panel, "Level -1", func() -> void: _change_level(-1))
	_add_button(panel, "Cycle boss name", func() -> void: _cycle_name())
	_add_button(panel, "Reset", func() -> void: _reset())


func _add_button(parent: Node, text: String, on_pressed: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(on_pressed)
	parent.add_child(button)
#endregion


#region ============================== Drivers ==============================
func _damage(amount: float) -> void:
	_owner_entity.stats.health -= amount


func _heal(amount: float) -> void:
	_owner_entity.stats.health += amount


func _set_max(value: float) -> void:
	_owner_entity.stats.health_max = value
	_owner_entity.stats.health = value
	_bar.setup_phases(_phase_count)
	_refresh_status()


func _cycle_phases() -> void:
	_phase_count = _phase_count + 1 if _phase_count < 4 else 1
	_bar.setup_phases(_phase_count)
	_refresh_status()


# Sets the level directly (bypassing ProgressionComponent's stat recompute, which
# would rewrite health_max from base stats — irrelevant noise for this proto).
func _change_level(delta: int) -> void:
	var new_level: int = maxi(1, _owner_entity.progression.level + delta)
	_owner_entity.progression._level = new_level
	_owner_entity.progression.level_changed.emit(new_level)
	_refresh_status()


func _cycle_name() -> void:
	_name_index = (_name_index + 1) % BOSS_NAMES.size()
	_owner_entity.entity_name = BOSS_NAMES[_name_index]
	_bar.set_boss_name(BOSS_NAMES[_name_index])


func _reset() -> void:
	_phase_count = 1
	_name_index = 0
	_owner_entity.entity_name = BOSS_NAMES[0]
	_bar.set_boss_name(BOSS_NAMES[0])
	_owner_entity.progression._level = 1
	_owner_entity.progression.level_changed.emit(1)
	_owner_entity.stats.health_max = 5000
	_owner_entity.stats.health = 5000
	_bar.setup_phases(1)
	_refresh_status()


func _refresh_status() -> void:
	if _status_label == null:
		return
	var stats := _owner_entity.stats
	_status_label.text = "HP %d / %d    Lv %d    Phases %d" % [
		int(stats.health), int(stats.health_max), _owner_entity.progression.level, _phase_count
	]
#endregion
