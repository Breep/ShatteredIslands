extends Node3D


@export var nb_card_aa: int
@export var nb_card_fire: int
@export var nb_card_defense: int
@export var nb_card_heal: int
@export var nb_card_storm: int
@export var nb_card_shadow: int
@export var nb_card_poison: int
@export var nb_card_hp: int


var card_scene: PackedScene = preload("res://Scenes/Card/card_3d_visual.tscn")

# Dictionnaire des familles avec le nombre de cartes
@onready var families = {
	"AA": nb_card_aa,
	"Fire": nb_card_fire,
	"Defense": nb_card_defense,
	"Heal": nb_card_heal,
	"Storm": nb_card_storm,
	"Shadow": nb_card_shadow,
	"Poison": nb_card_poison,
	"HP": nb_card_hp
}


var family_colors = {
	"AA": Color(0.812, 0.684, 0),       # Jaune doré
	"Fire": Color(1, 0, 0),           # Rouge
	"Defense": Color(0.4, 0.26, 0.13),# Marron
	"Heal": Color(1, 1, 1),       
	"Storm": Color(0, 0.5, 1),        # Bleu ciel
	"Shadow": Color(0.1, 0.1, 0.1),   # Gris foncé
	"Poison": Color(0.022, 0.289, 0.021),   # Vert poison
	"HP": Color(0.899, 0.516, 0.17)   # Orange
}

func _ready() -> void:
	spawn_cards()

func spawn_cards() -> void:
	var family_index = 0  
	
	for family_name in families.keys():
		var nb_cards = families[family_name]
		var color = family_colors.get(family_name, Color(1, 1, 1))  
		
		for i in range(nb_cards):
			var card_instance = card_scene.instantiate()
			add_child(card_instance)
			
		
			var position = Vector3(global_position.x + (family_index * 0.7), global_position.y + (i * 0.04), global_position.z)
			card_instance.global_transform.origin = position
			
			
			var mesh = card_instance.get_node_or_null("Mesh")  
			if mesh:
			
				var material = mesh.get_surface_override_material(0)
				if material:
					material = material.duplicate()  
				else:
					material = StandardMaterial3D.new()
					material.roughness = 0.5
				
				material.albedo_color = color
				#material.roughness = 0.5
				#material.normal_enabled = true
				#material.normal_texture = texture_back
				mesh.set_surface_override_material(0, material)
				
				
			await get_tree().create_timer(0.1).timeout
			
		family_index += 1  
