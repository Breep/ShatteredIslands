# Proto scene de UIEntityPortrait : exerce le composant isolé du jeu.
# - Tween hover/press : survoler/cliquer les icônes de skill directement.
# - Swap stats <-> description : boutons "Desc Bronze" / "Stats" + clic en dehors.
# - Snapshot + suivi live des stats : un Entity créé hors-arbre (pas de _ready
#   lourd) est bindé, puis ses stats sont mutées pour voir les ItemList suivre.
# - Placeholder portrait : l'Entity n'a pas d'entity_desc => texture par défaut.
extends Control

@onready var _portrait: UIEntityPortrait = %EntityPortrait
@onready var _bind_button: Button = %BindButton
@onready var _mutate_ad_button: Button = %MutateADButton
@onready var _mutate_armor_button: Button = %MutateArmorButton
@onready var _set_level_button: Button = %SetLevelButton
@onready var _show_desc_button: Button = %ShowDescButton
@onready var _show_stats_button: Button = %ShowStatsButton
@onready var _damage_button: Button = %DamageButton

var _dummy: Entity = null


func _ready() -> void:
	_bind_button.pressed.connect(_on_bind_pressed)
	_mutate_ad_button.pressed.connect(_on_mutate_ad_pressed)
	_mutate_armor_button.pressed.connect(_on_mutate_armor_pressed)
	_set_level_button.pressed.connect(_on_set_level_pressed)
	_show_desc_button.pressed.connect(_on_show_desc_pressed)
	_show_stats_button.pressed.connect(_on_show_stats_pressed)
	_damage_button.pressed.connect(_on_damage_pressed)


func _exit_tree() -> void:
	_free_dummy()


func _on_bind_pressed() -> void:
	_free_dummy()
	_dummy = Entity.new()
	_dummy.entity_name = "Proto Mob"
	_dummy.stats.health_max = 1200
	_dummy.stats.health = 1000
	_dummy.stats.attack_damage = 42
	_dummy.stats.attack_speed = 1.3
	_dummy.stats.attack_power = 25
	_dummy.stats.armor = 15
	_dummy.stats.dodge = 8
	_dummy.stats.crit_chance = 20
	_portrait.bind(_dummy)


func _on_mutate_ad_pressed() -> void:
	if is_instance_valid(_dummy):
		_dummy.stats.attack_damage += 10


func _on_mutate_armor_pressed() -> void:
	if is_instance_valid(_dummy):
		_dummy.stats.armor += 5


func _on_damage_pressed() -> void:
	if is_instance_valid(_dummy):
		_dummy.stats.health -= 100


func _on_set_level_pressed() -> void:
	_portrait._on_level_changed(randi_range(1, 20))


func _on_show_desc_pressed() -> void:
	_portrait._show_desc(Skill.Type.BRONZE)


func _on_show_stats_pressed() -> void:
	_portrait._show_stats()


func _free_dummy() -> void:
	if is_instance_valid(_dummy):
		_dummy.free()
	_dummy = null
