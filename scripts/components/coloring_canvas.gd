class_name ColoringCanvas
extends Control

signal region_pressed(point: Vector2)
var image: Image
var texture: ImageTexture
var paused := false
var pointer_owner := -2

func _ready() -> void:
	custom_minimum_size = Vector2(640, 400)
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)

func set_image(value: Image) -> void:
	image = value
	if texture == null:
		texture = ImageTexture.create_from_image(value)
	else:
		texture.update(value)
	queue_redraw()

func image_rect() -> Rect2:
	var scale_factor := minf(size.x / 1024, size.y / 640)
	var fitted := Vector2(1024, 640) * scale_factor
	return Rect2((size - fitted) * 0.5, fitted)

func _draw() -> void:
	if texture != null:
		draw_texture_rect(texture, image_rect(), false)
		draw_rect(image_rect(), Color("adc4ad"), false, 2)

func _gui_input(event: InputEvent) -> void:
	if paused or pointer_owner != -2:
		return
	var point := Vector2.ZERO
	if event is InputEventScreenTouch and event.pressed:
		pointer_owner = event.index
		point = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pointer_owner = -1
		point = event.position
	else:
		return
	var rect := image_rect()
	if rect.has_point(point):
		region_pressed.emit((point - rect.position) / rect.size * Vector2(1024, 640))
	accept_event()

func _input(event: InputEvent) -> void:
	if pointer_owner == -2:
		return
	if (event is InputEventScreenTouch and event.index == pointer_owner and not event.pressed) or (pointer_owner == -1 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed):
		pointer_owner = -2
		get_viewport().set_input_as_handled()

func set_paused(value: bool) -> void:
	paused = value
	if value:
		pointer_owner = -2
