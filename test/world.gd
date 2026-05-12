class_name World extends Node2D


@export_group("Dependencies")
## Escena de un nodo
@export var node_scene: PackedScene
## Escena de una arista
@export var edge_scene: PackedScene


## Lista de botones
@onready var buttons: Buttons = %Buttons
## Texto de lista de nodos
@onready var list: RichTextLabel = %Text

## Lista de nodos del grafo
@onready var nodes: Node2D = %Nodes
## Lista de aristas
@onready var edges: Node2D = %Edges

## Datoa actuales del grafo
@onready var current_graph_data := GraphData.new()


## Nombres de los nodos
var nodes_names: String:
	set(value):
		nodes_names = value
		_update_objects_list()
## Nombres de las aristas
var edges_names: String:
	set(value):
		edges_names = value
		_update_objects_list()


func _ready() -> void:
	buttons.delete_graph.connect(_delete_graph)
	buttons.save_graph_on_current.connect(_save_graph_data)
	buttons.load_graph.connect(_load_graph_data)
	# TODO: Resto de señales de los botones

	# Conecta la lista de nodos y de aristas
	nodes.child_order_changed.connect(_update_node_names)
	edges.child_order_changed.connect(_update_edge_names)

	nodes.child_order_changed.connect(buttons.mark_as_not_saved.bind(true))
	edges.child_order_changed.connect(buttons.mark_as_not_saved.bind(true))

	# Actualiza a la fuerza
	_update_node_names()
	_update_edge_names()


#region Manejo del GraphData


## Actualiza el recurso de grafo actual usando los datos del nodo
func _save_graph_data() -> void:
	print("[World] Datos actualizados")

	current_graph_data.nodes.assign(nodes.get_children().map(func(c: GraphimNode):
		return c.get_data()
	))
	current_graph_data.edges.assign(edges.get_children().map(func(c: GraphimEdge):
		return c.get_data()
	))


## Elimina el grafo actual
func _delete_graph() -> void:
	# Elimina. No es necesario actualizar porque cada eliminación lo hace
	for child in edges.get_children():
		child.queue_free()

	for child in nodes.get_children():
		child.queue_free()


## Carga el grafo desde un archivo
# ! Temporal: cargar desde el archivo actual
func _load_graph_data() -> void:
	# Borra primero
	_delete_graph()

	# Instancia todos los nodos
	for node_data in current_graph_data.nodes:
		var new_node: GraphimNode = node_scene.instantiate()
		nodes.add_child(new_node)
		new_node.data = node_data
		new_node.global_position = Vector2(randf_range(-100, 100), randf_range(-100, 100))

	# Instancia todas las aristas
	# TODO: lograr que esto funcione (actualmente no lo hace)
	for edge in current_graph_data.edges:
		var new_edge: GraphimEdge = edge_scene.instantiate()
		edges.add_child(new_edge)
		new_edge.data = edge


#endregion


#region Interfaz y entrada


## Actualiza el texto de la lista de nodos
func _update_node_names() -> void:
	print("[World] Nodos actualizados")

	nodes_names = _nodes_to_string(nodes.get_children())


## Actualiza el texto de la lista de aristas
func _update_edge_names() -> void:
	print("[World] Aristas actualizadas")

	edges_names = _nodes_to_string(edges.get_children())


## Actualiza la lista de textos
func _update_objects_list() -> void:
	list.text = "[center][b]Nodos[/b][/center]" + nodes_names + "\n\n[center][b]Aristas[/b][/center]" + edges_names


## Auxiliar: convierte la lista de nodos en una lista
func _nodes_to_string(nodes_list: Array[Node]) -> String:
	return nodes_list.reduce(func(current_text: String, node: Node):
		return (current_text + "\n- %s" % node.name),
		""
	)


func _unhandled_input(event: InputEvent) -> void:
	# Resetea el botón de borrar si se clica por fuera
	if event is InputEventMouseButton and event.is_pressed():
		buttons.has_delete_button_pressed = false


#endregion
