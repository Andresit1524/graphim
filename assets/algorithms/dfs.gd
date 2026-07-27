## Algoritmo de búsqueda en profundidad
class_name DFS extends BaseAlgorithm


func start() -> void:
	# Nodo inicial
	var begin := await request_node("Selecciona el nodo para comenzar el recorrido")

	# Grafo en lista de adyacencia
	var graph := get_adyacency_list()
	# Backtracking
	var backtrack: Dictionary[GraphimNode, GraphimNode]

	# Inicializa el grafo
	for node in get_nodes():
		backtrack[node] = null

	await _depth_first_search(graph, begin, backtrack)
	begin.data.color = GraphColors.HIGHLIGHT

	# Colorea los nodos y aristas restantes
	for edge in get_edges():
		if edge.data.color == GraphColors.BASE:
			edge.data.color = GraphColors.WRONG

	for node in get_nodes():
		if node.data.color == GraphColors.BASE:
			node.data.color = GraphColors.WRONG


## Visita un nodo y sus vecinos
func _depth_first_search(
	graph: Dictionary[GraphimNode, Array],
		node: GraphimNode,
	backtrack: Dictionary[GraphimNode, GraphimNode]
):
	await wait(WAIT_TIME)
	node.data.color = GraphColors.VISITED
	_color_parent_edge(node, backtrack)

	# Recorre sus vecinos si no ha sido así
	for neighbor in graph[node]:
		if neighbor.data.color == GraphColors.BASE:
			backtrack[neighbor] = node
			await _depth_first_search(graph, neighbor, backtrack)

	await wait(WAIT_TIME / 2)
	node.data.color = GraphColors.FINISHED
	_color_parent_edge(node, backtrack)


## Colorea la arista de la que viene un nodo
func _color_parent_edge(current: GraphimNode, backtrack: Dictionary[GraphimNode, GraphimNode]):
	var conection := world.find_edge_bi(backtrack[current], current)
	if conection: conection.data.color = current.data.color
