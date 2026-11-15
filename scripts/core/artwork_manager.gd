extends Node

signal changed
const MAX_ENTRIES := 200
const MAX_GALLERY_BYTES := 268435456
const MAX_PNG_BYTES := 4194304
var directory := "user://artwork"
var entries: Array[Dictionary] = []
var status := "new"
var last_error: Error = OK
var pending_open_id := ""

func _ready() -> void:
	reload()

func reload() -> void:
	entries.clear()
	last_error = OK
	var result := JsonStore.read_document(directory + "/index.json", _valid_index)
	status = result.status
	if status == "incompatible":
		return
	for entry: Dictionary in result.document.get("entries", []):
		entries.append(entry)
	# A PNG published just before an interrupted index update is recoverable.
	var dir := DirAccess.open(directory + "/gallery")
	if dir != null:
		for file: String in dir.get_files():
			var id := file.trim_suffix(".png")
			if file.ends_with(".png") and valid_id(id) and not _has(id) and entries.size() < MAX_ENTRIES:
				entries.append({"id":id,"created":0})
				status = "recovered"

func _has(id: String) -> bool:
	return entries.any(func(entry: Dictionary) -> bool: return entry.id == id)

func valid_id(id: String) -> bool:
	if id.length() > 60 or id.count("_") != 1:
		return false
	var parts := id.split("_")
	if parts[0].is_empty() or parts[1].is_empty():
		return false
	for part: String in parts:
		for character: int in part.to_ascii_buffer():
			if character < 48 or character > 57:
				return false
	return true

func _valid_index(value: Dictionary) -> bool:
	if value.get("version") != 1 or not value.get("entries") is Array or value.entries.size() > MAX_ENTRIES:
		return false
	var seen := {}
	for entry: Variant in value.entries:
		if not entry is Dictionary or not entry.get("id") is String or not valid_id(entry.id) or seen.has(entry.id) or not (entry.get("created") is int or entry.get("created") is float):
			return false
		seen[entry.id] = true
		if entry.has("coloring") and (not entry.coloring is Dictionary or not ColoringDocument.valid_state(entry.coloring)):
			return false
	return true

func _write_index() -> Error:
	return JsonStore.write_document(directory + "/index.json", {"version":1,"entries":entries}, _valid_index)

func gallery_bytes() -> int:
	var total := 0
	var dir := DirAccess.open(directory + "/gallery")
	if dir != null:
		for file: String in dir.get_files():
			if file.ends_with(".png") or file.ends_with(".png.new"):
				var stream := FileAccess.open(directory + "/gallery/" + file, FileAccess.READ)
				if stream != null:
					total += stream.get_length()
	return total

func save_artwork(image: Image, coloring: Dictionary = {}) -> String:
	last_error = OK
	if status == "incompatible" or not _valid_image(image):
		last_error = ERR_INVALID_DATA
		return ""
	if not coloring.is_empty() and not ColoringDocument.valid_state(coloring):
		last_error = ERR_INVALID_DATA
		return ""
	var bytes := image.save_png_to_buffer()
	if entries.size() >= MAX_ENTRIES or bytes.size() > MAX_PNG_BYTES or gallery_bytes() + bytes.size() > MAX_GALLERY_BYTES:
		last_error = ERR_OUT_OF_MEMORY
		return ""
	var id := "%d_%d" % [int(Time.get_unix_time_from_system() * 1000), Time.get_ticks_usec()]
	while _has(id) or FileAccess.file_exists(directory + "/gallery/" + id + ".png"):
		id = "%d_%d" % [int(Time.get_unix_time_from_system() * 1000), Time.get_ticks_usec() + 1]
	var path := directory + "/gallery/" + id + ".png"
	last_error = _publish(path, bytes, false)
	if last_error != OK:
		return ""
	entries.append({"id":id,"created":int(Time.get_unix_time_from_system())})
	if not coloring.is_empty():
		entries.back()["coloring"] = coloring.duplicate(true)
	last_error = _write_index()
	if last_error != OK:
		entries.pop_back()
		DirAccess.remove_absolute(path)
		return ""
	status = "ok"
	changed.emit()
	return id

func artwork_route(id: String) -> String:
	for entry: Dictionary in entries:
		if entry.id == id:
			return "coloring" if entry.has("coloring") else "drawing"
	return "drawing"

func coloring_state(id: String) -> Dictionary:
	for entry: Dictionary in entries:
		if entry.id == id and entry.has("coloring"):
			return entry.coloring.duplicate(true)
	return {}

func _valid_color_draft(value: Dictionary) -> bool:
	if value.get("version") != 1 or not value.get("pages") is Dictionary or value.pages.size() > 10 or not value.get("last_page") is String or ColoringDocument.page_for(value.last_page).is_empty():
		return false
	for id: Variant in value.pages:
		if not id is String or not value.pages[id] is Dictionary or value.pages[id].get("page") != id or not ColoringDocument.valid_state(value.pages[id]):
			return false
	return true

func load_color_draft() -> Dictionary:
	var result := JsonStore.read_document(directory + "/coloring-draft.json", _valid_color_draft)
	return result.document

