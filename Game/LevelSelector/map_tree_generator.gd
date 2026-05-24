# MapTreeGenerator — produit un graphe d'arbre radial procédural pour le
# LevelSelector : nodes répartis sur des anneaux concentriques autour d'un
# « Départ » avec densité décroissante vers l'extérieur, et cross-connexions
# occasionnelles entre niveaux N et N+1. Pure calcul, aucune dépendance scène.
class_name MapTreeGenerator
extends RefCounted

#region Enums
enum EdgeKind { PARENT, CROSS }
#endregion


#region Inner classes
class NodeDesc:
	var id: int
	var level: int
	var angle: float
	var position: Vector2
	var parent_id: int = -1
	var arc_width: float = TAU
	var is_leaf: bool = false
	var root_branch_id: int = -1


class EdgeDesc:
	var from_id: int
	var to_id: int
	var kind: int


class Graph:
	var nodes: Array = []
	var edges: Array = []
	var by_level: Array = []
	var is_valid: bool = true
	var invalid_ids: Array = []
#endregion


#region Public vars
var seed: int = 0
var total_node_target: int = 45
var level_count: int = 10
var root_branches: int = 3
var min_children: int = 2
var max_children: int = 4
var ring_spacing: float = 220.0
var min_angular_gap_px: float = 180.0
var min_node_distance_px: float = 180.0
var angular_jitter_factor: float = 0.20
var radial_jitter_px: float = 25.0
var decay_exponent: float = 0.6
var level_targets_override: PackedInt32Array = PackedInt32Array()
#endregion


#region Private vars
var _rng: RandomNumberGenerator
#endregion


#region Public functions
func generate() -> Graph:
	_rng = RandomNumberGenerator.new()
	_rng.seed = seed

	var graph: Graph = Graph.new()
	graph.by_level.resize(level_count + 1)
	for L in range(level_count + 1):
		graph.by_level[L] = []

	var root: NodeDesc = _make_node(0, 0, 0.0, Vector2.ZERO, -1, TAU)
	graph.nodes.append(root)
	graph.by_level[0].append(root)

	var targets: Array = _compute_level_targets()

	_seed_ring_one(graph, root, targets[1])
	for L in range(2, level_count + 1):
		_grow_ring(graph, L, targets[L])

	_add_leaf_rescues(graph)
	_validate(graph)
	return graph
#endregion


#region Private functions
func _make_node(id: int, level: int, angle: float, pos: Vector2, parent_id: int, arc_width: float) -> NodeDesc:
	var n: NodeDesc = NodeDesc.new()
	n.id = id
	n.level = level
	n.angle = angle
	n.position = pos
	n.parent_id = parent_id
	n.arc_width = arc_width
	return n


func _make_edge(from_id: int, to_id: int, kind: int) -> EdgeDesc:
	var e: EdgeDesc = EdgeDesc.new()
	e.from_id = from_id
	e.to_id = to_id
	e.kind = kind
	return e


func _compute_level_targets() -> Array:
	var targets: Array = []
	targets.resize(level_count + 1)
	targets[0] = 1

	# Override manuel : si la liste a exactement level_count valeurs, on l'utilise telle quelle.
	if level_targets_override.size() == level_count and level_count > 0:
		for L in range(level_count):
			targets[L + 1] = max(1, int(level_targets_override[L]))
		return targets

	var fixed_root: int = max(1, root_branches)
	if level_count >= 1:
		targets[1] = fixed_root

	if level_count <= 1:
		return targets

	# Distribuer le reste sur les niveaux 2..level_count avec poids décroissants.
	# decay_exponent contrôle la pente : 0 = uniforme, 1 = linéaire, 2 = forte décroissance.
	var exp_clamped: float = max(0.0, decay_exponent)
	var weight_sum: float = 0.0
	for L in range(2, level_count + 1):
		weight_sum += pow(float(level_count + 1 - L), exp_clamped)

	var remaining: int = max(0, total_node_target - 1 - fixed_root)
	var allocated: int = 0
	for L in range(2, level_count + 1):
		var w: float = pow(float(level_count + 1 - L), exp_clamped)
		var raw: int = int(round(w / weight_sum * float(remaining)))
		targets[L] = max(1, raw)
		allocated += targets[L]

	var delta: int = remaining - allocated
	var passes: int = 0
	while delta != 0 and passes < level_count * 2:
		for L in range(2, level_count + 1):
			if delta == 0:
				break
			if delta > 0:
				targets[L] += 1
				delta -= 1
			elif targets[L] > 1:
				targets[L] -= 1
				delta += 1
		passes += 1
	return targets


func _seed_ring_one(graph: Graph, root: NodeDesc, count: int) -> void:
	if count <= 0:
		return
	var arc: float = TAU / float(count)
	for i in range(count):
		var angle: float = arc * (float(i) + 0.5)
		var pos: Vector2 = Vector2.RIGHT.rotated(angle) * ring_spacing
		var n: NodeDesc = _make_node(graph.nodes.size(), 1, angle, pos, root.id, arc)
		n.root_branch_id = i
		graph.nodes.append(n)
		graph.by_level[1].append(n)
		graph.edges.append(_make_edge(root.id, n.id, EdgeKind.PARENT))


