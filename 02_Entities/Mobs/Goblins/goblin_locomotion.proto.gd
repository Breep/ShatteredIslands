# Proto isolée pour valider la pipeline Synty Goblins :
# AnimationLibrary partagée + BoneAttachment3D pour les armes.
# Pas de couplage à Entity/AnimationComponent — on teste uniquement la mécanique d'asset Godot.
extends Node3D


# ============================== Export ==============================
#region Export
@export var _hand_bone_name: String = "RightHand"
@export var _library_prefix: String = "goblin_loco"
#endregion


# ============================== Private variables ==============================
#region Private variables
@onready var _goblin: Node3D = $Goblin
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _btn_idle: Button = $UI/Panel/Buttons/BtnIdle
@onready var _btn_walk: Button = $UI/Panel/Buttons/BtnWalk
@onready var _btn_run: Button = $UI/Panel/Buttons/BtnRun
@onready var _btn_attack: Button = $UI/Panel/Buttons/BtnAttack
@onready var _variant_picker: OptionButton = $UI/Panel/VariantPicker
@onready var _status_label: Label = $UI/Panel/StatusLabel

var _skeleton: Skeleton3D
var _variant_meshes: Array[MeshInstance3D] = []
var _weapon_attachment: BoneAttachment3D
#endregion


# ============================== Node base functions ==============================
#region Node base functions
func _ready() -> void:
	_skeleton = _find_skeleton(_goblin)
	if _skeleton == null:
		_set_status("Skeleton3D introuvable dans Goblin — vérifier l'instance du FBX.")
		return

	_collect_variants()
	_show_only_first_variant()
	_setup_weapon_attachment()
	_setup_variant_picker()
	_connect_buttons()
	_play("idle")
#endregion


# ============================== Private functions ==============================
#region Private functions
func _find_skeleton(root: Node) -> Skeleton3D:
	if root is Skeleton3D:
		return root
	for child in root.get_children():
		var found: Skeleton3D = _find_skeleton(child)
		if found != null:
			return found
	return null


func _collect_variants() -> void:
	_variant_meshes.clear()
	for child in _skeleton.get_children():
		if child is MeshInstance3D:
			_variant_meshes.append(child)


func _show_only_first_variant() -> void:
	for i in _variant_meshes.size():
		_variant_meshes[i].visible = (i == 0)


func _setup_weapon_attachment() -> void:
	_weapon_attachment = BoneAttachment3D.new()
	_weapon_attachment.name = "WeaponSlot"
	_weapon_attachment.bone_name = _hand_bone_name
	_skeleton.add_child(_weapon_attachment)

	var placeholder := MeshInstance3D.new()
	placeholder.name = "PlaceholderWeapon"
	var box := BoxMesh.new()
	box.size = Vector3(0.05, 0.05, 0.25)
	placeholder.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.55, 0.15)
	placeholder.material_override = mat
	_weapon_attachment.add_child(placeholder)

	if _skeleton.find_bone(_hand_bone_name) == -1:
		_set_status("Bone '%s' introuvable — ajuster _hand_bone_name dans l'inspecteur." % _hand_bone_name)


func _setup_variant_picker() -> void:
	_variant_picker.clear()
	for mesh in _variant_meshes:
		_variant_picker.add_item(mesh.name)
	_variant_picker.item_selected.connect(_on_variant_selected)


func _connect_buttons() -> void:
	_btn_idle.pressed.connect(func(): _play("idle"))
	_btn_walk.pressed.connect(func(): _play("walk"))
	_btn_run.pressed.connect(func(): _play("run"))
	_btn_attack.pressed.connect(func(): _play("attack"))


func _play(anim_short_name: String) -> void:
	var full_name := "%s/%s" % [_library_prefix, anim_short_name]
	if not _animation_player.has_animation(full_name):
		_set_status("Animation '%s' absente — vérifier l'AnimationLibrary attachée à l'AnimationPlayer." % full_name)
		return
	_animation_player.play(full_name)
	_set_status("Playing: %s" % full_name)


func _set_status(msg: String) -> void:
	if _status_label != null:
		_status_label.text = msg
	Verbose.debug("[GoblinLocomotionProto] " + msg, Verbose.Category.ENTITY_ANIMATION)
#endregion


# ============================== Callbacks ==============================
#region Callbacks
func _on_variant_selected(index: int) -> void:
	for i in _variant_meshes.size():
		_variant_meshes[i].visible = (i == index)
	_set_status("Variant: %s" % _variant_meshes[index].name)
#endregion
