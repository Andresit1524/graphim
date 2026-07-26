## Algoritmo de búsqueda en profundidad
class_name DFS extends BaseAlgorithm


@warning_ignore_start("unused_variable")
func start() -> void:
	var begin := await request_node(true, "Selecciona el nodo desde el cual buscar")
	var target := await request_node(true, "Selecciona el nodo al cual buscar")
	var adyacency_list := get_adyacency_list()

	# Cola de prioridad
	var queue: Array[GraphimNode] = [begin]
	# Backtracking
	var backtrack: Dictionary[GraphimNode, GraphimNode]

	var result := await _dfs(adyacency_list, begin, target, queue, backtrack)
	if backtrack.has(target):
		ui.print_instruction("Ruta encontrada")
		_paint_result(backtrack, begin, target)
		return

	ui.print_instruction("Ruta no encontrada")


## Algoritmo principal de DFS
func _dfs(
	graph: Dictionary[GraphimNode, Array],
	begin: GraphimNode,
	target: GraphimNode,
	queue: Array[GraphimNode],
	backtrack:
) -> Dictionary[GraphimNode, GraphimNode]:
	# Si la pila se vació, no hay camino
	if queue.is_empty(): return backtrack

	var current: GraphimNode = queue.pop_back()
	current.data.color = Color.MEDIUM_SEA_GREEN

	# Fin de la ruta
	if current == target: return backtrack

	# Explorar vecinos
	for node: GraphimNode in graph[current]:
		if backtrack.has(node) or node == begin: continue

		await wait(WAIT_TIME)
		backtrack[node] = current
		queue.push_back(node)
		node.data.color = Color.PALE_GREEN

		# Colorea la arista
		var edge := world.find_edge_bi(node, current)
		if edge: edge.data.color = Color.PALE_GREEN

	# Continuar con el siguiente nodo disponible en la pila
	return await _dfs(graph, begin, target, queue, backtrack)


## Pinta la ruta obtenida
func _paint_result(backtrack: Dictionary[GraphimNode, GraphimNode], begin: GraphimNode, end: GraphimNode) -> void:
	var current := end
	while current != begin:
		var parent := backtrack[current]
		var edge := world.find_edge_bi(parent, current)

		current.data.color = Color.DODGER_BLUE
		parent.data.color = Color.DODGER_BLUE
		edge.data.color = Color.DODGER_BLUE

		current = parent
