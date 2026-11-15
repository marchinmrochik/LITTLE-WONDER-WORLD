class_name LetterCatalog
extends RefCounted
static var content: Dictionary = {}
static func load_data() -> Dictionary:
	if content.is_empty(): content=JSON.parse_string(FileAccess.get_file_as_string("res://data/game_content/letters.json"))
	return content
