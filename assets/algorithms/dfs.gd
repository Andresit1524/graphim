## Algoritmo de búsqueda en profundidad
class_name DFS extends BaseAlgorithm


@warning_ignore_start("unused_variable")
func start() -> void:
	var begin := await request_node(true, "Selecciona el nodo desde el cual buscar")
	var end := await request_node(true, "Selecciona el nodo al cual buscar")
	var adyacency_list: Dictionary[NodeData, Array] = graph_data().get_adyacency_list()

	if not adyacency_list.has(begin.data) or not adyacency_list[begin.data]:
		finish("No se encontró un camino entre los dos nodos")
		return

	for node_data: NodeData in adyacency_list[begin.data]:
		await wait(WAIT_TIME)
		node_data.color = Color.BLUE

	finish("Nodo encontrado")