func _grow_ring(graph: Graph, level: int, quota: int) -> void:
	var parents: Array = graph.by_level[level - 1]
	if parents.is_empty() or quota <= 0:
		for p in parents:
			p.is_leaf = true
		return

	var plan: Dictionary = _allocate_children(parents, quota)
	var min_gap: float = min_angular_gap_px / max(1.0, ring_spacing * float(level))
	var requested_jitter: float = clamp(angular_jitter_factor, 0.0, 0.5)

	# Cache id → position pour les tests de croisement rapides.
	var pos_by_id: Dictionary = {}
	for n in graph.nodes:
		pos_by_id[n.id] = n.position

	for parent in parents:
		var n_children: int = int(plan.get(parent.id, 0))
		while n_children > 1 and float(n_children - 1) * min_gap > parent.arc_width:
			n_children -= 1
		if n_children <= 0:
			parent.is_leaf = true
			continue
		var safe_jitter: float = 0.5 / float(max(1, n_children))
		var jitter_amp: float = min(requested_jitter, safe_jitter)
		var child_arc: float = parent.arc_width / float(n_children)
		for i in range(n_children):
			var center: float = parent.angle - parent.arc_width * 0.5 + child_arc * (float(i) + 0.5)
			var base_radius: float = ring_spacing * float(level)
			# Position de fallback : centre exact de l'arc, rayon nominal.
			var best_angle: float = center
			var best_radius: float = base_radius
			var best_pos: Vector2 = Vector2.RIGHT.rotated(center) * base_radius
			var best_score: int = _position_score(parent.position, best_pos, graph, pos_by_id)
			# 6 tentatives avec jitter pour trouver une position propre.
			for _attempt in range(6):
				var jitter: float = _rng.randf_range(-jitter_amp, jitter_amp) * child_arc
				var rj: float = _rng.randf_range(-radial_jitter_px, radial_jitter_px)
				var cand_angle: float = center + jitter
				var cand_radius: float = base_radius + rj
				var cand_pos: Vector2 = Vector2.RIGHT.rotated(cand_angle) * cand_radius
				var score: int = _position_score(parent.position, cand_pos, graph, pos_by_id)
				if score < best_score:
					best_score = score
					best_angle = cand_angle
					best_radius = cand_radius
					best_pos = cand_pos
				if best_score == 0:
					break
			var n: NodeDesc = _make_node(graph.nodes.size(), level, best_angle, best_pos, parent.id, child_arc)
			n.root_branch_id = parent.root_branch_id
			graph.nodes.append(n)
			graph.by_level[level].append(n)
			graph.edges.append(_make_edge(parent.id, n.id, EdgeKind.PARENT))
			pos_by_id[n.id] = best_pos


func _allocate_children(parents: Array, quota: int) -> Dictionary:
	var plan: Dictionary = {}
	for p in parents:
		plan[p.id] = 0
	if quota <= 0 or parents.is_empty():
		return plan

	# Grouper les parents par branche racine pour garantir la continuité.
	var by_branch: Dictionary = {}
	for p in parents:
		var bid: int = p.root_branch_id
		if not by_branch.has(bid):
			by_branch[bid] = []
		by_branch[bid].append(p)

	var branch_ids: Array = by_branch.keys()
	_shuffle(branch_ids)

	# Étape 1 : garantir au moins 1 enfant pour un parent de chaque branche vivante.
	# Si quota < nb_branches, certaines branches meurent (choix random via shuffle).
	var picked: Array = []
	var remaining: int = quota
	for bid in branch_ids:
		if remaining <= 0:
			break
		var branch_parents: Array = by_branch[bid].duplicate()
		_shuffle(branch_parents)
		var chosen = branch_parents[0]
		plan[chosen.id] = 1
		picked.append(chosen)
		remaining -= 1

	# Étape 2 : monter chaque picked à min_children si le quota le permet.
	for p in picked:
		if remaining <= 0:
			break
		var deficit: int = max(0, min_children - int(plan[p.id]))
		var add: int = min(deficit, remaining)
		plan[p.id] = int(plan[p.id]) + add
		remaining -= add

	# Étape 3 : distribuer le reste sur picked (sans dépasser max_children).
	var idx: int = 0
	var rounds_without_assign: int = 0
	while remaining > 0 and rounds_without_assign < picked.size():
		var p = picked[idx % picked.size()]
		if int(plan[p.id]) < max_children:
			plan[p.id] = int(plan[p.id]) + 1
			remaining -= 1
			rounds_without_assign = 0
		else:
			rounds_without_assign += 1
		idx += 1
	return plan


func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


