## Controla las físicas de las nodos para su distribución
class_name Physics extends Node


## Constante de escala para la distancia entre los nodos
const K_SCALE := 2 / pow(12, 0.25)
## Constante de escala de movimiento
const MOVE_SCALE := 100


## Constante de empaquetamiento
@export_range(0.01, 10.0) var alpha: float = 1.0:
	set(value):
		alpha = value
		_update_ell()
## Fuerza de gravedad
@export_range(0.0, 10.0) var gravity: float = 1.0


## Lista de nodos
@onready var nodes: Node2D = %Nodes
## Lista de aristas
@onready var edges: Node2D = %Edges


## Longitud ideal actual entre nodos
static var current_ell := 0.0
## Longitud al cuadrado
static var current_ell_sq := 0.0
## Longitud ideal inversa
static var current_ell_inv := 0.0


func _ready() -> void:
	# Conecta la actualización de la distancia ideal
	nodes.child_order_changed.connect(_update_ell)
	get_viewport().size_changed.connect(_update_ell)

	_update_ell()


func _physics_process(delta: float) -> void:
	var graph_nodes := nodes.get_children()
	var graph_edges := edges.get_children()

	if not graph_nodes: return

	# Repulsión
	for i in nodes.get_child_count():
		var node_i: GraphimNode = graph_nodes[i]

		for j in i:
			var node_j: GraphimNode = graph_nodes[j]
			var ji := node_i.global_position - node_j.global_position
			var ji_repulsion := ji / ji.length_squared()

			node_i.repulsion += ji_repulsion
			node_j.repulsion -= ji_repulsion

	# Atracción entre nodos
	for edge: GraphimEdge in graph_edges:
		var node_i := edge.data.start_node
		var node_j := edge.data.end_node

		var ji := node_i.global_position - node_j.global_position
		var ji_atraction := ji * ji.length()

		# ? Se restan las fuerzas (invertido respecto a la repulsión más arriba)
		node_i.atraction -= ji_atraction
		node_j.atraction += ji_atraction

	# Gravedad inversa y aplicación
	for node: GraphimNode in graph_nodes:
		# Aplica la gravedad antes para evitar que MOVE_SCALE la haga extrema
		var global_pos := node.global_position
		node.force -= gravity * global_pos.normalized() * global_pos.length_squared()

		node.integrate_forces(delta)


## Auxiliar: recalcula la distancia ideal
func _update_ell() -> void:
	var viewport := get_viewport()
	if not viewport: return

	var size := viewport.get_visible_rect().size
	var max_diameter := minf(size.x, size.y)
	var max_circle_area := PI * max_diameter * max_diameter / 4

	current_ell = K_SCALE * sqrt(max_circle_area / nodes.get_child_count()) / alpha
	current_ell_sq = current_ell * current_ell
	current_ell_inv = 1 / current_ell
