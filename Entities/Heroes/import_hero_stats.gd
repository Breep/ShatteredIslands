@tool
extends EditorScript

# Chemin vers ton fichier JSON exporté
const JSON_PATH = "res://Entities/Heroes/ImportJson/stats.json"
# Dossier où les fichiers .tres seront créés (crée ce dossier avant de lancer !)
const BASE_OUTPUT_FOLDER = "res://Entities/Heroes/Export/"

func _run() -> void:
	if not FileAccess.file_exists(JSON_PATH):
		print("Erreur : JSON introuvable.")
		return

	var file = FileAccess.open(JSON_PATH, FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	
	if json_data == null:
		print("Erreur de lecture du JSON.")
		return

	# On parcourt chaque ligne du fichier
	for entry in json_data:
		# 1. On récupère l'ID du héros et son niveau
		var hero_id = str(entry["hero_id"]) 
		var level = int(entry["level"])
		
		# 2. On crée le chemin du dossier spécifique (ex: res://resources/heroes/warrior/)
		var hero_folder = BASE_OUTPUT_FOLDER + hero_id + "/"
		
		# Si le dossier n'existe pas, on le crée
		var dir = DirAccess.open("res://")
		if not dir.dir_exists(hero_folder):
			dir.make_dir_recursive(hero_folder)
			print("Dossier créé : ", hero_folder)

		# 3. On crée et remplit la ressource
		var new_stats = HeroStats.new()
		new_stats.apply_json_data(entry) # Ta fonction magique de tout à l'heure
		
		# 4. On sauvegarde : warrior_lvl_1.tres
		var file_name = hero_folder + hero_id + "_lvl_" + str(level) + ".tres"
		ResourceSaver.save(new_stats, file_name)

	# Rafraîchir l'éditeur
	get_editor_interface().get_resource_filesystem().scan()
	print("Importation multi-héros terminée !")
