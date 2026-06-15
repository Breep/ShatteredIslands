# Joue le VFX et le SFX de montée de niveau sur l'entité porteuse.
# Drop le component dans la scène d'une entité (hero ou monstre) et set _owner :
# il se connecte à progression.level_changed et déclenche le feedback à chaque level up.

class_name LevelUpVfxComponent
extends EntityComponent

#region ============================== Export ==============================
@export var _vfx_scene: PackedScene = preload("res://22_VFX/VFX_3D/LevelUp/Scenes/VFX_LV_Up_style_e.tscn")
## Durée avant auto-destruction de l'instance de VFX (anim + lifetime des particules).
@export var _vfx_lifetime: float = 2.0
## Clé du son dans SFX_library.tres, joué en 3D à la position du porteur.
@export var _sfx_key: String = "lvlup"
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	super._ready()
	if _owner == null: return
	# Le set initial de progression.level (dans son _ready) émet level_changed
	# pendant le setup. On diffère la connexion d'une frame pour ignorer cette
	# émission et ne jouer le VFX que sur un vrai level up en jeu.
	await get_tree().process_frame
	if not is_instance_valid(_owner) or _owner.progression == null: return
	_owner.progression.level_changed.connect(_on_owner_progression_level_changed)
#endregion

#region ============================== Private functions ==============================
func _play_level_up_vfx() -> void:
	if not is_instance_valid(_owner) or _vfx_scene == null: return

	var vfx: Node3D = _vfx_scene.instantiate()
	_owner.add_child(vfx)
	vfx.position = Vector3.ZERO

	var tree: SceneTree = _owner.get_tree()
	if tree == null: return
	tree.create_timer(_vfx_lifetime).timeout.connect(func() -> void:
		if is_instance_valid(vfx):
			vfx.queue_free()
	)


func _play_level_up_sfx() -> void:
	if not is_instance_valid(_owner) or _sfx_key.is_empty(): return
	AudioManager.play_3d(_sfx_key, _owner.global_position)
#endregion

#region ============================== Callbacks ==============================
func _on_owner_progression_level_changed(_new_level: int) -> void:
	_play_level_up_vfx()
	_play_level_up_sfx()
#endregion