func save_color_draft(value: Dictionary) -> bool:
	var existing := JsonStore.read_document(directory + "/coloring-draft.json", _valid_color_draft)
	if status == "incompatible" or existing.status == "incompatible":
		last_error = ERR_INVALID_DATA
		return false
	last_error = JsonStore.write_document(directory + "/coloring-draft.json", value, _valid_color_draft)
	return last_error == OK

func save_draft(image: Image,slot: String="") -> bool:
	if slot not in ["","draw-word"]:return false
	if status == "incompatible" or not _valid_image(image):
		last_error = ERR_INVALID_DATA
		return false
	last_error = _publish(directory + ("/draft.png" if slot.is_empty() else "/draw-word-draft.png"), image.save_png_to_buffer(), true)
	return last_error == OK

func load_draft(slot: String="") -> Image:
	if slot not in ["","draw-word"]:return null
	var path := directory + ("/draft.png" if slot.is_empty() else "/draw-word-draft.png")
	var image := _read_png(path)
	return image if image != null else _read_png(path+".bak")

func load_artwork(id: String) -> Image:
	if not valid_id(id) or not _has(id):
		return null
	return _read_png(directory + "/gallery/" + id + ".png")

func thumbnail(id: String) -> Texture2D:
	var image := load_artwork(id)
	if image == null:
		return null
	image.resize(192, 120, Image.INTERPOLATE_BILINEAR)
	return ImageTexture.create_from_image(image)

func remove_artwork(id: String) -> bool:
	if status == "incompatible" or not valid_id(id) or not _has(id):
		last_error = ERR_INVALID_DATA
		return false
	var previous := entries.duplicate(true)
	entries = entries.filter(func(entry: Dictionary) -> bool: return entry.id != id)
	last_error = _write_index()
	if last_error != OK:
		entries = previous
		return false
	var path := directory + "/gallery/" + id + ".png"
	if FileAccess.file_exists(path):
		last_error = DirAccess.remove_absolute(path)
		if last_error != OK:
			entries = previous
			_write_index()
			return false
	changed.emit()
	return true

func _publish(path: String, bytes: PackedByteArray, backup: bool) -> Error:
	if bytes.is_empty() or bytes.size() > MAX_PNG_BYTES:
		return ERR_INVALID_DATA
	var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	if error != OK:
		return error
	var file := FileAccess.open(path + ".new", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_buffer(bytes)
	file.flush()
	error = file.get_error()
	file.close()
	if error != OK:
		return error
	if backup and _read_png(path) != null:
		error = DirAccess.copy_absolute(path, path + ".bak.new")
		if error == OK:
			error = DirAccess.rename_absolute(path + ".bak.new", path + ".bak")
		if error != OK:
			return error
	return DirAccess.rename_absolute(path + ".new", path)

func _valid_image(image: Image) -> bool:
	return image != null and image.get_size() == PaintDocument.SIZE

func _read_png(path: String) -> Image:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() < 24 or file.get_length() > MAX_PNG_BYTES:
		return null
	var bytes := file.get_buffer(file.get_length())
	if bytes.slice(0, 8) != PackedByteArray([137,80,78,71,13,10,26,10]) or bytes.slice(12, 16).get_string_from_ascii() != "IHDR":
		return null
	# Bound dimensions before decoding compressed pixels.
	if _u32(bytes, 16) != PaintDocument.SIZE.x or _u32(bytes, 20) != PaintDocument.SIZE.y:
		return null
	var image := Image.new()
	if image.load_png_from_buffer(bytes) != OK or not _valid_image(image):
		return null
	image.convert(Image.FORMAT_RGBA8)
	return image

func _u32(bytes: PackedByteArray, offset: int) -> int:
	return (int(bytes[offset]) << 24) | (int(bytes[offset + 1]) << 16) | (int(bytes[offset + 2]) << 8) | int(bytes[offset + 3])

# Only a path explicitly returned by the parent's system save dialog is used.
func export_artwork(id: String, destination: String) -> Error:
	var image := load_artwork(id)
	if image == null or destination.is_empty() or destination.begins_with("res://"):
		return ERR_INVALID_PARAMETER
	var resolved := ProjectSettings.globalize_path(destination).simplify_path().replace("\\", "/")
	var internal := ProjectSettings.globalize_path(directory).simplify_path().replace("\\", "/")
	if resolved.to_lower() == internal.to_lower() or resolved.to_lower().begins_with(internal.to_lower()+"/"):
		return ERR_INVALID_PARAMETER
	if not destination.begins_with("content://") and not destination.get_extension().to_lower() == "png":
		return ERR_INVALID_PARAMETER
	var bytes := image.save_png_to_buffer()
	if bytes.is_empty():return ERR_INVALID_DATA
	# Android document-provider URIs are opened directly by Godot's FileAccess.
	if destination.begins_with("content://"):
		var output := FileAccess.open(destination,FileAccess.WRITE)
		if output == null:return FileAccess.get_open_error()
		output.store_buffer(bytes);output.flush()
		var error := output.get_error();output.close();return error
	return _publish(destination,bytes,false)
