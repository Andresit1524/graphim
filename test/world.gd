class_name World extends Node2D


## Constante de repulsión para simplificar el valor de la fuerza
const REPULSION_CONST = 1e6


@export_group("Nodes physics")
## Fuerza de repulsión
@export var nodes_repulsion: float = 4
## Fuerza de repulsión al centro
@export var center_atraction: float = 0.05
## Fricción del movimiento
@export var friction: float = 0.2

@export_group("Edges physics")
## Longitud de la arista
@export var edge_length: float = 200.0
## Fuerza de Hooke para los nodos que conecta
@export var edge_force: float = 50

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

## Datos actuales del grafo
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


func _physics_process(delta: float) -> void:
	_make_and_apply_forces(delta)


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


#region Físicas


## Aplica las fuerzas sobre todos los nodos
func _make_and_apply_forces(delta: float) -> void:
	var graph_nodes := nodes.get_children()
	var graph_edges := edges.get_children()

	# Resetea y aplica gravedad inversa
	for node: GraphimNode in graph_nodes:
		node.force = _apply_inverse_gravity(node)

	# Repulsión y gravedad inversa entre los nodos aprovechando la simetria de Coulomb
	for i in graph_nodes.size():
		for j in i:
			var node_a = graph_nodes[i]
			var node_b = graph_nodes[j]
			var current_force := _coulomb(node_b.global_position, node_a.global_position)

			node_a.force += current_force
			node_b.force += -current_force

	# Atracción entre nodos de una arista
	for edge: GraphimEdge in graph_edges:
		var start := edge.data.start_node
		var end := edge.data.end_node
		var current_force := _hooke(start, end)

		start.force -= current_force / 2
		end.force += current_force / 2

	# Aplica la fuerza a cada nodo
	for node: GraphimNode in graph_nodes:
		node.apply_forces(delta, friction)


## Calcula la repulsión usando la ley de Coulomb para un par de posiciones globales
func _coulomb(from: Vector2, to: Vector2) -> Vector2:
	var distance := to - from

	# Evitamos división por cero y suavizamos la fuerza en distancias cortas (+ 100)
	return distance.normalized() * nodes_repulsion * REPULSION_CONST / (distance.length_squared() + 100.0)


## Calcula la fuerza que conecta dos nodos usando la ley de hooke
func _hooke(from: GraphimNode, to: GraphimNode) -> Vector2:
	var distance := to.global_position - from.global_position
	var force := (distance.normalized() * edge_length - distance) * edge_force

	return force


## Aplica la gravedad a la inversa, empujando hacia el centro del mundo 2D
func _apply_inverse_gravity(node: GraphimNode) -> Vector2:
	var distance := -node.global_position
	if distance.length_squared() < Constants.EPSILON: return Vector2.ZERO

	return distance.normalized() * center_atraction * distance.length_squared()


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
