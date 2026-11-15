class_name ColoringDocument
extends RefCounted

static var pages: Array[Dictionary] = []
var page: Dictionary = {}
var colors: Dictionary = {}
var history: Array[Dictionary] = []
var cursor := 0
const HISTORY_LIMIT := 64

static func catalog() -> Array[Dictionary]:
	if pages.is_empty():
		var file := FileAccess.open("res://data/game_content/coloring.json", FileAccess.READ)
		if file == null:
			return []
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if not parsed is Dictionary or parsed.get("version") != 1:
			return []
		for item: Dictionary in parsed.get("pages", []):
			for region: Dictionary in item.regions:
				region.polygon = _polygon(region.polygon)
				region.tap = Vector2(region.tap[0], region.tap[1])
			var masks: Array[PackedVector2Array] = []
			for polygon: Array in item.locks:
				masks.append(_polygon(polygon))
			item.locks = masks
			pages.append(item)
	return pages

static func _polygon(points: Array) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for point: Array in points:
		polygon.append(Vector2(point[0], point[1]))
	return polygon

static func page_for(id: String) -> Dictionary:
	for item: Dictionary in catalog():
		if item.id == id:
			return item
	return {}

static func valid_state(value: Dictionary) -> bool:
	if value.get("version") != 1 or not value.get("page") is String or not value.get("colors") is Dictionary:
		return false
	var item := page_for(value.page)
	if item.is_empty() or value.colors.size() > item.regions.size():
		return false
	var ids := {}
	for region: Dictionary in item.regions:
		ids[region.id] = true
	for id: Variant in value.colors:
		if not id is String or not ids.has(id) or not value.colors[id] is String:
			return false
		if not valid_paint(value.colors[id]): return false
	return true

static func valid_paint(value: String) -> bool:
	var parts := value.split(":")
	if parts.size()!=1 and (parts.size()!=3 or parts[0]!="gradient"): return false
	for hex: String in ([value] if parts.size()==1 else [parts[1],parts[2]]):
		if hex.length()!=6: return false
		for character: int in hex.to_ascii_buffer():
			if not (character>=48 and character<=57 or character>=97 and character<=102): return false
	return true

func _init(id: String = "cat") -> void:
	page = page_for(id)
	for region: Dictionary in page.get("regions", []):
		colors[region.id] = "ffffff"

func region_at(point: Vector2) -> String:
	if not point.is_finite() or not Rect2(0, 0, 1024, 640).has_point(point):
		return ""
	for mask: PackedVector2Array in page.locks:
		if Geometry2D.is_point_in_polygon(point, mask):
			return ""
	for index: int in range(page.regions.size() - 1, -1, -1):
		var region: Dictionary = page.regions[index]
		var polygon: PackedVector2Array = region.polygon
		if Geometry2D.is_point_in_polygon(point, polygon):
			# Tapping the ink outline must not fill a neighboring region below it.
			for i: int in range(polygon.size()):
				if point.distance_to(Geometry2D.get_closest_point_to_segment(point, polygon[i], polygon[(i + 1) % polygon.size()])) < 3.1:
					return ""
			return region.id
	return ""

func fill_at(point: Vector2, color: Color) -> bool:
	return fill_paint(point,color.to_html(false))

func fill_paint(point: Vector2, paint: String) -> bool:
	if not valid_paint(paint): return false
	var id := region_at(point)
	if id.is_empty():
		return false
	var hex := paint
	if colors[id] == hex:
		return false
	_record({id:colors[id]}, {id:hex})
	return true

func reset() -> bool:
	if is_blank():
		return false
	var cleared := {}
	for id: String in colors:
		cleared[id] = "ffffff"
	_record(colors.duplicate(), cleared)
	return true

func is_blank() -> bool:
	return colors.values().all(func(hex: String) -> bool: return hex == "ffffff")

func _record(before: Dictionary, after: Dictionary) -> void:
	history.resize(cursor)
	history.append({"before":before,"after":after})
	if history.size() > HISTORY_LIMIT:
		history.pop_front()
	cursor = history.size()
	colors.merge(after, true)

func undo() -> bool:
	if cursor == 0:
		return false
	cursor -= 1
	colors.merge(history[cursor].before, true)
	return true

func redo() -> bool:
	if cursor == history.size():
		return false
	colors.merge(history[cursor].after, true)
	cursor += 1
	return true

func state() -> Dictionary:
	return {"version":1,"page":page.id,"colors":colors.duplicate()}

func restore(value: Dictionary) -> bool:
	if not valid_state(value):
		return false
	page = page_for(value.page)
	colors.clear()
	for region: Dictionary in page.regions:
		colors[region.id] = value.colors.get(region.id, "ffffff")
	history.clear()
	cursor = 0
	return true

func render_image() -> Image:
	var svg: String = page.template
	var definitions := "<defs>"
	for id: String in colors:
		var paint: String=colors[id]
		if paint.begins_with("gradient:"):
			var parts := paint.split(":")
			definitions+='<linearGradient id="g_'+id+'" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#'+parts[1]+'"/><stop offset="1" stop-color="#'+parts[2]+'"/></linearGradient>'
			paint="url(#g_"+id+")"
		else: paint="#"+paint
		svg = svg.replace("{{" + id + "}}", paint)
	var start := svg.find(">")+1
	svg=svg.insert(start,definitions+"</defs>")
	var image := Image.new()
	if image.load_svg_from_string(svg) != OK:
		return null
	image.convert(Image.FORMAT_RGBA8)
	return image
