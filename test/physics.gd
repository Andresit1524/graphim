## [code]Physics[/code] controla las físicas de la escena tales como la repulsión de los nodos
class_name Physics extends Node


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
## Lista de nodos
@export var nodes: Node2D
## Lista de aristas
@export var edges: Node2D


func _physics_process(delta: float) -> void:
	_make_and_apply_forces(delta)


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

		# Validamos que los nodos de la arista sigan existiendo en memoria
		if not is_instance_valid(start) or not is_instance_valid(end): continue

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
