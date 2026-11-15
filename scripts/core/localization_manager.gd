extends Node

signal locale_changed
var messages: Dictionary = {}

func _ready() -> void:
	for locale: String in ["en", "uk"]:
		var file := FileAccess.open("res://data/localization/" + locale + ".json", FileAccess.READ)
		if file == null:
			push_error("Missing localization: " + locale)
			continue
		var data: Variant = JSON.parse_string(file.get_as_text())
		if not data is Dictionary:
			push_error("Invalid localization: " + locale)
			continue
		messages[locale] = data
		var translation := Translation.new()
		translation.locale = locale
		for key: String in data:
			translation.add_message(key, str(data[key]))
		TranslationServer.add_translation(translation)
	TranslationServer.set_locale(SettingsManager.values.locale)
	SettingsManager.changed.connect(_on_settings_changed)

func text(key: String) -> String:
	return str(TranslationServer.translate(key))

func object_name(entry: Dictionary) -> String:
	return str(entry.get("ukrainian" if SettingsManager.values.locale == "uk" else "english", ""))

func _on_settings_changed(key: String) -> void:
	if key == "locale":
		TranslationServer.set_locale(SettingsManager.values.locale)
		locale_changed.emit()
