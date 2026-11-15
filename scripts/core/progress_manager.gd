extends Node

signal changed
signal storage_failed

var storage_path := "user://progress.json"
var document: Dictionary = {"version": 1, "companion_visits": 0, "games": {}}
var load_status := "new"
var last_save_error: Error = OK

func _ready() -> void:
	reload()

func reload() -> void:
	last_save_error = OK
	var result := JsonStore.read_document(storage_path, is_valid_document)
	load_status = result.status
	document = {"version": 1, "companion_visits": 0, "games": {}}
	if not result.document.is_empty():
		document = result.document

func record_companion_visit() -> void:
	document.companion_visits += 1
	save()
	changed.emit()

func record_answer(game_id: String, topic_id: String, correct: bool, completes_task: bool = false) -> bool:
	if game_id.is_empty() or topic_id.is_empty():
		return false
	var game: Dictionary = document.games.get(game_id, {"attempts": 0, "correct": 0, "topics": {}})
	game.attempts += 1
	game.correct += int(correct)
	if correct and completes_task:
		game["completed_tasks"] = int(game.get("completed_tasks", 0)) + 1
	var topic: Dictionary = game.topics.get(topic_id, {"attempts": 0, "correct": 0})
	topic.attempts += 1
	topic.correct += int(correct)
	game.topics[topic_id] = topic
	document.games[game_id] = game
	var saved := save()
	changed.emit()
	return saved

func reset_progress() -> bool:
	var previous := document.duplicate(true)
	document = {"version": 1, "companion_visits": 0, "games": {}}
	if not save():
		document = previous
		return false
	changed.emit()
	return true

func record_task_completed(game_id: String) -> bool:
	return _increment_game_counter(game_id, "completed_tasks")

func record_session_completed(game_id: String) -> bool:
	return _increment_game_counter(game_id, "completed_sessions")

func _increment_game_counter(game_id: String, counter: String) -> bool:
	if game_id.is_empty():
		return false
	var game: Dictionary = document.games.get(game_id, {"attempts": 0, "correct": 0, "topics": {}})
	game[counter] = int(game.get(counter, 0)) + 1
	document.games[game_id] = game
	var saved := save()
	changed.emit()
	return saved

func save() -> bool:
	last_save_error = ERR_INVALID_DATA if load_status == "incompatible" else JsonStore.write_document(storage_path, document, is_valid_document)
	if last_save_error != OK:
		storage_failed.emit()
	return last_save_error == OK

func is_valid_document(value: Dictionary) -> bool:
	if value.get("version") != 1 or not _is_count(value.get("companion_visits")) or not value.get("games") is Dictionary:
		return false
	for id: Variant in value.games:
		var game: Variant = value.games[id]
		if not id is String or str(id).is_empty() or not game is Dictionary or not _valid_counts(game) or not game.get("topics") is Dictionary:
			return false
		for counter: String in ["completed_tasks", "completed_sessions"]:
			if game.has(counter) and not _is_count(game[counter]):
				return false
		for topic: Variant in game.topics.values():
			if not topic is Dictionary or not _valid_counts(topic):
				return false
	return true

func _valid_counts(value: Dictionary) -> bool:
	return _is_count(value.get("attempts")) and _is_count(value.get("correct")) and value.correct <= value.attempts

func _is_count(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= 0 and value == floor(value)
