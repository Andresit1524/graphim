class_name World extends Node2D


## Se emite cuando se cambia el archivo actual
signal current_file(new_name: String)


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


func _ready() -> void:
	# Conecta la interfaz a las funciones del grafo
	ui.buttons.delete_graph.connect(_delete_graph)
	ui.buttons.save_graph_on_current.connect(_save_graph_data)
	ui.buttons.save_graph_as.connect(_save_graph_data_as)
	ui.buttons.load_graph.connect(_load_graph_data)

	current_file.connect(ui.set_file_name)


#region Manejo del GraphData


## Actualiza el recurso de grafo actual usando los datos del nodo
func _save_graph_data() -> void:
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
		current_file.emit("Grafo en escena")
		return

	# Guarda en archivo
	var error := ResourceSaver.save(current_graph_data)
	print(
		"[World] Guardado en archivo %s con código de error %s"
		% [_get_graph_data_path(), error]
	)
	current_file.emit(_get_graph_data_path())


## Guarda los datos de grafo actual en un nuevo archivo
func _save_graph_data_as() -> void:
	save_load_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_load_dialog.popup_centered()

	await save_load_dialog.file_selected
	current_graph_data.resource_path = save_load_dialog.current_path
	print("[World] Guardando datos en %s" % _get_graph_data_path())
	_save_graph_data()


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
func _load_graph_data() -> void:
	# Busca en el menú de archivos a por el archivo que el usuario quiera y lo carga
	save_load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	save_load_dialog.popup_centered()
	await save_load_dialog.file_selected
	current_graph_data = ResourceLoader.load(save_load_dialog.current_path)

	print("[World] Cargando datos desde %s" % _get_graph_data_path())
	current_file.emit(_get_graph_data_path())

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
