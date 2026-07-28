## Clase base para un algoritmo sobre un grafo. Forma de uso: método [start] para
@abstract class_name BaseAlgorithm extends Node


## Se emite cuando el algoritmo es finalizado, sea cual sea el motivo
signal finished


## Tiempo de espera normal
const WAIT_TIME = 1.0
## Tiempo de espera corto
const SHORT_WAIT_TIME = 0.5
## Tiempo de espera largo
const LONG_WAIT_TIME = 2.0


## Nombre del algoritmo para poner en el botón
@export var button_name: String = ""


## Mundo
@onready var world: World = get_tree().current_scene
## Interfaz
@onready var ui: UI = %UI

## Nodos
@onready var nodes: Node2D = %Nodes
## Aristas
@onready var edges: Node2D = %Edges


## Inicia a procesar el algoritmo al presionar su botón
@abstract func start() -> void


## Finaliza la ejecución del algoritmo
func finish(msg := "") -> void:
	ui.enable_all()
	ui.print_instruction(msg)
	reset_graph_visuals()
	finished.emit()

	await wait(LONG_WAIT_TIME)
	ui.clear_instruction()


#region Utilidades


## Solicita la selección de un nodo, opcionalmente resaltándolo y usando otro mensaje
func request_node(msg := "") -> GraphimNode:
	ui.print_instruction("Selecciona un nodo" if not msg else msg)
	var requested: GraphimNode = await world.node_clicked
	ui.clear_instruction()

	requested.data.color = GraphColors.HIGHLIGHT
	return requested


## Solicita la selección de una arista, opcionalmente resaltándola
func request_edge(msg := "") -> GraphimEdge:
	ui.print_instruction("Selecciona una arista" if not msg else msg)
	var requested: GraphimEdge = await world.edge_clicked
	ui.clear_instruction()

	requested.data.color = GraphColors.HIGHLIGHT
	return requested


## Resetea el estado del grafo
func reset_graph_visuals() -> void:
	for node in get_nodes():
		node.data.color = GraphColors.BASE

	for edge in get_edges():
		edge.data.color = GraphColors.BASE


## Descarta los nodos y aristas que no se tocaron
func _discard_rest() -> void:
	# Colorea los nodos y aristas restantes
	for edge in get_edges():
		if edge.data.color == GraphColors.BASE:
			edge.data.color = GraphColors.WRONG

	for node in get_nodes():
		if node.data.color == GraphColors.BASE:
			node.data.color = GraphColors.WRONG


## Colorea la arista de la que viene un nodo
func _paint_parent_edge(current: GraphimNode, backtrack: Dictionary[GraphimNode, GraphimNode]):
	var conection := world.find_edge_bi(backtrack[current], current)
	if conection: conection.data.color = current.data.color


## Espera un tiempo
func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout


#endregion


#region Adyacencias


## Obtiene la lista de adyacencia del grafo actual. Los nodos huérfanos tienen lista vacía
func get_adyacency_list() -> Dictionary[GraphimNode, Array]:
	var adyacency_list: Dictionary[GraphimNode, Array] = {}

	# Inicializa
	for node in get_nodes():
		adyacency_list[node] = []

	# Aristas
	for edge in get_edges():
		var start_node := edge.data.start_node
		var end_node := edge.data.end_node
		if start_node and end_node:
			adyacency_list[start_node].append(end_node)
			if not edge.data.directed: adyacency_list[end_node].append(start_node)

	return adyacency_list


## Obtiene la matriz de adyacencia (en producto cartesiano) del grafo actual.
## Formato: [inicio, final]: peso. Si no existe, el peso es NAN
func get_adyacency_matrix() -> Dictionary[Array, float]:
	var adyacency_matrix: Dictionary[Array, float] = {}
	var nodes_list := get_nodes()

	# Primera pasada para las aristas
	for edge in get_edges():
		var start_node := edge.data.start_node
		var end_node := edge.data.end_node
		if start_node and end_node:
			adyacency_matrix[[start_node, end_node]] = edge.weight

	# Segunda pasada para el resto
	for node_a in nodes_list:
		for node_b in nodes_list:
			if adyacency_matrix.has([node_a, node_b]): continue
			adyacency_matrix[[node_a, node_b]] = NAN

	return adyacency_matrix


#endregion


#region Getters y setters


## Obtiene los datos del grafo actual
func graph_data() -> GraphData:
	world._save_graph()
	return world.current_graph_data


## Obtiene la lista de nodos
func get_nodes() -> Array[GraphimNode]:
	return nodes.get_children() as Array[GraphimNode]


## Obtiene la lista de aristas
func get_edges() -> Array[GraphimEdge]:
	return edges.get_children() as Array[GraphimEdge]


#endregion
