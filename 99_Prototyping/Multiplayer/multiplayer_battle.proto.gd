extends Node

# Proto de test du combat en multijoueur. Monte rapidement un host/client local,
# pilote la latence du BattleLogSynchronizer (période d'envoi + délai simulé côté
# lecteur), simule une déconnexion/reconnexion, et lance / reset un combat
# synchronisé à partir des unités placées dans Team1 / Team2.
#
# Proto-only : on accède librement à l'API interne des modules réseau/combat.
# UI et connexions de signaux sont décrites dans la scène ; ce script ne porte
# que le comportement. Le SEUL endroit dépendant du flow de jeu réel est
# _start_fight_local().

#region ============================== Enums ==============================
# Rôle réseau effectif. Distinct de multiplayer.is_server() qui renvoie true
# même hors-ligne (OfflineMultiplayerPeer par défaut) : ici NONE tant qu'aucun
# serveur/connexion ENet n'a réellement été établi.
enum Role { NONE, HOST, CLIENT }
#endregion

#region ============================== Constants ==============================
const DEFAULT_IP := "127.0.0.1"
const MAX_PEERS := 8
# Équipes passées à init_fight (mappées aux SpawnArea par la FightingArea).
const LEFT_TEAM := 1
const RIGHT_TEAM := 2
#endregion

#region ============================== Export (scene refs) ==============================
@export var _arch_island: FightingIsland
@export var _team1: Node3D
@export var _team2: Node3D
@export var _ip_field: LineEdit
@export var _port_field: SpinBox
@export var _status_label: Label
# Section host : sync period + combat. Visible seulement quand on héberge.
@export var _host_section: Control
@export var _sync_period_label: Label
@export var _sync_period_slider: HSlider
# Section client : reader delay + simulation de déco. Visible seulement en client.
@export var _client_section: Control
@export var _delay_label: Label
@export var _delay_slider: HSlider
@export var _reconnect_delay_field: SpinBox
#endregion

#region ============================== Private variables ==============================
var _role := Role.NONE
# Mémorise le dernier rôle/adresse voulus pour la reconnexion simulée.
var _was_host := false
var _last_ip := DEFAULT_IP
var _last_port := 4242
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	_setup_window()

	GameManager.init()

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	# Applique les valeurs initiales des sliders posées dans l'éditeur.
	_on_sync_period_changed(_sync_period_slider.value)
	_on_delay_changed(_delay_slider.value)

	# Au départ : seule la section connexion est visible.
	_update_role_ui()

	# Caméra de l'île pour voir le combat (sans dépendre du reste du jeu).
	if _arch_island != null:
		_arch_island.set_active()


# Ouvre la proto en fenêtré. Le projet démarre en plein écran sauf en éditeur
# (window/size/mode.editor=0). On force le fenêtré par sécurité, puis — une frame
# plus tard, une fois la transition appliquée — on dimensionne et place.
func _setup_window() -> void:
	await get_tree().process_frame
	var window := get_window()
	window.mode = Window.MODE_WINDOWED
	window.borderless = false
	await get_tree().process_frame
	_place_window(window)


# Dimensionne la fenêtre à ~un quart de l'écran (moitié en largeur et hauteur,
# pour un tuilage 2x2) et la place dans le coin indiqué par --proto=<n> :
# 0=haut-gauche, 1=haut-droite, 2=bas-gauche, 3=bas-droite. Sans flag : centrée.
func _place_window(window: Window) -> void:
	var screen_pos := DisplayServer.screen_get_position(window.current_screen)
	var screen_size := DisplayServer.screen_get_size(window.current_screen)
	var win_size := screen_size / 2
	window.size = win_size

	var quadrant := _proto_quadrant()
	if quadrant < 0 or quadrant > 3:
		window.move_to_center()
		return
	var on_right := quadrant == 1 or quadrant == 3
	var on_bottom := quadrant == 2 or quadrant == 3
	var x: int = screen_pos.x + (win_size.x if on_right else 0)
	var y: int = screen_pos.y + (win_size.y if on_bottom else 0)
	window.position = Vector2i(x, y)


func _proto_quadrant() -> int:
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--proto="):
			return int(arg.get_slice("=", 1))
	return -1


# Affiche la section host (sync + combat) ou client (reader delay + déco) selon
# le rôle effectif. Tant qu'on n'a rien établi (Role.NONE), les deux restent
# masquées — y compris en solo où is_server() ment.
func _update_role_ui() -> void:
	if _host_section != null:
		_host_section.visible = _role == Role.HOST
	if _client_section != null:
		_client_section.visible = _role == Role.CLIENT
#endregion

#region ============================== Networking ==============================
func _host(port: int) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, MAX_PEERS)
	if err != OK:
		_set_status("Host failed (err %d)" % err)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	_was_host = true
	_last_port = port
	_role = Role.HOST
	_set_status("Hosting on :%d  (id=%d)" % [port, multiplayer.get_unique_id()])
	_update_role_ui()


func _join(ip: String, port: int) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, port)
	if err != OK:
		_set_status("Connect failed (err %d)" % err)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	_was_host = false
	_last_ip = ip
	_last_port = port
	_set_status("Connecting to %s:%d ..." % [ip, port])


func _disconnect_peer() -> void:
	multiplayer.multiplayer_peer = null
	_role = Role.NONE
	_update_role_ui()


func _reconnect() -> void:
	if _was_host:
		_host(_last_port)
	else:
		_join(_last_ip, _last_port)
#endregion

#region ============================== Fight control (RPC) ==============================
# Lancé par le host : tout le monde (host + clients) reçoit l'ordre et démarre
# le combat localement. Le host simule et écrit les logs (BattleWriter), les
# clients rejouent via BattleReader.
@rpc("any_peer", "call_local", "reliable")
func _rpc_start_fight() -> void:
	_start_fight_local()


