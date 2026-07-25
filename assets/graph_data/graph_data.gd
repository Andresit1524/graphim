## Contiene los datos de un grafo (no referencias), de forma serializable y persistente
class_name GraphData extends Resource


## Lista de datos de nodos
@export var nodes_data: Array

## Lista de datos de aristas
@export var edges_data: Array


## Obtiene la lista de adyacencia del grafo actual
# ? Se usará para los algoritmos, pero eso es más adelante
func get_adyacency_list() -> Dictionary[NodeData, Array]:
	var adyacency_list: Dictionary[NodeData, Array] = {}
	var nodes_by_uid := {}

	# Registra por UID
	for n in nodes_data:
		nodes_by_uid[n.uid] = n
		adyacency_list[n] = []

	# Filtra
	for e in edges_data:
		var start: NodeData = nodes_by_uid.get(e.start_uid)
		var end: NodeData = nodes_by_uid.get(e.end_uid)
		if start and end:
			adyacency_list[start].append(end)
			if not e.directed: adyacency_list[end].append(start)

	return adyacency_list


## Obtiene la matriz de adyacencia (en producto cartesiano) del grafo actual.
## Formato: [inicio, final]: peso. Si no existe, el peso es NAN
# ? Se usará para los algoritmos, pero eso es más adelante
func get_adyacency_matrix() -> Dictionary[Array, float]:
	var adyacency_matrix: Dictionary[Array, float] = {}
	var nodes_by_uid := {}

	# Registra por UID
	for n in nodes_data:
		nodes_by_uid[n.uid] = n

	# Primera pasada para las aristas
	for e in edges_data:
		var start: NodeData = nodes_by_uid.get(e.start_uid)
		var end: NodeData = nodes_by_uid.get(e.end_uid)
		if start and end: adyacency_matrix[[start, end]] = e.weight

	# Segunda pasada para el resto
	for node_a: NodeData in nodes_data:
		for node_b: NodeData in nodes_data:
			if adyacency_matrix.has([node_a, node_b]): continue
			adyacency_matrix[[node_a, node_b]] = NAN

	return adyacency_matrix
