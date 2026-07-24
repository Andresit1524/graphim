class_name World extends Node2D


## Se emite cuando se cambia el archivo actual
signal current_file_changed(new_name: String)


## Tamaño máximo de un grafo aleatorio
const RANDOM_SIZE = 50
## Espacio para aleatorizar la posición de los nodos
const SPREAD_SIZE = 300
## Retraso entre adición de nodos-aristas nuevos
const DELAY = 0.01


@export_group("Dependencies")
## Escena de un nodo
@export var node_scene: PackedScene
## Escena de una arista
@export var edge_scene: PackedScene


## Interfaz
@onready var ui: UI = %UI
## Botón para dibujar aristas
@onready var directed_edges_checkbox: CheckBox = %DirectedEdgesCheckbox
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

	# Conexión para nuevos nodos
	nodes.child_entered_tree.connect(_connect_new_node)
	edges.child_entered_tree.connect(_connect_new_edge)


#region Manejo del GraphData


## Actualiza el recurso de grafo actual usando los datos del nodo
func _save_graph() -> void:
	# Guarda en los datos de grafo
	current_graph_data.nodes_data.assign(
		nodes.get_children().map(func(c: GraphimNode): return c.get_data_copy())
	)
	current_graph_data.edges_data.assign(
		edges.get_children().map(func(c: GraphimEdge): return c.get_data_copy())
	)

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

	print("[World] Guardando datos en %s" % _get_graph_data_path())
	current_graph_data.resource_path = save_load_dialog.current_path
	_save_graph()


## Elimina el grafo actual
func _delete_graph() -> void:
	print("[World] Borrando grafo")

	for child in nodes.get_children() + edges.get_children():
		Sounds.play_sound(&"delete")
		child.queue_free()

	print("[World] Borrado")


## Carga el grafo desde un archivo
func _load_graph() -> void:
	# Busca en el menú de archivos a por el archivo que el usuario quiera y lo carga
	save_load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	save_load_dialog.popup_centered()
	await save_load_dialog.file_selected

	print("[World] Cargando datos desde %s" % _get_graph_data_path())
	current_graph_data = ResourceLoader.load(save_load_dialog.current_path)
	current_file_changed.emit(_get_graph_data_path())

	_delete_graph()

	# Nodos
	var uids := {}
	for node_data: NodeData in current_graph_data.nodes_data:
		await get_tree().create_timer(DELAY).timeout
		var new_node: GraphimNode = node_scene.instantiate()
		nodes.add_child(new_node, true)
		new_node.data = node_data

		uids[new_node.data.uid] = new_node
		new_node.global_position = Vector2(
			randf_range(-SPREAD_SIZE, SPREAD_SIZE),
			randf_range(-SPREAD_SIZE, SPREAD_SIZE)
		)

	# Aristas
	for edge_data: EdgeData in current_graph_data.edges_data:
		var new_edge: GraphimEdge = edge_scene.instantiate()
		edges.add_child(new_edge, true)
		new_edge.data = edge_data

		# Busca los nodos por su UID y vincula los extremos
		new_edge.data.start_node = uids.get(new_edge.data.start_uid)
		new_edge.data.end_node = uids.get(new_edge.data.end_uid)
		new_edge.data.refresh()

	print("[World] Cargado")


## Genera un grafo al azar
func _randomize() -> void:
	ui.disable_all()
	_delete_graph()

	var node_count = randi_range(5, RANDOM_SIZE)
	var edge_count = randi_range(node_count, node_count * 2)

	# Nodos
	var new_nodes: Array[GraphimNode]
	for i in node_count:
		await get_tree().create_timer(DELAY).timeout
		var new_node: GraphimNode = node_scene.instantiate()
		nodes.add_child(new_node)
		new_nodes.append(new_node)

		new_node.data.weight = randi_range(2, RANDOM_SIZE)
		new_node.position = Vector2(
			randf_range(-SPREAD_SIZE, SPREAD_SIZE),
			randf_range(-SPREAD_SIZE, SPREAD_SIZE)
		)

	# Pares de nodos
	var pairs := []
	for i in new_nodes.size():
		for j in range(i + 1, new_nodes.size()):
			pairs.append([new_nodes[i], new_nodes[j]])
	pairs.shuffle()

	# Aristas
	for i in edge_count:
		var pair = pairs.pick_random()
		pairs.erase(pair)

		var node_a: GraphimNode = pair[0]
		var node_b: GraphimNode = pair[1]

		await get_tree().create_timer(DELAY).timeout
		var new_edge: GraphimEdge = edge_scene.instantiate()
		edges.add_child(new_edge, true)
		new_edge.data.directed = [true, false].pick_random()
		new_edge.data.weight = randi_range(1, RANDOM_SIZE)
		new_edge.data.start_node = node_a
		new_edge.data.end_node = node_b
		new_edge.data.refresh()

	ui.enable_all()


## Auxiliar: limpia la ruta del archivo de guardado
func _get_graph_data_path() -> String:
	return current_graph_data.resource_path.trim_prefix("user://graphs/")


#endregion


#region Manejo del grafo interno


## Actualiza las conexiones del nodo nuevo
func _connect_new_node(node: Node) -> void:
	var _node := node as GraphimNode

	if not _node.is_connected(&"clicked", _draw_edge):
		_node.clicked.connect(_draw_edge)
		# TODO: implementar menú contextual

	if not _node.is_connected(&"deleted", _delete_node):
		_node.deleted.connect(_delete_node)


## Actualiza las conexiones de una arista nueva
func _connect_new_edge(edge: Node) -> void:
	var _edge := edge as GraphimEdge

	# TODO: Implementar clicked también

	if not _edge.is_connected(&"deleted", _delete_edge):
		edge.deleted.connect(_delete_edge)


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
	# ! que?
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
		if (
			edge.data.start_node == end_node and edge.data.end_node == start_node
			and not edge.data.directed
		): return edge

	return null


## Elimina un nodo y todas las aristas que dependen de él
func _delete_node(node: GraphimNode) -> void:
	# Elimina aristas conectadas
	for edge: GraphimEdge in edges.get_children():
		if edge.data.end_node == node or edge.data.start_node == node:
			edge.queue_free()

	node.queue_free()
	Sounds.play_sound(&"delete")


## Elimina una arista
func _delete_edge(edge: GraphimEdge) -> void:
	edge.queue_free()
	Sounds.play_sound(&"delete")


#endregion


#region Botones


# TODO: mandar esto a la UI


## Actualiza el estado del dibujado de aristas
func _on_draw_edges_button_toggled(toggled_on: bool) -> void:
	drawing_edges = toggled_on
	directed_edges_checkbox.disabled = not toggled_on

	if not toggled_on: _abort_new_edge()


## Actualiza el estado del dibujado de aristas dirigidas
func _on_directed_edges_checkbox_toggled(toggled_on: bool) -> void:
	drawing_directed = toggled_on


#endregion
