extends Node
func _ready() -> void:call_deferred("_run")
func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size()!=2 or not args[1].begins_with("user://test-runs/history-probe-") or ".." in args[1]:get_tree().quit(1);return
	SettingsManager.storage_path=args[1]+"/settings.json";SettingsManager.reload();SettingsManager.set_value("music_enabled",false)
	AudioManager.apply_settings()
	await get_tree().create_timer(0.2).timeout
	AssessmentHistory.storage_path=args[1]+"/history.json";AssessmentHistory.reload()
	var items: Array[String]=["eye","nose","arm","leg","foot"]
	var valid := false
	if args[0]=="write":
		var first: String=AssessmentHistory.begin_check("body",1,"uk","easy",items)
		AssessmentHistory.record(first,"eye",true,false,1,true)
		AssessmentHistory.record(first,"nose",true,true,1,true)
		AssessmentHistory.record(first,"arm",false,false,1,false);AssessmentHistory.record(first,"arm",false,false,2,true)
		AssessmentHistory.record(first,"leg",true,false,1,true);AssessmentHistory.record(first,"foot",true,false,1,true)
		AssessmentHistory.finish(first,true)
		var next: String=AssessmentHistory.begin_check("body",1,"uk","easy",items)
		for item: String in items:AssessmentHistory.record(next,item,true,false,1,true)
		valid=AssessmentHistory.finish(next,true) and AssessmentHistory.previous_comparable(next).id==first
	elif args[0]=="read":
		var rows: Array=AssessmentHistory.document.sessions
		valid=rows.size()==2 and rows[0].status=="completed" and rows[1].status=="completed"
		if valid:valid=AssessmentHistory.metrics(rows[0]).independent==3 and AssessmentHistory.metrics(rows[0]).assisted==1 and AssessmentHistory.metrics(rows[0]).retries==1 and AssessmentHistory.metrics(rows[1]).independent==5 and AssessmentHistory.previous_comparable(rows[1].id).id==rows[0].id
	await AudioManager.shutdown()
	print("HISTORY PERSISTENCE "+args[0].to_upper()+": "+("PASS" if valid else "FAIL"))
	get_tree().quit(0 if valid else 1)
