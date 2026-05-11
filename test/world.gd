class_name World extends Node2D


## Lista de botones
@onready var buttons: Buttons = %Buttons
## Texto de lista de nodos
@onready var list: RichTextLabel = %Text

## Lista de aristas
@onready var edges: Node2D = %Edges
## Lista de nodos del grafo
@onready var nodes: Node2D = %Nodes


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
	edges.child_order_changed.connect(_update_edges)
	nodes.child_order_changed.connect(_update_nodes)

	# Actualiza a la fuerza
	_update_edges()
	_update_nodes()


#region Manejo del grafo


## Elimina el grafo actual
func _delete_graph() -> void:
	for child in edges.get_children():
		child.queue_free()

	for child in nodes.get_children():
		child.queue_free()


## Actualiza la lista de nodos
func _update_nodes() -> void:
	print("[World] Nodos actualizados")
	nodes_names = _nodes_to_string(nodes.get_children())

	# TODO: implementación en el grafo abstracto


## Actualiza la lista de aristas
func _update_edges() -> void:
	print("[World] Aristas actualizadas")
	edges_names = _nodes_to_string(edges.get_children())

	# TODO: implementación en el grafo abstracto


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
	list.text = "[center][b]Nodes[/b][/center]" + nodes_names + "\n\n[center][b]Aristas[/b][/center]" + edges_names


#endregion


#region Entrada


func _unhandled_input(event: InputEvent) -> void:
	# Resetea el botón de borrar si se clica por fuera
	if event is InputEventMouseButton and event.is_pressed():
		buttons.has_delete_button_pressed = false


#endregion
