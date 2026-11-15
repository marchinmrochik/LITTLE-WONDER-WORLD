class_name PaintCanvas
extends Control

signal stroke_committed
var document := PaintDocument.new()
var texture: ImageTexture
var pointer_owner := -2
var paused := false
var needs_upload := true

func _ready() -> void:
	clip_contents = true
	texture = ImageTexture.create_from_image(document.image)
	custom_minimum_size = Vector2(640, 400)
	resized.connect(queue_redraw)

func image_rect() -> Rect2:
	var scale_factor := minf(size.x / PaintDocument.SIZE.x, size.y / PaintDocument.SIZE.y)
	var fitted := Vector2(PaintDocument.SIZE) * scale_factor
	return Rect2((size - fitted) * 0.5, fitted)

func _draw() -> void:
	if texture != null:
		draw_texture_rect(texture, image_rect(), false)
		draw_rect(image_rect(), Color("adc4ad"), false, 2)

func _process(_delta: float) -> void:
	if needs_upload and texture != null:
		texture.update(document.image)
		needs_upload = false
		queue_redraw()

func refresh() -> void:
	needs_upload = true

func _logical(point: Vector2) -> Vector2:
	var rect := image_rect()
	return (point - rect.position) / rect.size * Vector2(PaintDocument.SIZE)

func _gui_input(event: InputEvent) -> void:
	if paused or pointer_owner != -2:
		return
	if event is InputEventScreenTouch and event.pressed and image_rect().has_point(event.position):
		_begin(event.index, event.position)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and image_rect().has_point(event.position):
		_begin(-1, event.position)
		accept_event()

func _begin(pointer: int, point: Vector2) -> void:
	if document.begin(_logical(point)):
		pointer_owner = pointer
		refresh()

func _input(event: InputEvent) -> void:
	if pointer_owner == -2:
		return
	var point := Vector2.ZERO
	var moved := false
	var ended := false
	if event is InputEventScreenDrag and event.index == pointer_owner:
		point = event.position
		moved = true
	elif event is InputEventScreenTouch and event.index == pointer_owner and not event.pressed:
		point = event.position
		ended = true
		moved = not event.canceled
	elif pointer_owner == -1 and event is InputEventMouseMotion:
		point = event.position
		moved = true
	elif pointer_owner == -1 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		point = event.position
		ended = true
		moved = true
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		ended = true
	else:
		return
	if moved:
		var local := get_global_transform_with_canvas().affine_inverse() * point
		document.move(_logical(local))
		refresh()
	if ended:
		finish_stroke()
	get_viewport().set_input_as_handled()

func finish_stroke() -> void:
	pointer_owner = -2
	if document.finish():
		refresh()
		stroke_committed.emit()

func set_paused(value: bool) -> void:
	if value:
		finish_stroke()
	paused = value
