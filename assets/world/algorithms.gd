## Clase que gestiona los algoritmos y su interfaz
class_name Algorithms extends Node


## Grupo de botones
@export var alg_buttons_group: ButtonGroup


## Mundo
@onready var world: Node2D = get_tree().current_scene
## Botones para los algoritmos
@onready var algoritm_buttons: VBoxContainer = %AlgoritmButtons
## Interfaz
@onready var ui: UI = %UI


func _ready() -> void:
	for algorithm: BaseAlgorithm in get_children():
		# Crea el botón
		var alg_button := Button.new()
		algoritm_buttons.add_child(alg_button)

		alg_button.button_group = alg_buttons_group
		alg_button.toggled.connect(_on_algorithm_button_toggled.bind(algorithm))
		algorithm.finished.connect(alg_button.set_pressed_no_signal.bind(false))

		alg_button.text = algorithm.button_name
		alg_button.autowrap_mode = TextServer.AUTOWRAP_WORD
		alg_button.toggle_mode = true


## Actúa cuando se presiona un botón
func _on_algorithm_button_toggled(on: bool, algorithm: BaseAlgorithm) -> void:
	if not on:
		algorithm.finish()
		return

	ui.disable_all()

	# ? El await no es redundante porque el algoritmo lo puede tener
	@warning_ignore("redundant_await")
	await algorithm.start()