# Reset : tout le monde se déconnecte et recharge la scène. Léger délai avant le
# teardown local pour laisser le paquet fiable partir vers les clients.
@rpc("any_peer", "call_local", "reliable")
func _rpc_reset() -> void:
	await get_tree().create_timer(0.1).timeout
	_disconnect_peer()
	get_tree().reload_current_scene()


# === SEUL point dépendant du flow de jeu : à ajuster si ton orchestration diffère.
func _start_fight_local() -> void:
	var fighting_area := _fighting_area()
	if fighting_area == null:
		_set_status("No FightingArea")
		return

	var left := _build_formation_from(_team1, fighting_area)
	var right := _build_formation_from(_team2, fighting_area)
	# Les placeholders Team1/Team2 ne servent qu'à décrire la formation : on les
	# retire pour ne pas doublonner avec les entités spawnées par init_fight.
	_free_placeholders()

	_arch_island.init_fight(left, right, LEFT_TEAM, RIGHT_TEAM)

	GlobalFightingManager.start()
	# POSITIONING est bloquant (attend un "READY") : on l'avance immédiatement.
	await get_tree().process_frame
	if fighting_area.fighting_manager != null:
		fighting_area.fighting_manager.request_phase_advance()
	_set_status("Fight started (%s)" % ("host/sim" if multiplayer.is_server() else "client/playback"))


func _build_formation_from(container: Node3D, fighting_area: FightingArea) -> FightingFormation:
	var formation := FightingFormation.new()
	if container == null:
		return formation
	# Les specs sont rejouées comme transforms LOCALES sous la FightingArea (qui
	# est tournée à 90° dans l'island). On exprime donc la pose monde des
	# placeholders dans l'espace de la FightingArea, sinon les unités héritent de
	# la rotation de l'island au spawn (nord/sud → gauche/droite).
	var to_fighting_area := fighting_area.global_transform.affine_inverse() if fighting_area != null else Transform3D.IDENTITY
	for child in container.get_children():
		var entity := child as Entity
		if entity == null:
			continue
		var spec := EntitySpec.new()
		spec.display_label = entity.name
		spec.transform = to_fighting_area * entity.global_transform
		if entity.entity_desc != null:
			spec.entry = RoasterEntry.from_desc(entity.entity_desc)
		elif entity.scene_file_path != "":
			spec.scene = load(entity.scene_file_path)
		formation.entity_specs.append(spec)
	return formation


func _free_placeholders() -> void:
	for container in [_team1, _team2]:
		if container == null:
			continue
		for child in container.get_children():
			child.queue_free()
#endregion

#region ============================== Accessors ==============================
func _fighting_area() -> FightingArea:
	if _arch_island == null:
		return null
	return _arch_island.get_fighting_area()


func _synchronizer() -> BattleLogSynchronizer:
	var fa := _fighting_area()
	if fa == null:
		return null
	return fa.get_node_or_null("BattleLogSynchronizer") as BattleLogSynchronizer


func _battle_reader() -> BattleReader:
	# N'existe que sur les clients (le BattleReader queue_free le sien côté serveur).
	var fa := _fighting_area()
	if fa == null:
		return null
	return fa.get_node_or_null("BattleReader") as BattleReader


func _set_status(text: String) -> void:
	if _status_label != null:
		_status_label.text = text
	Verbose.debug("[MP proto] " + text, Verbose.Category.NET)
#endregion

#region ============================== Callbacks (UI) ==============================
func _on_host_pressed() -> void:
	_host(int(_port_field.value))


func _on_connect_pressed() -> void:
	var ip := _ip_field.text if not _ip_field.text.is_empty() else DEFAULT_IP
	_join(ip, int(_port_field.value))


func _on_start_pressed() -> void:
	if multiplayer.multiplayer_peer == null:
		_start_fight_local() # mode solo / hors-réseau
		return
	_rpc_start_fight.rpc()


func _on_reset_pressed() -> void:
	if multiplayer.multiplayer_peer == null:
		get_tree().reload_current_scene()
		return
	_rpc_reset.rpc()


func _on_simulate_disconnect_pressed() -> void:
	if multiplayer.multiplayer_peer == null:
		_set_status("Not connected")
		return
	var delay := float(_reconnect_delay_field.value)
	_set_status("Disconnected — reco in %ss" % delay)
	_disconnect_peer()
	await get_tree().create_timer(delay).timeout
	_reconnect()


func _on_sync_period_changed(value_ms: float) -> void:
	if _sync_period_label != null:
		_sync_period_label.text = "Sync period: %d ms" % int(value_ms)
	var sync := _synchronizer()
	if sync != null:
		sync.set_sync_period(value_ms / 1000.0)


func _on_delay_changed(value_ms: float) -> void:
	if _delay_label != null:
		_delay_label.text = "Reader delay: %d ms" % int(value_ms)
	var reader := _battle_reader()
	if reader != null:
		reader.simulated_delay_ms = int(value_ms)
#endregion

#region ============================== Callbacks (multiplayer) ==============================
func _on_connected_to_server() -> void:
	_role = Role.CLIENT
	_set_status("Connected (id=%d)" % multiplayer.get_unique_id())
	_update_role_ui()


func _on_connection_failed() -> void:
	_role = Role.NONE
	_set_status("Connection failed")
	_update_role_ui()


func _on_server_disconnected() -> void:
	_role = Role.NONE
	_set_status("Server disconnected")
	_update_role_ui()


func _on_peer_connected(id: int) -> void:
	_set_status("Peer %d connected" % id)


func _on_peer_disconnected(id: int) -> void:
	_set_status("Peer %d disconnected" % id)
#endregion
