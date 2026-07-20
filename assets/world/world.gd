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
## Botón para dibujar aristas
@onready var directed_button: Button = %DirectedEdgesButton
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
## Indica si estamos dibujando aristas dirigidas o no
var drawing_directed := false

# Variables temporales para el dibujado de aristas
var current_new_edge_start: GraphimNode
var current_new_edge_end: GraphimNode


func _ready() -> void:
	# Botones de acción (borrar, guardar, ...)
	ui.action_buttons.delete.connect(_delete_graph)
	ui.action_buttons.save.connect(_save_graph)
	ui.action_buttons.save_as.connect(_save_graph_as)
	ui.action_buttons.load.connect(_load_graph)

	# Cambio de nombre de archivo en la UI
	current_file_changed.connect(ui.set_file_name)

	# Actualización del conteo de nodos y aristas
	nodes.child_order_changed.connect(ui.update_objects_count)
	edges.child_order_changed.connect(ui.update_objects_count)

	# Actualización de los nodos
	nodes.child_order_changed.connect(_update_nodes)
	_update_nodes()


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
	for child in nodes.get_children() + edges.get_children():
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


## Genera un grafo al azar
func _randomize() -> void:
	_delete_graph()

	const RANDOM_SIZE = 50
	const SPREAD_SIZE = 200

	var count = randi_range(1, RANDOM_SIZE)

	# Nodos
	for i in count:
		var new_node: GraphimNode = node_scene.instantiate()
		nodes.add_child(new_node, true)
		new_node.data.weight = randi_range(2, RANDOM_SIZE)
		new_node.data.refresh()
		new_node.position = Vector2(
			randf_range(-SPREAD_SIZE, SPREAD_SIZE),
			randf_range(-SPREAD_SIZE, SPREAD_SIZE)
		)

	# Conexiones
	for i in count:
		var node_a: GraphimNode = null
		var node_b: GraphimNode = null

		var max_attemps := 100000
		for j in max_attemps:
			node_a = nodes.get_children().pick_random()
			node_b = nodes.get_children().pick_random()
			if node_a != node_b: break

		var new_edge: GraphimEdge = edge_scene.instantiate()
		edges.add_child(new_edge, true)
		new_edge.data.directed = [true, false].pick_random()
		new_edge.data.weight = randi_range(1, RANDOM_SIZE)
		new_edge.data.start_node = node_a
		new_edge.data.end_node = node_b
		new_edge.data.refresh()


## Auxiliar: limpia la ruta del archivo de guardado
func _get_graph_data_path() -> String:
	return current_graph_data.resource_path.trim_prefix("user://graphs/")


#endregion


#region Manejo del grafo interno


## Actualiza las señales de los nodos
func _update_nodes() -> void:
	for node: GraphimNode in nodes.get_children():
		if not node.is_connected(&"clicked", _draw_edge): node.clicked.connect(_draw_edge)


## Dibuja una arista entre los dos nodos cuando se seleccionan
func _draw_edge(new_node: GraphimNode) -> void:
	if not drawing_edges: return

	# Añade el extremo inicial si es el caso
	if not current_new_edge_start:
		current_new_edge_start = new_node
		current_new_edge_start.data.color = Color.LIGHT_SKY_BLUE
		return

	# Añade el extremo final
	current_new_edge_end = new_node
	if current_new_edge_start == current_new_edge_end:
		# ? Aún no se soportan aristas en bucle. Así que se omiten
		_abort_new_edge()
		return

	# Verifica que la arista no este existiendo ya
	# ? Se separan los métodos para que sea fácil implementar bucles en el futuro
	if _find_edge(current_new_edge_start, current_new_edge_end): return
	if _find_edge_reverse(current_new_edge_start, current_new_edge_end): return

	current_new_edge_start.data.color = Color.WHITE

	# Crea y configura
	var new_edge: GraphimEdge = edge_scene.instantiate()
	edges.add_child(new_edge, true)
	new_edge.data.start_node = current_new_edge_start
	new_edge.data.end_node = current_new_edge_end
	new_edge.data.directed = drawing_directed
	new_edge.data.refresh()

	# Resetea los nodos para nueva arista
	current_new_edge_start = null
	current_new_edge_end = null


## Aborta el dibujado de la nueva arista
func _abort_new_edge() -> void:
	current_new_edge_end = null
	if current_new_edge_start != null:
		current_new_edge_start.data.color = Color.WHITE
		current_new_edge_start = null


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


#region Botones


## Actualiza el estado del dibujado de grafos
func _on_draw_button_pressed() -> void:
	drawing_edges = not drawing_edges
	directed_button.disabled = not drawing_edges

	if not drawing_edges: _abort_new_edge()

func _on_directed_button_pressed() -> void:
	drawing_directed = not drawing_directed


func _on_randomize_button_pressed() -> void:
	_randomize()


#endregion
