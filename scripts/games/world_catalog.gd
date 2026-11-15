class_name WorldCatalog
extends RefCounted
static var registry: Array[Dictionary] = []
static var loaded: Dictionary = {}

static func topics() -> Array[Dictionary]:
	if registry.is_empty():
		var data: Variant=JSON.parse_string(FileAccess.get_file_as_string("res://data/game_content/world_topics.json"))
		if data is Dictionary and data.get("version")==1:
			for topic: Dictionary in data.get("topics",[]):registry.append(topic)
	return registry

static func topic(id: String) -> Dictionary:
	for entry: Dictionary in topics():
		if entry.id==id:return entry
	return {}

static func items(id: String) -> Array[Dictionary]:
	if not loaded.has(id):
		var definition := topic(id)
		if definition.is_empty():return []
		var data: Variant=JSON.parse_string(FileAccess.get_file_as_string(definition.catalog))
		var result: Array[Dictionary]=[]
		if data is Dictionary and data.get("version")==1:
			for item: Dictionary in data.get("items",[]):result.append(item)
		loaded[id]=result
	var result: Array[Dictionary]=[]
	result.assign(loaded[id])
	return BodyCharacterCatalog.apply(result) if id=="body" else result

static func item(topic_id: String,id: String) -> Dictionary:
	for entry: Dictionary in items(topic_id):
		if entry.id==id:return entry
	return {}
