@tool
extends EditorScript

# Vérifie que ce chemin correspond bien à ton dossier racine
const JSON_PATH = "res://Entities/Heroes/_Shared/ImportJson/stats.json"
# Le dossier racine où se trouvent tes dossiers de héros
const HEROES_ROOT_DIR = "res://Entities/Heroes/"

func _run() -> void:
	if not FileAccess.file_exists(JSON_PATH):
		push_error("JSON introuvable !")
		return

	var file = FileAccess.open(JSON_PATH, FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	
	if json_data == null:
		push_error("Erreur de lecture du JSON.")
		return

	print("--- Début de l'injection dans les ressources HeroDesc ---")

	# Regroupement des données par ID de héros
	var data_per_hero = {}
	for entry in json_data:
		var h_id = str(entry["hero_id"])
		if not data_per_hero.has(h_id):
			data_per_hero[h_id] = []
		data_per_hero[h_id].append(entry)

	# Traitement de chaque héros
	for hero_id in data_per_hero:
		_process_single_hero(hero_id, data_per_hero[hero_id])
		
	# Rafraîchissement
	get_editor_interface().get_resource_filesystem().scan()
	print("--- Terminé ---")

func _process_single_hero(hero_id: String, entries: Array) -> void:
	var snake_name = hero_id.to_snake_case() # Ex: DarkKnight -> dark_knight
	
	# Chemins
	var hero_folder = HEROES_ROOT_DIR + hero_id + "/"
	var stats_folder = hero_folder + "Stats/"
	var main_res_path = hero_folder + snake_name + ".tres"

	# Vérifications de sécurité
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(hero_folder):
		print("⚠️ Dossier introuvable pour : ", hero_id)
		return

	if not dir.dir_exists(stats_folder):
		dir.make_dir_recursive(stats_folder) # Création auto du dossier Stats

	if not FileAccess.file_exists(main_res_path):
		print("⚠️ Ressource HeroDesc introuvable : ", main_res_path)
		return

	# Chargement de la ressource "HeroDesc"
	var main_hero_res = ResourceLoader.load(main_res_path)
	
	# Vérification que la variable 'stats' existe bien dans ton script HeroDesc
	if not "stats" in main_hero_res:
		print("ERREUR : La variable 'stats' est introuvable dans ", main_res_path)
		print("Vérifie que ton script HeroDesc a bien '@export var stats: Dictionary'")
		return
		
	print("🔄 Mise à jour de : ", hero_id)
	
	# On vide le dictionnaire existant pour ne garder que les specs du JSON
	main_hero_res.stats.clear()
	
	# Génération des fichiers de stats pour chaque niveau
	for entry in entries:
		var level = int(entry["level"])
		
		# Création des données (Livre page X)
		var new_stats = HeroStats.new()
		new_stats.apply_json_data(entry)
		
		# Sauvegarde du fichier individuel
		var stats_filename = snake_name + "_lvl_" + str(level) + ".tres"
		var final_stats_path = stats_folder + stats_filename
		ResourceSaver.save(new_stats, final_stats_path)
		
	# Injection dans ton fichier HeroDesc (Livre complet)
		# Note : on utilise .stats (minuscule) comme dans ton code source
		var loaded_stats = ResourceLoader.load(final_stats_path)
		main_hero_res.stats[level] = loaded_stats
		
	# Sauvegarde finale du HeroDesc
	ResourceSaver.save(main_hero_res, main_res_path)
	print("✅ HeroDesc mis à jour : ", main_res_path)
