class_name World extends Node2D


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
		_update_list()
## Nombres de las aristas
var edges_names: String:
	set(value):
		edges_names = value
		_update_list()


func _ready() -> void:
	buttons.delete_graph.connect(_delete_graph)
	# TODO: Resto de señales de los botones

	# Conecta la lista de nodos y de aristas
	nodes.child_order_changed.connect(_update_nodes)
	edges.child_order_changed.connect(_update_edges)

	# Actualiza a la fuerza
	_update_nodes()
	_update_edges()


#region Manejo del grafo


## Elimina el grafo actual
func _delete_graph() -> void:
	# Elimina. No es necesario actualizar porque cada eliminación lo hace
	for child in edges.get_children():
		child.queue_free()

	for child in nodes.get_children():
		child.queue_free()


## Actualiza la lista de nodos
func _update_nodes() -> void:
	print("[World] Nodos actualizados")

	# Actualiza los datos actuales del grafo, en el texto y en el recurso
	var children := nodes.get_children()

	nodes_names = _nodes_to_string(children)
	current_graph_data.nodes.assign(children)


## Actualiza la lista de aristas
func _update_edges() -> void:
	print("[World] Aristas actualizadas")

	# Actualiza los datos actuales del grafo, en el texto y en el recurso
	var children := edges.get_children()

	edges_names = _nodes_to_string(children)
	current_graph_data.edges.assign(children)


## Auxiliar: convierte la lista de nodos en una lista
func _nodes_to_string(nodes_list: Array[Node]) -> String:
	return nodes_list.reduce(func(current_text: String, node: Node):
		return (current_text + "\n- %s" % node.name),
		""
	)


#endregion


#region Interfaz


## Actualiza la lista de textos
func _update_list() -> void:
	list.text = "[center][b]Nodos[/b][/center]" + nodes_names + "\n\n[center][b]Aristas[/b][/center]" + edges_names


#endregion


#region Entrada


func _unhandled_input(event: InputEvent) -> void:
	# Resetea el botón de borrar si se clica por fuera
	if event is InputEventMouseButton and event.is_pressed():
		buttons.has_delete_button_pressed = false


#endregion
