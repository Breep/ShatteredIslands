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

	# Chargement de la ressource "HeroDesc" SANS cache pour éviter les problèmes
	var main_hero_res = ResourceLoader.load(main_res_path, "", ResourceLoader.CACHE_MODE_IGNORE)

	# Vérification que la variable 'stats' existe bien dans ton script HeroDesc
	if not "stats" in main_hero_res:
		print("ERREUR : La variable 'stats' est introuvable dans ", main_res_path)
		print("Vérifie que ton script HeroDesc a bien '@export var stats: Dictionary'")
		return

	print("🔄 Mise à jour de : ", hero_id)

	# Créer un nouveau dictionnaire de stats
	var new_stats_dict: Dictionary[int, HeroStats] = {}

	# Génération des fichiers de stats pour chaque niveau
	for entry in entries:
		var level = int(entry["level"])

		# Création des données
		var new_stats = HeroStats.new()
		new_stats.apply_json_data(entry)

		# Sauvegarde du fichier individuel
		var stats_filename = snake_name + "_lvl_" + str(level) + ".tres"
		var final_stats_path = stats_folder + stats_filename
		ResourceSaver.save(new_stats, final_stats_path)

		# Rechargement sans cache
		var loaded_stats = ResourceLoader.load(final_stats_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		new_stats_dict[level] = loaded_stats
		print("  ✅ Niveau ", level, " -> ", final_stats_path)

	# Remplacer le dictionnaire stats en entier
	main_hero_res.stats = new_stats_dict

	# Sauvegarde finale du HeroDesc
	ResourceSaver.save(main_hero_res, main_res_path)
	print("✅ HeroDesc mis à jour : ", main_res_path, " (", new_stats_dict.size(), " niveaux)")
