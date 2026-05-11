class_name World extends Node2D


## Lista de botones
@onready var buttons: Buttons = %Buttons

## Lista de aristas
@onready var edges: Node2D = $Edges
## Lista de nodos del grafo
@onready var nodes: Node2D = $Nodes


func _ready() -> void:
	buttons.delete_graph.connect(_delete_graph)


## Elimina el grafo actual
func _delete_graph() -> void:
	for child in edges.get_children():
		child.queue_free()

	for child in nodes.get_children():
		child.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# Resetea el botón de borrar si se clica por fuera
	if event is InputEventMouseButton and event.is_pressed():
		buttons.has_delete_button_pressed = false
