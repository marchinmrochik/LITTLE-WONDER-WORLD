extends Node

signal changed(key: String)
signal storage_failed

const DEFAULTS := {
	"version": 1, "locale": "en", "difficulty": "easy",
	"english_ukrainian_translation": false,
	"companion": "fox", "body_character": "boy",
	"music_volume": 0.25, "voice_volume": 0.8, "sfx_volume": 0.55,
	"music_enabled": true, "reduced_motion": false, "system_voice_enabled": false,
}

var values: Dictionary = DEFAULTS.duplicate(true)
var storage_path := "user://settings.json"
var load_status := "new"
var last_save_error: Error = OK

func _ready() -> void:
	reload()

func reload() -> void:
	last_save_error = OK
	var result := JsonStore.read_document(storage_path, is_valid_document)
	load_status = result.status
	values = DEFAULTS.duplicate(true)
	if not result.document.is_empty():
		values.merge(result.document, true)

func set_value(key: String, value: Variant) -> bool:
	if not DEFAULTS.has(key) or key == "version":
		return false
	var candidate := values.duplicate(true)
	candidate[key] = value
	if not is_valid_document(candidate):
		return false
	if values[key] == value:
		return true
	values = candidate
	var saved := save()
	changed.emit(key)
	return saved

func save() -> bool:
	if load_status == "incompatible":
		last_save_error = ERR_INVALID_DATA
	else:
		last_save_error = JsonStore.write_document(storage_path, values, is_valid_document)
	if last_save_error != OK:
		storage_failed.emit()
	return last_save_error == OK

func is_valid_document(value: Dictionary) -> bool:
	if value.get("version") != 1:
		return false
	if value.get("locale") not in ["en", "uk"] or value.get("difficulty") not in ["easy", "normal", "advanced"]:
		return false
	if value.get("companion","fox") not in ["fox","cat","dog","rabbit","bear","lion","elephant","duck","pig","sheep","horse"] or value.get("body_character","boy") not in ["boy","girl"]:
		return false
	for key: String in ["music_volume", "voice_volume", "sfx_volume"]:
		var amount: Variant = value.get(key)
		if not (amount is float or amount is int) or not is_finite(float(amount)) or amount < 0 or amount > 1:
			return false
	for key: String in ["music_enabled", "reduced_motion", "system_voice_enabled"]:
		if not value.get(key) is bool:
			return false
	if not value.get("english_ukrainian_translation",false) is bool:return false
	return true
