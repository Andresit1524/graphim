class_name World extends Node2D


## Lista de botones
@onready var buttons: Buttons = %Buttons

## Lista de aristas
@onready var edges: Node2D = %Edges
## Lista de nodos del grafo
@onready var nodes: Node2D = %Nodes


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
	# TODO: implementación en el grafo abstracto


## Actualiza la lista de aristas
func _update_edges() -> void:
	print("[World] Aristas actualizadas")
	# TODO: implementación en el grafo abstracto


#endregion


#region Entrada


func _unhandled_input(event: InputEvent) -> void:
	# Resetea el botón de borrar si se clica por fuera
	if event is InputEventMouseButton and event.is_pressed():
		buttons.has_delete_button_pressed = false


#endregion
