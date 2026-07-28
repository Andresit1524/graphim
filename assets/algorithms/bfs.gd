## Algoritmo de búsqueda en anchura
class_name BFS extends BaseAlgorithm


func start() -> void:
	# Nodo inicial
	var begin := await request_node("Selecciona el nodo para comenzar el recorrido")
	# Grafo en lista de adyacencia
	var graph := get_adyacency_list()

	# Backtracking para colorear aristas
	var backtrack: Dictionary[GraphimNode, GraphimNode]
	# Lista de pesos
	var distances: Dictionary[GraphimNode, float]
	# Cola de prioridad
	var queue: Array[GraphimNode]

	# Inicializa
	for node in get_nodes():
		backtrack[node] = null
		distances[node] = INF

	begin.data.color = GraphColors.VISITED
	distances[begin] = 0

	# Bucle de recorrido
	queue.push_back(begin)
	while not queue.is_empty():
		var current: GraphimNode = queue.pop_front()

		# Recorrido de los vecinos
		for neighbor: GraphimNode in graph[current]:
			var conection := world.find_edge_bi(current, neighbor)

			# Vecinos disponibles
			if neighbor.data.color == GraphColors.BASE:
				await wait(WAIT_TIME)

				distances[neighbor] = distances[current] + conection.data.weight
				backtrack[neighbor] = current
				queue.push_back(neighbor)

				Sounds.play_sound(&"pop")
				neighbor.data.color = GraphColors.VISITED
				_paint_parent_edge(neighbor, backtrack)

			# Tacha las aristas sobrantes
			if conection.data.color == GraphColors.BASE:
				await wait(SHORT_WAIT_TIME)
				Sounds.play_sound(&"fail")
				conection.data.color = GraphColors.WRONG

		# Un nodo se considera finalizado cuando se exploran todos sus vecinos
		await wait(SHORT_WAIT_TIME)
		Sounds.play_sound(&"bell")
		current.data.color = GraphColors.FINISHED
		_paint_parent_edge(current, backtrack)

	Sounds.play_sound(&"success")
	begin.data.color = GraphColors.HIGHLIGHT
	_discard_rest()
