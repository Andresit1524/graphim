## Clase base para un algoritmo sobre un grafo. Forma de uso: método [start] para
@abstract class_name BaseAlgorithm extends Node


## Se emite cuando el algoritmo es cancelado
signal aborted


## Tiempo de espera entre pasos
const WAIT_TIME = 1.0
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


## Finzaliza la ejecución si se deselecciona el botón
func abort(msg := "") -> void:
	ui.enable_all()
	ui.print_instruction(msg)
	reset_graph_visuals()
	await wait(LONG_WAIT_TIME)

	ui.clear_instruction()
	aborted.emit()


#region Utilidades


## Solicita la selección de un nodo, opcionalmente resaltándolo y usando otro mensaje
func request_node(highlight := false, msg := "") -> GraphimNode:
	ui.print_instruction("Selecciona un nodo" if not msg else msg)
	var requested: GraphimNode = await world.node_clicked
	ui.clear_instruction()

	if highlight: requested.data.color = Color.MEDIUM_SEA_GREEN

	return requested


## Solicita la selección de una arista, opcionalmente resaltándola
func request_edge(highlight := false, msg := "") -> GraphimEdge:
	ui.print_instruction("Selecciona una arista" if not msg else msg)
	var requested: GraphimEdge = await world.edge_clicked
	ui.clear_instruction()

	if highlight: requested.data.color = Color.GREEN

	return requested


## Resetea el estado del grafo
func reset_graph_visuals() -> void:
	for node in get_nodes():
		node.data.color = Color.WHITE

	for edge in get_edges():
		edge.data.color = Color.WHITE


## Espera un tiempo
func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout


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
