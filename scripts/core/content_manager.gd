extends Node

var manifest: Dictionary = {}
var issues: PackedStringArray = []
var animals: Array[Dictionary] = []
var colors: Array[Dictionary] = []
var foods: Array[Dictionary] = []
var shapes: Array[Dictionary] = []
var puzzles: Array[Dictionary] = []
var memory: Array[Dictionary] = []
var counting: Array[Dictionary] = []

func _ready() -> void:
	var file := FileAccess.open("res://data/game_content/foundation.json", FileAccess.READ)
	if file == null:
		issues.append("Foundation manifest missing")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		manifest = parsed
	else:
		issues.append("Foundation manifest invalid")
		return
	validate()
	animals = AnimalCatalog.load_catalog()
	colors = AnimalCatalog.load_catalog("res://data/game_content/colors.json", "colors")
	foods = AnimalCatalog.load_catalog("res://data/game_content/foods.json", "foods")
	shapes = AnimalCatalog.load_catalog("res://data/game_content/shapes.json", "shapes")
	puzzles = AnimalCatalog.load_catalog("res://data/game_content/puzzles.json", "puzzles")
	memory = AnimalCatalog.load_catalog("res://data/game_content/memory.json", "memory")
	counting = AnimalCatalog.load_catalog("res://data/game_content/counting.json", "counting")

func animal(id: String) -> Dictionary:
	for entry: Dictionary in animals:
		if entry.id == id:
			return entry
	return {}

func validate() -> PackedStringArray:
	issues.clear()
	if manifest.get("version") != 1:
		issues.append("Invalid foundation schema version")
	for category: String in ["sfx", "music"]:
		var entries: Variant = manifest.get(category)
		if not entries is Dictionary:
			issues.append("Missing resource category: " + category)
			continue
		var required: Array = ["tap", "sparkle", "rest"] if category == "sfx" else ["meadow"]
		for id: String in required:
			if not entries.get(id) is String:
				issues.append("Missing resource ID: " + id)
				continue
			var path: String = entries[id]
			if not path.begins_with("res://assets/") or not ResourceLoader.exists(path):
				issues.append("Missing resource: " + path)
	if not manifest.get("voice") is Dictionary:
		issues.append("Missing voice manifest")
		return issues
	for locale: String in ["en", "uk"]:
		for key: String in ["FOX_HELLO", "FOX_HAPPY", "FOX_REST"]:
			var voices: Variant = manifest.voice.get(key)
			if not voices is Dictionary or not voices.get(locale) is String:
				issues.append("Missing explicit voice status: " + key + ":" + locale)
				continue
			var path: String = voices[locale]
			if not path.is_empty() and (not path.begins_with("res://assets/") or not ResourceLoader.exists(path)):
				issues.append("Missing speech resource: " + path)
			if not LocalizationManager.messages.get(locale, {}).has(key):
				issues.append("Missing voice text: " + locale + ":" + key)
	return issues

func audio_path(category: String, id: String) -> String:
	return str(manifest.get(category, {}).get(id, ""))

func voice_path(key: String, locale: String) -> String:
	return str(manifest.get("voice", {}).get(key, {}).get(locale, ""))
