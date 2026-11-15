class_name AnimalCatalog
extends RefCounted

static func load_catalog(path: String = "res://data/game_content/animals.json", collection: String = "animals") -> Array[Dictionary]:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or parsed.get("version") != 1 or not parsed.get(collection) is Array:
		return []
	var entries: Array[Dictionary] = []
	for entry: Variant in parsed[collection]:
		if not entry is Dictionary:
			return []
		entries.append(entry)
	return entries

static func validate(entries: Array[Dictionary], require_audio: bool = true, minimum_entries: int = 12) -> PackedStringArray:
	var errors: PackedStringArray = []
	var seen := {}
	if entries.size() < minimum_entries:
		errors.append("Insufficient catalog entries")
	for entry: Dictionary in entries:
		var valid := true
		for key: String in ["id", "english", "ukrainian", "illustration", "word_key", "prompt_key", "word_audio", "prompt_audio"]:
			if not entry.get(key) is String or str(entry.get(key, "")).is_empty():
				errors.append("Missing animal field: " + key)
				valid = false
		if not valid:
			continue
		if seen.has(entry.id):
			errors.append("Duplicate animal ID: " + entry.id)
		seen[entry.id] = true
		for key: String in ["illustration", "word_audio", "prompt_audio"]:
			if not require_audio and key != "illustration":
				continue
			var path: String = entry[key]
			if not path.begins_with("res://assets/") or ".." in path or not ResourceLoader.exists(path):
				errors.append("Missing animal resource: " + path)
	return errors
