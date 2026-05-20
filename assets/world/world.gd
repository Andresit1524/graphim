class_name World extends Node2D


@export_group("Dependencies")
## Escena de un nodo
@export var node_scene: PackedScene
## Escena de una arista
@export var edge_scene: PackedScene


## Interfaz
@onready var ui: UI = %UI

## Lista de nodos del grafo
@onready var nodes: Node2D = %Nodes
## Lista de aristas
@onready var edges: Node2D = %Edges

## Datos actuales del grafo
@onready var current_graph_data := GraphData.new()


func _ready() -> void:
	# Conecta la interfaz a las funciones del grafo
	ui.buttons.delete_graph.connect(_delete_graph)
	ui.buttons.save_graph_on_current.connect(_save_graph_data)
	ui.buttons.load_graph.connect(_load_graph_data)
	# TODO: Resto de señales de los botones


#region Manejo del GraphData


## Actualiza el recurso de grafo actual usando los datos del nodo
func _save_graph_data() -> void:
	print("[World] Datos actualizados")

	current_graph_data.nodes.assign(nodes.get_children().map(func(c: GraphimNode):
		return c.get_data_copy()
	))
	current_graph_data.edges.assign(edges.get_children().map(func(c: GraphimEdge):
		return c.get_data_copy()
	))


## Elimina el grafo actual
func _delete_graph() -> void:
	# Elimina. No es necesario actualizar porque cada eliminación lo hace
	for child in edges.get_children():
		edges.remove_child(child)
		child.queue_free()

	for child in nodes.get_children():
		nodes.remove_child(child)
		child.queue_free()


## Carga el grafo desde un archivo
# ! Temporal: cargar desde el archivo actual
func _load_graph_data() -> void:
	# Borra primero
	_delete_graph()

	# Instancia todos los nodos
	for node_data in current_graph_data.nodes:
		var new_node: GraphimNode = node_scene.instantiate()
		new_node.data = node_data
		nodes.add_child(new_node, true)
		new_node.global_position = Vector2(randf_range(-200, 200), randf_range(-200, 200))

	# Instancia todas las aristas
	for edge_data in current_graph_data.edges:
		var new_edge: GraphimEdge = edge_scene.instantiate()
		new_edge.data = edge_data
		edges.add_child(new_edge, true)

		# Busca los nodos por su UID y vincula los extremos
		new_edge.data.start_node = _find_node_by_uid(new_edge.data.start_uid)
		new_edge.data.end_node = _find_node_by_uid(new_edge.data.end_uid)
		new_edge.data.refresh()


## Auxiliar: busca un nodo por su UID
func _find_node_by_uid(uid: int) -> GraphimNode:
	for node in nodes.get_children():
		if not is_instance_valid(node) or not is_instance_valid(node.data): continue
		if node.data.uid == uid: return node

	return null


#endregion
