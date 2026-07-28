## Algoritmo de búsqueda en profundidad
class_name DFS extends BaseAlgorithm


func start() -> void:
	# Nodo inicial
	var begin := await request_node("Selecciona el nodo para comenzar el recorrido")
	# Grafo en lista de adyacencia
	var graph := get_adyacency_list()

	# Backtracking para colorear aristas
	var backtrack: Dictionary[GraphimNode, GraphimNode]
	for node in get_nodes():
		backtrack[node] = null

	# Explora el grafo
	await _depth_first_search(graph, begin, backtrack)
	Sounds.play_sound(&"success")
	begin.data.color = GraphColors.HIGHLIGHT
	_discard_rest()


## Visita un nodo y sus vecinos
func _depth_first_search(
	graph: Dictionary[GraphimNode, Array],
	node: GraphimNode,
	backtrack: Dictionary[GraphimNode, GraphimNode]
) -> void:
	# Marca como visitado
	await wait(WAIT_TIME)
	Sounds.play_sound(&"pop")
	node.data.color = GraphColors.VISITED
	paint_parent_edge(node, backtrack)

	# Recorre sus vecinos si no ha sido así
	for neighbor in graph[node]:
		if neighbor.data.color == GraphColors.BASE:
			backtrack[neighbor] = node
			await _depth_first_search(graph, neighbor, backtrack)
			continue

		var conection := world.find_edge_bi(node, neighbor)
		if conection.data.color == GraphColors.BASE:
			await wait(SHORT_WAIT_TIME)
			Sounds.play_sound(&"fail")
			conection.data.color = GraphColors.WRONG

	# El nodo se considera finalizado si sus vecinos lo están
	await wait(SHORT_WAIT_TIME)
	Sounds.play_sound(&"bell")
	node.data.color = GraphColors.FINISHED
	paint_parent_edge(node, backtrack)
