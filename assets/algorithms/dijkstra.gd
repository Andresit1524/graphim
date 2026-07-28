## Algoritmo de Dijkstra entre dos nodos
class_name Dijkstra extends BaseAlgorithm


func start() -> void:
	# Nodo inicial
	var begin := await request_node("Selecciona el nodo para comenzar el recorrido")
	# Nodo final
	var end := await request_node("Selecciona el nodo para buscar")
	# Grafo en lista de adyacencia
	var graph := get_adyacency_list()

	# Costo
	var cost: Dictionary[GraphimNode, float]
	# Backtracking para hallar la ruta
	var backtrack: Dictionary[GraphimNode, GraphimNode]
	# Lista de nodos no visitados
	var unvisited: Array[GraphimNode]

	# Inicializa
	for node in get_nodes():
		cost[node] = INF
		backtrack[node] = null
		unvisited.append(node)

	cost[begin] = 0.0

	# Itera sobre los nodos no visitados
	while not unvisited.is_empty():
		# Obtiene el nodo de menor costo y lo visita
		var current: GraphimNode = _min_cost_node(cost)
		unvisited.erase(current)

		await wait(WAIT_TIME)
		Sounds.play_sound(&"pop")
		current.data.color = GraphColors.VISITED
		paint_parent_edge(current, backtrack)

		# Fin o nodo inalcanzable
		if current == end or cost[current] == INF: break

		# Itera sobre cada vecino del nodo actual
		for neighbor in graph[current]:
			if neighbor not in unvisited: continue

			var new_cost := cost[current] + world.find_edge_bi(current, neighbor).data.weight

			if new_cost < cost[neighbor]:
				cost[neighbor] = new_cost
				backtrack[neighbor] = current

	if cost[end] == INF:
		Sounds.play_sound(&"fail")
		_discard_rest()
		return

	Sounds.play_sound(&"success")
	_paint_route(begin, end, backtrack)


## Obtiene el mínimo costo de la lista de nodos
func _min_cost_node(cost: Dictionary[GraphimNode, float]) -> GraphimNode:
	var current: GraphimNode = cost.keys().pick_random()
	for node in cost:
		if node.data.color == GraphColors.VISITED: continue
		if cost[node] < cost[current]: current = node

	return current


## Pinta la ruta entre los dos nodos usando el backtrack
func _paint_route(
	begin: GraphimNode,
	end: GraphimNode,
	backtrack: Dictionary[GraphimNode, GraphimNode]
) -> void:
	begin.data.color = GraphColors.HIGHLIGHT
	end.data.color = GraphColors.HIGHLIGHT
	var current := end

	while current != begin:
		current.data.color = GraphColors.HIGHLIGHT
		paint_parent_edge(current, backtrack)
		current = backtrack[current]
