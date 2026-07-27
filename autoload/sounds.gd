extends AudioStreamPlayer


## Lista de sonidos
@export var sounds: Dictionary[StringName, AudioStream] = {
	&"pop": load("res://assets/sounds/pop.mp3"),
	&"pencil": load("res://assets/sounds/pencil.mp3"),
	&"delete": load("res://assets/sounds/swipe.mp3"),
	&"shuffle": load("res://assets/sounds/shuffle.mp3"),
	&"success": load("res://assets/sounds/success.mp3"),
	&"fail": load("res://assets/sounds/wrong.mp3")
}


var playback: AudioStreamPlaybackPolyphonic


func _ready() -> void:
	# Creamos y asignamos el stream polifónico por código si no lo hiciste en el inspector
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = 128 # O el número que prefieras
	play()
	playback = get_stream_playback()


## Reproduce un sonido
func play_sound(sound: StringName) -> void:
	var pitch = randf_range(0.9, 1.1)
	var volumen = randf_range(-2.0, 2.0) # en decibelios

	if playback and sound:
		playback.play_stream(sounds[sound], 0.0, volumen, pitch)
