class_name PaintDocument
extends RefCounted

const SIZE := Vector2i(1024, 640)
const COLORS := [Color("d95b59"), Color("ec984b"), Color("efce55"), Color("6ba46f"), Color("578dc2"), Color("9672b7"), Color("e995b4"), Color("986b49"), Color("354940")]
const TOOLS := ["regular", "soft", "rainbow", "eraser"]
var image := Image.create(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
var tool := "regular"
var color := COLORS[0]
var gradient_to := Color.WHITE
var gradient_enabled := false
var radius := 10
var active := false
var history: Array[Dictionary] = []
var cursor := 0
var history_bytes := 0
var history_limit := 24
var byte_limit := 33554432
var revision := 0
var before: Image
var dirty := Rect2i()
var last := Vector2.ZERO
var distance := 0.0
var stamps: Dictionary = {}

func _init() -> void:
	image.fill(Color.WHITE)

func begin(point: Vector2) -> bool:
	if active or not point.is_finite() or not Rect2(Vector2.ZERO, Vector2(SIZE)).has_point(point):
		return false
	before = image.duplicate()
	dirty = Rect2i()
	last = point
	distance = 0
	active = true
	_stamp(point)
	return true

func move(point: Vector2) -> void:
	if not active or not point.is_finite():
		return
	point = point.clamp(Vector2(SIZE) * -2, Vector2(SIZE) * 3)
	var segment := _clip(last, point)
	last = point
	if segment.is_empty():
		return
	var length := segment[0].distance_to(segment[1])
	var steps := maxi(1, ceili(length / maxf(1, minf(5, radius * 0.35))))
	for step: int in range(1, steps + 1):
		distance += length / steps
		_stamp(segment[0].lerp(segment[1], step / float(steps)))

func finish(commit: bool = true) -> bool:
	if not active:
		return false
	active = false
	if not commit:
		image = before
		before = null
		return false
	var previous := before.get_region(dirty)
	var current := image.get_region(dirty)
	before = null
	if previous.get_data() == current.get_data():
		return false
	_add_history(dirty, previous, current)
	return true

func clear() -> bool:
	finish()
	if is_blank():
		return false
	var previous := image.duplicate()
	image.fill(Color.WHITE)
	_add_history(Rect2i(Vector2i.ZERO, SIZE), previous, image.duplicate())
	return true

func load_image(value: Image) -> bool:
	if value == null or value.get_size() != SIZE:
		return false
	finish(false)
	image = value.duplicate()
	image.convert(Image.FORMAT_RGBA8)
	history.clear()
	cursor = 0
	history_bytes = 0
	revision += 1
	return true

func is_blank() -> bool:
	var bytes := image.get_data()
	return bytes.count(255) == bytes.size()

func undo() -> bool:
	if active or cursor == 0:
		return false
	cursor -= 1
	var entry := history[cursor]
	image.blit_rect(entry.before, Rect2i(Vector2i.ZERO, entry.rect.size), entry.rect.position)
	revision += 1
	return true

func redo() -> bool:
	if active or cursor == history.size():
		return false
	var entry := history[cursor]
	image.blit_rect(entry.after, Rect2i(Vector2i.ZERO, entry.rect.size), entry.rect.position)
	cursor += 1
	revision += 1
	return true

func _add_history(rect: Rect2i, previous: Image, current: Image) -> void:
	while history.size() > cursor:
		history_bytes -= int(history.pop_back().bytes)
	var bytes := rect.get_area() * 8
	history.append({"rect":rect,"before":previous,"after":current,"bytes":bytes})
	history_bytes += bytes
	while history.size() > history_limit or history_bytes > byte_limit:
		history_bytes -= int(history.pop_front().bytes)
	cursor = history.size()
	revision += 1

func _stamp(point: Vector2) -> void:
	var ink: Color = Color.WHITE if tool == "eraser" else Color.from_hsv(fmod(floor(distance / 18.0), 36) / 36.0, 0.62, 0.91) if tool == "rainbow" else color
	if gradient_enabled and tool in ["regular","soft"]:
		# Quantize the smooth ramp to bound brush-cache churn on low-power devices.
		ink=color.lerp(gradient_to,roundf(pingpong(distance/240.0,1.0)*24)/24.0)
	var key := "%s:%s:%d" % [tool, ink.to_html(), radius]
	if not stamps.has(key):
		if stamps.size() >= 64:
			stamps.clear()
		var diameter := radius * 2 + 2
		var stamp := Image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
		stamp.fill(Color.TRANSPARENT)
		for y: int in range(diameter):
			for x: int in range(diameter):
				var length := Vector2(x - radius, y - radius).length()
				var alpha := pow(clampf(1 - length / radius, 0, 1), 2) * 0.35 if tool == "soft" else clampf(radius + 0.5 - length, 0, 1)
				stamp.set_pixel(x, y, Color(ink, alpha))
		stamps[key] = stamp
	var stamp: Image = stamps[key]
	var destination := Rect2i(Vector2i(point.round()) - Vector2i(radius, radius), stamp.get_size())
	var clipped := Rect2i(Vector2i.ZERO, SIZE).intersection(destination)
	if clipped.has_area():
		image.blend_rect(stamp, Rect2i(clipped.position - destination.position, clipped.size), clipped.position)
		dirty = dirty.merge(clipped) if dirty.has_area() else clipped

func _clip(a: Vector2, b: Vector2) -> Array[Vector2]:
	var d := b - a
	var p := [-d.x, d.x, -d.y, d.y]
	var q := [a.x, SIZE.x - 1 - a.x, a.y, SIZE.y - 1 - a.y]
	var low := 0.0
	var high := 1.0
	for i: int in range(4):
		if absf(p[i]) < 0.00001:
			if q[i] < 0:
				return []
		else:
			var t: float = q[i] / p[i]
			if p[i] < 0:
				low = maxf(low, t)
			else:
				high = minf(high, t)
			if low > high:
				return []
	return [a + d * low, a + d * high]
