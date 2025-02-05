extends Node3D

# Nombre de cartes à afficher
@export var player_nb_card: int = 10  

# Niveaux des familles
@export var defense_level: int = 2
@export var poison_level: int = 2
@export var fire_level: int = 6

var fire:Color = Color(1, 0, 0)     # Rouge
var storm:Color = Color(0, 0, 1)   # Bleu
var defense:Color = Color(0.4, 0.26, 0.13)  # Marron
var aa:Color = Color(0.774, 0.644, 0.085)  # jaune
var shadow:Color = Color(0, 0, 0)   #noir
var poison:Color =Color(0.069, 0.332, 0.106) 
var heal:Color =Color(1, 1, 1) 
var hp:Color = Color(0.737, 0.379, 0.087) 

var family_colors = {
	"Fire": Color(1, 0, 0),               # Rouge
	"Defense": Color(0.4, 0.26, 0.13),    # Marron
	"Poison": Color(0.069, 0.332, 0.106)  # Vert foncé
}

func _ready() -> void:
	_show_player_card_on_table()

func _show_player_card_on_table():
	var total_level = fire_level + defense_level + poison_level
	

	var families = {
		"Fire": fire_level,
		"Defense": defense_level,
		"Poison": poison_level
	}
	
	for i in range(min(player_nb_card, 10)):
		var card_node_name = str(i + 1)
		var card_node = get_node_or_null("%" + card_node_name)
		
		if card_node:
			card_node.show()

	# Application des couleurs en fonction du ratio de chaque famille
	var card_index = 0
	for family_name in families.keys():
		var ratio = round((families[family_name] / (total_level as float)) * player_nb_card)
		print(ratio)
		for j in range(ratio):
			if card_index < player_nb_card:
				var card_node = get_node_or_null("%" + str(card_index + 1))
				if card_node:
					card_node.modulate = family_colors[family_name]
					card_node.show()
				card_index += 1

	## Si des cartes n'ont pas été colorées, les afficher par défaut
	#for k in range(card_index, player_nb_card):
		#var card_node = get_node_or_null("%" + str(k + 1))
		#if card_node:
			#card_node.modulate = Color(1, 1, 1)  # Blanc par défaut
			#card_node.show()
