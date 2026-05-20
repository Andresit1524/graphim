class_name UI extends Control


## Lista de botones
@onready var buttons: Buttons = %Buttons
## Texto de la lista de objetos
@onready var nodes_list_text: RichTextLabel = %Text
## Etiqueta de FPS
@onready var fps_label = %FPS
## Etiqueta de archivo actual
@onready var current_file: Label = $CurrentFile

## Lista de nodos del grafo
@onready var nodes: Node2D = %Nodes
## Lista de aristas
@onready var edges: Node2D = %Edges


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
	# Conecta la lista de nodos y de aristas a la actualización de interfaz
	nodes.child_order_changed.connect(_update_node_names)
	nodes.child_order_changed.connect(buttons.mark_as_not_saved.bind(true))

	edges.child_order_changed.connect(_update_edge_names)
	edges.child_order_changed.connect(buttons.mark_as_not_saved.bind(true))

	# Actualiza a la fuerza
	_update_node_names()
	_update_edge_names()


func _physics_process(_delta) -> void:
	# Actualiza los FPS
	fps_label.text = "FPS: %s" % Engine.get_frames_per_second()


#region Objects list


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
	nodes_list_text.text = "[center][b]Nodos[/b][/center]" + nodes_names + "\n\n[center][b]Aristas[/b][/center]" + edges_names


## Auxiliar: convierte la lista de nodos en una lista
func _nodes_to_string(nodes_list: Array[Node]) -> String:
	return nodes_list.reduce(func(current_text: String, node: Node):
		return (current_text + "\n- %s" % node.name),
		""
	)


#endregion


## Actualiza el nombre de archivo
func set_file_name(file_name := "") -> void:
	current_file.text = file_name if file_name else "Grafo en escena"


func _unhandled_input(event: InputEvent) -> void:
	# Resetea el botón de borrar si se clica por fuera
	if event is InputEventMouseButton and event.is_pressed():
		buttons.has_delete_button_pressed = false