func _add_leaf_rescues(graph: Graph) -> void:
	# Une feuille intermédiaire (node N < N_max sans enfant direct) se rattache au
	# N+1 voisin le plus proche pour éviter les culs-de-sac visuels.
	var children_count: Dictionary = {}
	for n in graph.nodes:
		children_count[n.id] = 0
	for e in graph.edges:
		if e.kind == EdgeKind.PARENT:
			children_count[e.from_id] = int(children_count[e.from_id]) + 1

	var max_rescue_dist: float = ring_spacing * 1.5
	for L in range(1, level_count):
		var ring_a: Array = graph.by_level[L]
		var ring_b: Array = graph.by_level[L + 1]
		if ring_a.is_empty() or ring_b.is_empty():
			continue
		for n in ring_a:
			if int(children_count[n.id]) != 0:
				continue
			# Choix par distance euclidienne : pertinent avec le radial jitter qui peut
			# rendre l'angle trompeur.
			var rescue: NodeDesc = _closest_by_position(n, ring_b)
			if rescue == null:
				continue
			if n.position.distance_to(rescue.position) > max_rescue_dist:
				continue
			if _edge_exists(graph, n.id, rescue.id):
				continue
			graph.edges.append(_make_edge(n.id, rescue.id, EdgeKind.CROSS))


func _closest_by_angle(node: NodeDesc, candidates: Array) -> NodeDesc:
	var best: NodeDesc = null
	var best_d: float = INF
	for c in candidates:
		var d: float = _angular_dist(node.angle, c.angle)
		if d < best_d:
			best_d = d
			best = c
	return best


func _closest_by_position(node: NodeDesc, candidates: Array) -> NodeDesc:
	var best: NodeDesc = null
	var best_d: float = INF
	for c in candidates:
		var d: float = node.position.distance_to(c.position)
		if d < best_d:
			best_d = d
			best = c
	return best


func _count_crossings(from_pos: Vector2, to_pos: Vector2, graph: Graph, pos_by_id: Dictionary) -> int:
	var count: int = 0
	for e in graph.edges:
		if e.kind != EdgeKind.PARENT:
			continue
		var from_p = pos_by_id.get(e.from_id)
		var to_p = pos_by_id.get(e.to_id)
		if from_p == null or to_p == null:
			continue
		# Ignore les arêtes qui partagent un endpoint avec le candidat (cas légitime).
		if from_p == from_pos or from_p == to_pos or to_p == from_pos or to_p == to_pos:
			continue
		if _segments_intersect(from_pos, to_pos, from_p, to_p):
			count += 1
	return count


func _position_score(from_pos: Vector2, candidate_pos: Vector2, graph: Graph, pos_by_id: Dictionary) -> int:
	# Score combiné : un croisement coûte plus cher qu'un chevauchement, mais les deux
	# pénalisent la position. min score = 0 = parfait.
	var crossings: int = _count_crossings(from_pos, candidate_pos, graph, pos_by_id)
	var too_close: int = 0
	var min_d: float = min_node_distance_px
	if min_d > 0.0:
		for other_id in pos_by_id:
			var other_pos: Vector2 = pos_by_id[other_id]
			if other_pos == from_pos:
				continue
			if candidate_pos.distance_to(other_pos) < min_d:
				too_close += 1
	return crossings * 100 + too_close * 30


static func _segments_intersect(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var d1: float = _cross2d(p4 - p3, p1 - p3)
	var d2: float = _cross2d(p4 - p3, p2 - p3)
	var d3: float = _cross2d(p2 - p1, p3 - p1)
	var d4: float = _cross2d(p2 - p1, p4 - p1)
	return ((d1 > 0.0 and d2 < 0.0) or (d1 < 0.0 and d2 > 0.0)) \
			and ((d3 > 0.0 and d4 < 0.0) or (d3 < 0.0 and d4 > 0.0))


static func _cross2d(a: Vector2, b: Vector2) -> float:
	return a.x * b.y - a.y * b.x


static func _angular_dist(a: float, b: float) -> float:
	var d: float = fmod(absf(a - b), TAU)
	if d > PI:
		d = TAU - d
	return d


func _edge_exists(graph: Graph, a: int, b: int) -> bool:
	for e in graph.edges:
		if (e.from_id == a and e.to_id == b) or (e.from_id == b and e.to_id == a):
			return true
	return false


func _validate(graph: Graph) -> void:
	graph.is_valid = true
	graph.invalid_ids.clear()
	if graph.nodes.is_empty():
		return

	var adj: Dictionary = {}
	for n in graph.nodes:
		adj[n.id] = []
	for e in graph.edges:
		adj[e.from_id].append(e.to_id)
		adj[e.to_id].append(e.from_id)

	var dist: Dictionary = {0: 0}
	var queue: Array = [0]
	while not queue.is_empty():
		var current: int = queue.pop_front()
		for neighbor in adj[current]:
			if not dist.has(neighbor):
				dist[neighbor] = int(dist[current]) + 1
				queue.append(neighbor)

	for n in graph.nodes:
		var expected: int = n.level
		var actual: int = int(dist.get(n.id, -1))
		if actual != expected:
			graph.is_valid = false
			graph.invalid_ids.append(n.id)
			Verbose.error("MapTreeGenerator: node %d niveau %d à distance BFS %d" % [n.id, expected, actual], Verbose.Category.DEFAULT)
#endregion
