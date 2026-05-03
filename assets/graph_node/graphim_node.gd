## Nodo de grafo con comportamientos de arrastre
class_name GraphimNode extends DraggableObject


const GRAVITY_MIN_RADIUS_SQUARED := 2000


## Fuerza de repulsión
@export var repulsion_force: float = 4e6
## Fuerza de repulsión al centro
@export var center_repulsion: float = 0.05
## Fricción del movimiento
@export var damping: float = 0.2


@onready var data: NodeData = $Data
@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var label: Label = %Label
@onready var last_global_pos := global_position


## Desactiva el nodo y sus físicas. Usado para el DragInstancer
var disabled := false:
	set(value):
		if not is_node_ready(): await ready
		disabled = value
		_disable(value)

## Fuerza de la arista por la ley de Hooke
var hooke_force: Vector2


func _ready() -> void:
	# Conecta las señales para el arrastre y la actualización de datos
	dragging.connect(_set_drag_visuals)
	data.weight_changed.connect(_set_weight)
	data.color_changed.connect(_set_color)

	# Fuerza a actualiizar los datos
	data.refresh()


func _physics_process(delta: float) -> void:
	var current_pos := global_position

	# Aplica la fuerza sobre si mísmo y actualiza la posición
	_apply_repulsion(delta)
	last_global_pos = current_pos

	# Necesario para que funcione el arrastre con el mouse
	handle_dragging(delta)


## Activa o desactiva el nodo
func _disable(value: bool) -> void:
	input_pickable = not value
	collision_shape.disabled = value

	if value:
		remove_from_group(&"nodes")
	else:
		add_to_group(&"nodes")
		_reset_physics()


#region Visuales


## Cambia el color del nodo con posibilidad de tween para suavizado
func _change_color(_color: Color, tweened := false) -> void:
	if not tweened:
		sprite.modulate = _color
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", _color, Constants.EFFECT_TIME)


## Resalta un objeto
func _highlight(value: bool, tweened := false) -> void:
	var _color := Color.GRAY if value else Color.WHITE

	if not tweened:
		modulate = _color
		return

	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", _color, Constants.EFFECT_TIME)


## Establece el efecto visual al arrastrar el objeto
func _set_drag_visuals(value: bool) -> void:
	_highlight(value, true)

	if value: _expand()
	else: _contract()


#endregion


#region Tamaño del nodo


## Aumenta el tamaño del nodo y lo deja como antes
func _bump() -> void:
	await _expand().finished
	_contract()


## Expande el nodo
func _expand() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "scale", Vector2(1, 1) * Constants.BUMP_SCALE, Constants.EFFECT_TIME)
	return tween


## Contrae el nodo a su tamaño original
func _contract() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "scale", Vector2(1, 1), Constants.EFFECT_TIME)
	return tween


#endregion


#region Físicas


## Resetea la física del objeto (util al instanciar)
func _reset_physics() -> void:
	last_global_pos = global_position


## Aplica las fuerzas sobre el objeto
func _apply_repulsion(delta: float) -> void:
	if disabled: return

	var nodes := get_tree().get_nodes_in_group(&"nodes")
	var force := Vector2.ZERO

	# Calculamos la sumatoria de cada repulsión de los otros nodos
	for node: GraphimNode in nodes:
		if node == self: continue
		force += _coulomb(node.global_position)

	# Aplicamos la fuerza de gravedad al centro
	force += _apply_inverse_gravity()
	force += hooke_force

	# Limpiamos la fuerza para la siguiente iteración de las aristas
	hooke_force = Vector2.ZERO

	# Aplica Verlet con fricción sobre la velocidad (el desplazamiento)
	var inertia := (global_position - last_global_pos) * (1.0 - damping)
	var displacement := inertia + (force * delta * delta)

	# Usamos el motor de Godot para mover y detenernos si hay colisión
	move_and_collide(displacement)


## Aplica la gravedad a la inversa, empujando hacia el centro del mundo 2D
func _apply_inverse_gravity() -> Vector2:
	var distance := -global_position
	if distance.length_squared() < GRAVITY_MIN_RADIUS_SQUARED: return Vector2.ZERO

	return distance.normalized() * center_repulsion * distance.length_squared()


## Calcula la repulsión usando la ley de Coulomb para un punto dado (posición global)
func _coulomb(point_pos: Vector2) -> Vector2:
	var distance := global_position - point_pos

	# Evitamos división por cero y suavizamos la fuerza en distancias cortas (+ 100)
	return distance.normalized() * repulsion_force / (distance.length_squared() + 100.0)


#endregion


#region Setters


## Cambia el peso del nodo
func _set_weight(value: float) -> void:
	label.text = str(value)


## Cambia el color del nodo
func _set_color(new_color: Color) -> void:
	_bump()
	_change_color(new_color, true)


#endregion
