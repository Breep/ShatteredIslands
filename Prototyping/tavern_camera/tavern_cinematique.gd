# Script à attacher au nœud "tavern_cinematique"
extends Node3D

# On cible l'AnimationPlayer qui se trouve à l'intérieur de la scène "dark knight".
# Le chemin est "$'NomDuNoeud/NomDeLAnimationPlayer'".
# Les guillemets sont nécessaires car le nom "dark knight" a un espace.
@onready var anim_player: AnimationPlayer = $"dark knight/AnimationPlayer"

# On va stocker les noms des animations ici
var _animation_list: PackedStringArray
# On garde en mémoire l'animation en cours
var _current_animation_index: int = 0


func _ready() -> void:
	# 1. On récupère la liste de toutes les animations
	_animation_list = anim_player.get_animation_list()
	
	# On s'assure qu'il y a bien des animations à jouer
	if _animation_list.is_empty():
		print("Erreur : Aucune animation trouvée dans ", anim_player.get_path())
		return
	
	# 2. On connecte le signal "animation_finished".
	# Quand une animation se termine, la fonction _on_animation_finished sera appelée.
	anim_player.animation_finished.connect(_on_animation_finished)
	
	# 3. On lance la toute première animation de la liste
	play_next_animation()


# Fonction pour jouer l'animation suivante
func play_next_animation() -> void:
	# On vérifie si on n'a pas dépassé la fin de la liste
	if _current_animation_index < _animation_list.size():
		var animation_name = _animation_list[_current_animation_index]
		print("Lancement de l'animation : '", animation_name, "'")
		anim_player.play(animation_name)
	else:
		print("Séquence d'animations terminée.")
		# Optionnel : Si vous voulez que ça recommence en boucle, décommentez les 2 lignes suivantes
		# _current_animation_index = 0
		# play_next_animation()


# Cette fonction est appelée automatiquement à la fin de chaque animation
# grâce à la connexion faite dans _ready()
func _on_animation_finished(anim_name: String) -> void:
	# On passe à l'index de l'animation suivante
	_current_animation_index += 1
	
	# Et on lance la lecture
	play_next_animation()
