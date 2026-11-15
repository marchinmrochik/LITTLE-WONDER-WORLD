class_name JsonStore
extends RefCounted

const MAX_BYTES := 524288

static func read_document(path: String, validator: Callable) -> Dictionary:
	if not FileAccess.file_exists(path) and not FileAccess.file_exists(path + ".bak"):
		return {"status": "new", "document": {}}
	var primary: Variant = _read(path)
	if primary is Dictionary and primary.get("version", 1) != 1:
		return {"status": "incompatible", "document": {}}
	for candidate: String in [path, path + ".bak"]:
		var value: Variant = _read(candidate)
		if value is Dictionary and validator.call(value):
			return {"status": "ok" if candidate == path else "recovered", "document": value}
	return {"status": "unreadable", "document": {}}

static func write_document(path: String, document: Dictionary, validator: Callable) -> Error:
	if not validator.call(document):
		return ERR_INVALID_DATA
	var parent := ProjectSettings.globalize_path(path.get_base_dir())
	var error := DirAccess.make_dir_recursive_absolute(parent)
	if error != OK:
		return error
	error = _write(path + ".new", document)
	if error != OK:
		return error
	if FileAccess.file_exists(path):
		var previous: Variant = _read(path)
		if previous is Dictionary and validator.call(previous):
			error = DirAccess.copy_absolute(path, path + ".bak.new")
			if error == OK:
				error = DirAccess.rename_absolute(path + ".bak.new", path + ".bak")
		else:
			# Preserve unreadable data before a user-initiated replacement.
			error = DirAccess.copy_absolute(path, path + ".invalid")
		if error != OK:
			return error
	return DirAccess.rename_absolute(path + ".new", path)

static func _read(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	if file.get_length() > MAX_BYTES:
		return null
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return null
	return parser.data

static func _write(path: String, document: Dictionary) -> Error:
	var serialized := JSON.stringify(document, "\t")
	if serialized.to_utf8_buffer().size() > MAX_BYTES:
		return ERR_OUT_OF_MEMORY
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(serialized)
	file.flush()
	var error := file.get_error()
	file.close()
	return error
