class_name ChildButton
extends Button

var press_tween: Tween

func _ready() -> void:
	button_down.connect(_animate.bind(0.97))
	button_up.connect(_animate.bind(1.0))
	resized.connect(func() -> void: pivot_offset = size * 0.5)
	pivot_offset = size * 0.5
	pressed.connect(func() -> void: AudioManager.play_sfx("tap"))

func _animate(amount: float) -> void:
	if press_tween != null:
		press_tween.kill()
	if SettingsManager.values.reduced_motion:
		scale = Vector2.ONE
		return
	press_tween = create_tween()
	press_tween.tween_property(self, "scale", Vector2.ONE * amount, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
