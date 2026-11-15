extends Control

var fox: FoxieView
var greeting: Label
var stars: HBoxContainer

func _ready() -> void:
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var content := UiKit.column(10)
	center.add_child(content)
	var title := UiKit.label("MEADOW_TITLE", 36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)
	var bubble := UiKit.card(Color("fffdf0"))
	bubble.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(bubble)
	greeting = UiKit.label("FOX_HELLO", 27, UiKit.GREEN)
	bubble.add_child(greeting)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(400, 330)
	content.add_child(fox)
	stars = UiKit.row(18)
	stars.alignment = BoxContainer.ALIGNMENT_CENTER
	stars.custom_minimum_size.y = 40
	content.add_child(stars)
	for index: int in range(3):
		var star := TextureRect.new()
		star.texture = preload("res://assets/ui/star.svg")
		star.custom_minimum_size = Vector2(32, 32)
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.modulate.a = 0.3
		stars.add_child(star)
	var actions := UiKit.row(24)
	content.add_child(actions)
	for item: Array in [["SAY_HELLO", "wave", "FOX_HELLO"], ["SPARKLE", "star", "FOX_HAPPY"], ["REST", "moon", "FOX_REST"]]:
		var action := UiKit.button(item[0], interact.bind(item[2]), UiKit.CREAM, item[1])
		action.name = item[0]
		action.custom_minimum_size = Vector2(220, 84)
		actions.add_child(action)

func interact(key: String) -> void:
	var quiet := key == "FOX_REST"
	fox.react(quiet)
	greeting.text = LocalizationManager.text(key)
	AudioManager.set_resting(quiet)
	AudioManager.play_sfx("rest" if quiet else "sparkle")
	AudioManager.say(key)
	for star: Control in stars.get_children():
		star.modulate.a = 1.0 if key == "FOX_HAPPY" else 0.3
