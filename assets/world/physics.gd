## Controla las físicas de las nodos para su distribución
class_name Physics extends Node


## Constante de escala para la distancia entre los nodos
const K_SCALE := 2 / pow(12, 0.25)
## Constante de escala de movimiento
const MOVE_SCALE := 1e6


## Constante de empaquetamiento
@export_range(0.01, 10.0) var alpha: float = 1.0:
	set(value):
		alpha = value
		_update_ell()
## Fuerza de gravedad
@export_range(0.0, 20.0) var gravity: float = 1.0


## Lista de nodos
@onready var nodes: Node2D = %Nodes
## Lista de aristas
@onready var edges: Node2D = %Edges


## Longitud ideal actual entre nodos
var current_ell := 0.0


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
			var distance_ji := node_i.global_position - node_j.global_position
			var distance_sq := maxf(distance_ji.length_squared(), Constants.EPSILON)
			var inverse_distance := distance_ji.normalized() / distance_sq

			node_i.force += current_ell * inverse_distance
			node_j.force -= current_ell * inverse_distance

	# Atracción entre nodos
	for edge: GraphimEdge in graph_edges:
		var node_a := edge.data.start_node
		var node_b := edge.data.end_node

		var distance_ba := node_a.global_position - node_b.global_position
		var force := distance_ba / (current_ell * current_ell)

		node_a.force -= force
		node_b.force += force

	# Gravedad inversa y aplicación
	for node: GraphimNode in graph_nodes:
		node.force *= MOVE_SCALE

		# Aplica la gravedad antes para evitar que MOVE_SCALE la haga extrema
		var global_pos := node.global_position
		node.force -= gravity * global_pos.normalized() * global_pos.length_squared()
		node.apply_forces(delta)


## Auxiliar: recalcula la distancia ideal
func _update_ell() -> void:
	var viewport := get_viewport()
	if not viewport: return

	var size := viewport.get_visible_rect().size
	var max_diameter := minf(size.x, size.y)
	var max_circle_area := PI * max_diameter * max_diameter / 4

	current_ell = K_SCALE * sqrt(max_circle_area / nodes.get_child_count()) / alpha
