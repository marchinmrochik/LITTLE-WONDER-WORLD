extends Node

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	await get_tree().create_timer(0.2).timeout
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] not in ["write", "read"] or not args[1].begins_with("user://test-runs/"):
		get_tree().quit(1)
		return
	SettingsManager.storage_path = args[1] + "/settings.json"
	ProgressManager.storage_path = args[1] + "/progress.json"
	SettingsManager.reload()
	AudioManager.apply_settings()
	await get_tree().create_timer(0.2).timeout
	ProgressManager.reload()
	if args[0] == "write":
		SettingsManager.set_value("locale", "uk")
		SettingsManager.set_value("difficulty", "advanced")
		SettingsManager.set_value("companion", "rabbit")
		SettingsManager.set_value("body_character", "girl")
		SettingsManager.set_value("music_enabled", false)
		AudioManager.apply_settings()
		await get_tree().create_timer(0.2).timeout
		ProgressManager.record_companion_visit()
		ProgressManager.record_answer("animals", "dog", true)
		ProgressManager.record_task_completed("animals")
		ProgressManager.record_session_completed("animals")
		print("PERSISTENCE WRITE: completed")
		await AudioManager.shutdown()
		get_tree().quit(0)
		return
	var valid: bool = SettingsManager.values.locale == "uk" and SettingsManager.values.difficulty == "advanced" and not SettingsManager.values.music_enabled and ProgressManager.document.companion_visits == 1 and ProgressManager.document.games.get("animals", {}).get("correct") == 1
	valid = valid and SettingsManager.values.companion=="rabbit" and SettingsManager.values.body_character=="girl"
	valid = valid and ProgressManager.document.games.get("animals", {}).get("completed_tasks") == 1 and ProgressManager.document.games.get("animals", {}).get("completed_sessions") == 1
	print("PERSISTENCE READ AFTER PROCESS RESTART: " + ("PASS" if valid else "FAIL"))
	await AudioManager.shutdown()
	get_tree().quit(0 if valid else 1)
