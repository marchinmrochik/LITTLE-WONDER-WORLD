extends Node

const RATE := 22050
var generation_failed := false

func _ready() -> void:
	call_deferred("_generate")

func _generate() -> void:
	await get_tree().create_timer(0.2).timeout
	var audio := get_tree().root.get_node_or_null("AudioManager")
	if audio != null:
		await audio.shutdown()
	_write("res://assets/audio/sfx/tap.wav", 0.13, [659.25], false)
	_write("res://assets/audio/sfx/sparkle.wav", 0.8, [523.25, 659.25, 783.99], false)
	_write("res://assets/audio/sfx/rest.wav", 0.8, [392.0, 329.63], false)
	_write("res://assets/audio/music/meadow.wav", 16.0, [261.63, 329.63, 392.0, 493.88, 392.0, 329.63, 293.66, 392.0], true)
	print("Original foundation audio generated.")
	get_tree().quit(1 if generation_failed else 0)

func _write(path: String, seconds: float, notes: Array, is_music: bool) -> void:
	var count := int(seconds * RATE)
	var data := PackedByteArray()
	data.resize(count * 2)
	for index: int in range(count):
		var time := float(index) / RATE
		var sample := 0.0
		if is_music:
			for offset: int in range(notes.size()):
				var onset := float(offset) * 2.0
				var age := fposmod(time - onset, seconds)
				var envelope := minf(age / 0.03, 1.0) * exp(-age * 1.3)
				sample += sin(TAU * float(notes[offset]) * age) * envelope * 0.12
		else:
			for offset: int in range(notes.size()):
				var age := time - float(offset) * 0.11
				if age >= 0:
					sample += sin(TAU * float(notes[offset]) * age) * minf(age / 0.008, 1) * exp(-age * 9) * 0.22
		var fade := minf((seconds - time) / 0.05, 1.0) if not is_music else 1.0
		data.encode_s16(index * 2, int(clampf(sample * fade, -0.9, 0.9) * 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = data
	var error := stream.save_to_wav(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Audio generation failed: " + path)
		generation_failed = true
