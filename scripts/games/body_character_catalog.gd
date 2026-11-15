class_name BodyCharacterCatalog
extends RefCounted
static var content: Dictionary={}
static func definition(id: String="") -> Dictionary:
	if content.is_empty():content=JSON.parse_string(FileAccess.get_file_as_string("res://data/game_content/body_characters.json"))
	if id.is_empty():id=SettingsManager.values.body_character
	return content.characters.get(id,content.characters.boy)
static func apply(items: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary]=[];var character := definition()
	for original: Dictionary in items:
		var entry := original.duplicate(true)
		entry.areas=character.areas[entry.id].duplicate(true);entry.illustration=character.texture;entry.art_region=character.crops[entry.id].duplicate()
		result.append(entry)
	return result
