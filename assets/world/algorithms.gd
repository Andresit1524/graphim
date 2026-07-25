## Clase que gestiona los algoritmos y su interfaz
class_name Algorithms extends Node


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

		alg_button.toggled.connect(_on_algorithm_button_toggled.bind(algorithm))
		algorithm.aborted.connect(alg_button.set_pressed_no_signal.bind(false))

		alg_button.text = algorithm.button_name
		alg_button.autowrap_mode = TextServer.AUTOWRAP_WORD
		alg_button.toggle_mode = true


## Actúa cuando se presiona un botón
func _on_algorithm_button_toggled(on: bool, algorithm: BaseAlgorithm) -> void:
	if on:
		ui.disable_all()
		algorithm.start()
		return

	algorithm.abort()
