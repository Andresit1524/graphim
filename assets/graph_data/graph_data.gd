## [code]GraphData[/code] contiene los datos de una grafo, de forma serializable y persistente.
class_name GraphData extends Resource


## Lista de nodos
@export var nodes: Array

## Lista de aristas
@export var edges: Array


## Obtiene la lista de adyacencia del grafo actual
func get_adyacency_list() -> Dictionary[GraphimNode, Array]:
	var adyacency_list := {}
	for node: GraphimNode in nodes:
		adyacency_list[node] = edges.filter(
			func(e: GraphimEdge): return e.data.start_node == node
		).map(
			func(e: GraphimEdge): return e.data.end_node
		)

	return adyacency_list


## Obtiene la matriz de adyacencia del grafo actual.
## Formato: [inicio, final]: peso. Si no existe, el peso es NAN
func get_adyacency_matrix() -> Dictionary[Array, float]:
	var adyacency_matrix := {}

	# Primera pasada para las aristas
	for node_a: GraphimNode in nodes:
		for node_b: GraphimNode in nodes:
			adyacency_matrix[[node_a, node_b]] = edges.filter(
				func(e: GraphimEdge): return (
					e.data.start_node == node_a
					and e.data.end_node == node_b
				)
			).map(
				func(e: GraphimEdge): return e.data.weight
			)

	# Segunda pasada para el resto
	for node_a: GraphimNode in nodes:
		for node_b: GraphimNode in nodes:
			if adyacency_matrix.has([node_a, node_b]): continue

			adyacency_matrix[[node_a, node_b]] = NAN

	return adyacency_matrix
