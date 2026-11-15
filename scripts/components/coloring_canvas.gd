class_name ColoringCanvas
extends Control

signal region_pressed(point: Vector2)
var image: Image
var texture: ImageTexture
var paused := false
var pointer_owner := -2
var source_bounds := Rect2(0,0,1024,640)

func _ready() -> void:
	custom_minimum_size = Vector2(240, 180)
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
	var scale_factor := minf(size.x / source_bounds.size.x, size.y / source_bounds.size.y)
	var fitted := source_bounds.size * scale_factor
	return Rect2((size - fitted) * 0.5, fitted)

func _draw() -> void:
	if texture != null:
		draw_style_box(UiKit.panel(Color.WHITE,16,0),Rect2(Vector2.ZERO,size))
		draw_texture_rect_region(texture,image_rect(),source_bounds)
		draw_style_box(_border(),Rect2(Vector2.ZERO,size))

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
		region_pressed.emit(source_bounds.position+(point - rect.position) / rect.size * source_bounds.size)
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

func _border() -> StyleBoxFlat:
	var style := UiKit.panel(Color(0,0,0,0),16,0);style.border_color=Color("adc4ad");style.set_border_width_all(2);return style
