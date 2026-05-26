class_name World extends Node2D


## Se emite cuando se cambia el archivo actual
signal current_file_changed(new_name: String)


@export_group("Dependencies")
## Escena de un nodo
@export var node_scene: PackedScene
## Escena de una arista
@export var edge_scene: PackedScene


## Interfaz
@onready var ui: UI = %UI
## Ventana de guardado
@onready var save_load_dialog: FileDialog = %SaveDialog

## Lista de nodos del grafo
@onready var nodes: Node2D = %Nodes
## Lista de aristas
@onready var edges: Node2D = %Edges

## Datos actuales del grafo
@onready var current_graph_data := GraphData.new()


## Indica si estamos dibujando aristas
var drawing_edges := false


# Variables temporales para el dibujado de aristas
var current_start_for_new_edge: GraphimNode
var current_end_for_new_edge: GraphimNode


func _ready() -> void:
	# Conecta la interfaz a las funciones del grafo
	ui.buttons.delete.connect(_delete_graph)
	ui.buttons.save.connect(_save_graph)
	ui.buttons.save_as.connect(_save_graph_as)
	ui.buttons.load.connect(_load_graph)

	# Conecta el archivo actual a la interfaz
	current_file_changed.connect(ui.set_file_name)

	# Conecta la lista de nodos y de aristas a la actualización de interfaz
	nodes.child_order_changed.connect(ui.update_node_names)
	edges.child_order_changed.connect(ui.update_edge_names)

	# Conecta la lista de nodos a la actualización de señales
	edges.child_order_changed.connect(_update_edges)
	nodes.child_order_changed.connect(_update_nodes)

	# Actualiza a la fuerza
	_update_nodes()
	_update_edges()


#region Manejo del GraphData


## Actualiza el recurso de grafo actual usando los datos del nodo
func _save_graph() -> void:
	# Guarda en los datos de grafo
	current_graph_data.nodes.assign(nodes.get_children().map(func(c: GraphimNode):
		return c.get_data_copy()
	))
	current_graph_data.edges.assign(edges.get_children().map(func(c: GraphimEdge):
		return c.get_data_copy()
	))

	# Guarda en escena
	var save_path := current_graph_data.resource_path
	if not save_path.begins_with("user://"):
		print("[World] Guardado en escena")
		current_file_changed.emit("Grafo en escena")
		return

	# Guarda en archivo
	var error := ResourceSaver.save(current_graph_data)
	print(
		"[World] Guardado en archivo %s con código de error %s"
		% [_get_graph_data_path(), error]
	)
	current_file_changed.emit(_get_graph_data_path())


## Guarda los datos de grafo actual en un nuevo archivo
func _save_graph_as() -> void:
	save_load_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_load_dialog.popup_centered()

	await save_load_dialog.file_selected
	current_graph_data.resource_path = save_load_dialog.current_path
	print("[World] Guardando datos en %s" % _get_graph_data_path())
	_save_graph()


## Elimina el grafo actual
func _delete_graph() -> void:
	print("[World] Borrando grafo")

	# Elimina. No es necesario actualizar porque cada eliminación lo hace
	for child in edges.get_children():
		edges.remove_child(child)
		child.queue_free()

	for child in nodes.get_children():
		nodes.remove_child(child)
		child.queue_free()

	print("[World] Borrado")


## Carga el grafo desde un archivo
func _load_graph() -> void:
	# Busca en el menú de archivos a por el archivo que el usuario quiera y lo carga
	save_load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	save_load_dialog.popup_centered()
	await save_load_dialog.file_selected
	current_graph_data = ResourceLoader.load(save_load_dialog.current_path)

	print("[World] Cargando datos desde %s" % _get_graph_data_path())
	current_file_changed.emit(_get_graph_data_path())

	# Borra el grafo actual primero
	_delete_graph()

	# Lista de UIDs para poder encontrar más rápido
	var uids := {}

	# Instancia todos los nodos
	for node_data: NodeData in current_graph_data.nodes:
		var new_node: GraphimNode = node_scene.instantiate()
		new_node.data = node_data
		nodes.add_child(new_node, true)

		uids[new_node.data.uid] = new_node
		new_node.global_position = Vector2(randf_range(-200, 200), randf_range(-200, 200))

	# Instancia todas las aristas
	for edge_data: EdgeData in current_graph_data.edges:
		var new_edge: GraphimEdge = edge_scene.instantiate()
		new_edge.data = edge_data
		edges.add_child(new_edge, true)

		# Busca los nodos por su UID y vincula los extremos
		new_edge.data.start_node = uids.get(new_edge.data.start_uid)
		new_edge.data.end_node = uids.get(new_edge.data.end_uid)
		new_edge.data.refresh()

	print("[World] Cargado")


## Auxiliar: limpia la ruta del archivo de guardado
func _get_graph_data_path() -> String:
	return current_graph_data.resource_path.trim_prefix("user://graphs/")


#endregion


#region Manejo del grafo interno


## Actualiza las señales de los nodos
func _update_nodes() -> void:
	for node: GraphimNode in nodes.get_children():
		if not node.is_connected(&"clicked", _draw_edge): node.clicked.connect(_draw_edge)


## Actualiza las señales de las aristas
# ! No implementado
func _update_edges() -> void:
	pass


## Dibuja una arista entre los dos nodos cuando se seleccionan
func _draw_edge(new_node: GraphimNode) -> void:
	if not drawing_edges: return

	# Añade el inicio si es el caso
	if not current_start_for_new_edge:
		current_start_for_new_edge = new_node
		return

	# Añade el final
	# ? Aún no se soportan aristas redundantes. Así que se omiten
	current_end_for_new_edge = new_node
	if current_start_for_new_edge == current_end_for_new_edge: return

	# Verifica que la arista no este existiendo ya
	# ? Se separan los métodos para que sea fácil implementar bucles en el futuro
	if _find_edge(current_start_for_new_edge, current_end_for_new_edge): return
	if _find_edge_reverse(current_start_for_new_edge, current_end_for_new_edge): return

	# Crea y configura
	var new_edge: GraphimEdge = edge_scene.instantiate()
	edges.add_child(new_edge, true)
	new_edge.data.start_node = current_start_for_new_edge
	new_edge.data.end_node = current_end_for_new_edge
	new_edge.data.refresh()

	# Resetea los nodos para nueva arista
	current_start_for_new_edge = null
	current_end_for_new_edge = null


## Auxiliar: busca una arista que contenga los dos nodos dados y la retorna
func _find_edge(start_node: GraphimNode, end_node: GraphimNode) -> GraphimEdge:
	for edge in edges.get_children():
		if edge.data.start_node == start_node and edge.data.end_node == end_node: return edge

	return null


## Auxiliar: busca una arista que contenga los dos nodos dados (en reversa) y lo retorna.
## Esto solo es válido si la arista no es dirigida.
func _find_edge_reverse(start_node: GraphimNode, end_node: GraphimNode) -> GraphimEdge:
	for edge in edges.get_children():
		# Coinciden en el orden inverso (solo pasa si no es dirigido)
		if (
			edge.data.start_node == end_node
			and edge.data.end_node == start_node
			and not edge.data.directed
		): return edge

	return null


#endregion


## Actualiza el estado del dibujado de grafos
func _on_draw_button_pressed() -> void:
	drawing_edges = not drawing_edges
	if not drawing_edges:
		current_end_for_new_edge = null
		current_start_for_new_edge = null
