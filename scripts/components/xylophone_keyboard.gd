class_name XylophoneKeyboard
extends Control

signal note_struck(index: int)
const COLORS := [Color("d85e63"),Color("e9a050"),Color("e8c35b"),Color("80b280"),Color("67adba"),Color("719dcb"),Color("9980bc"),Color("d893b6")]
const NAMES := ["C", "D", "E", "F", "G", "A", "B", "C"]
var pointers: Dictionary = {}
var pulses := PackedFloat32Array([0,0,0,0,0,0,0,0])
var paused := false
var highlighted := -1

func _ready() -> void:
	custom_minimum_size = Vector2(640, 360)
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)

func key_rect(index: int) -> Rect2:
	var width := size.x / 8.0
	var height := size.y * (0.91 - index * 0.045)
	return Rect2(Vector2(index * width + 5, (size.y - height) * 0.5), Vector2(width - 10, height))

func key_at(point: Vector2) -> int:
	for index: int in range(8):
		if key_rect(index).has_point(point):
			return index
	return -1

func _draw() -> void:
	for fraction: float in [0.3, 0.7]:
		draw_line(Vector2(8,size.y*fraction),Vector2(size.x-8,size.y*fraction),Color("b7946a"),14,true)
	var font := ThemeDB.fallback_font
	for index: int in range(8):
		var rect := key_rect(index)
		var held := index in pointers.values()
		var shift := 5.0 if held else pulses[index] * 3.0
		var shadow := StyleBoxFlat.new()
		shadow.bg_color = Color("496557")
		shadow.set_corner_radius_all(18)
		draw_style_box(shadow,Rect2(rect.position + Vector2(0,7),rect.size))
		var bar := StyleBoxFlat.new()
		bar.bg_color = COLORS[index].lightened(0.17 if held else pulses[index]*0.12)
		bar.set_corner_radius_all(18)
		bar.border_color = Color("496557")
		bar.border_color=Color("f4cf58") if highlighted==index else Color("496557")
		bar.set_border_width_all(6 if highlighted==index else 2)
		rect.position.y += shift
		draw_style_box(bar,rect)
		for fraction: float in [0.18,0.82]:
			draw_circle(Vector2(rect.get_center().x,rect.position.y+rect.size.y*fraction),5,Color("496557"))
		var label: String = NAMES[index]
		draw_string(font,Vector2(rect.get_center().x-font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,30).x/2,rect.get_center().y+11),label,HORIZONTAL_ALIGNMENT_LEFT,-1,30,Color("233f35"))

func _process(delta: float) -> void:
	var changing := false
	for index: int in range(8):
		if pulses[index] > 0:
			pulses[index] = maxf(0,pulses[index]-delta*4)
			changing = true
	if changing:
		queue_redraw()

func update_pointer(id: int, point: Vector2, beginning: bool = false) -> void:
	if paused or (not beginning and not pointers.has(id)):
		return
	var note := key_at(point)
	if beginning and note < 0:
		return
	var previous: int = pointers.get(id,-1)
	pointers[id] = note
	if note >= 0 and (beginning or note != previous):
		pulses[note] = 0 if SettingsManager.values.reduced_motion else 1
		note_struck.emit(note)
	queue_redraw()

func release_pointer(id: int) -> void:
	pointers.erase(id)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if paused:
		return
	# Godot may synthesize a mouse event from touch; never strike twice.
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if event is InputEventScreenTouch:
		if event.pressed and not event.canceled:
			update_pointer(event.index,event.position-global_position,true)
		else:
			release_pointer(event.index)
	elif event is InputEventScreenDrag:
		update_pointer(event.index,event.position-global_position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			update_pointer(-1,event.position-global_position,true)
		else:
			release_pointer(-1)
	elif event is InputEventMouseMotion:
		update_pointer(-1,event.position-global_position)

func set_paused(value: bool) -> void:
	paused = value
	if value:
		pointers.clear()
		pulses.fill(0)
	queue_redraw()
