extends Node
var checks := 0
var failures: PackedStringArray = []
var app: Variant
func _ready() -> void:
	get_tree().create_timer(100).timeout.connect(func() -> void:get_tree().quit(1))
	call_deferred("_run")
func expect(value: bool,message: String) -> void:
	checks+=1
	if not value:failures.append(message);print("FAIL: "+message)
func frames() -> void:
	for i: int in range(4):await get_tree().process_frame
func touch(point: Vector2) -> void:
	var down := InputEventScreenTouch.new();down.index=7;down.position=point;down.pressed=true;get_viewport().push_input(down,true)
	var up := InputEventScreenTouch.new();up.index=7;up.position=point;get_viewport().push_input(up,true)
func answer_point(game: Variant,id: String) -> Vector2:
	return game.board.anchor(id) if game.board!=null else game.find_child("WorldItem_"+id,true,false).get_global_rect().get_center()
func complete_history(topic: String,locale: String,difficulty: String,revision: int=1) -> String:
	var items: Array[String]=["a","b","c","d","e"]
	var id: String=AssessmentHistory.begin_check(topic,revision,locale,difficulty,items)
	for item: String in items:AssessmentHistory.record(id,item,true,false,1,true)
	AssessmentHistory.finish(id,true)
	return id

func _run() -> void:
	var fixture := "user://test-runs/world-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload()
	SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("reduced_motion",true)
	expect(WorldCatalog.topics().size()==3,"Three separate initial world categories")
	for topic: Dictionary in WorldCatalog.topics():
		var items := WorldCatalog.items(topic.id)
		expect(items.size()==(12 if topic.id=="animals" else 20 if topic.id=="body" else 8),"Complete initial topic content")
		expect(topic.check_items.size()==5,"Fixed five-item comparable checks")
		for item: Dictionary in items:
			for locale: String in ["en","uk"]:
				expect(AudioManager.local_voice_available(item.word_key,locale) and AudioManager.local_voice_available(item.prompt_key,locale),"Every topic word/instruction is locally voiced in both languages")
	app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);await frames()
	expect(not GameManager.navigate("assessment_history"),"Child cannot directly access results history")
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale",locale);await frames()
		GameManager.navigate("activities");await frames();app.current_view.ensure_activity("world");await frames()
		app.current_view.find_child("WorldButton",true,false).pressed.emit();await frames()
		expect(GameManager.current_route=="world","Actual virtual-menu card opens a separate world hub")
		for difficulty: String in ["easy","normal","advanced"]:
			SettingsManager.set_value("difficulty",difficulty)
			for topic: Dictionary in WorldCatalog.topics():
				GameManager.world_topic=topic.id;GameManager.navigate("world_topic");await frames()
				var game: Variant=app.current_view;game.focus_paused=false
				if game.board!=null:
					game.explore_face=true;game.show_explore();await frames()
					expect(game.board.part_at(game.board.anchor("nose")-game.board.global_position)=="nose","Zoomed body board maps the visible nose")
					game.explore_face=false;game.show_explore();await frames()
					for item: Dictionary in game.entries:
						if true:expect(game.board.part_at(game.board.anchor(item.id)-game.board.global_position)==item.id,"Whole-body parts have correct touch anchors")
					expect(game.board.part_at(game.board.from_image(Vector2(439,183)))=="eyebrow","Visible brow stroke maps to eyebrow, not the head")
					expect(game.board.part_at(game.board.from_image(Vector2(132,823)))=="finger","The drawn thumb is a selectable finger")
					game.choose("hand");await frames()
					expect(game.board.zoom_hand and game.board.part_at(game.board.anchor("finger")-game.board.global_position)=="finger","Hand zoom exposes selectable fingers")
					game.choose("finger");await frames();expect(game.selected=="finger","Detailed finger can be named")
					game.toggle_hand_zoom();await frames();game.choose("torso");await frames()
					expect(game.selected=="torso" and not game.board.zoom_hand,"Torso is selectable in whole-body view")
				var before: int=AssessmentHistory.document.sessions.size()
				game.find_child("CheckMode",true,false).pressed.emit();await frames()
				var id: String=game.session_id
				expect(not id.is_empty() and AssessmentHistory.document.sessions.size()==before+1,"Starting a check records a new real session")
				for question: int in range(5):
					expect(game.options.size()=={"easy":2,"normal":3,"advanced":4}[difficulty],"Difficulty controls the actual selectable answers")
					expect(not game.assisted,"Each question begins without an invented hint")
					var candidate: Dictionary=game.get_idle_action()
					expect(candidate.has("from") and not game.assisted,"Computing a possible hint does not mark it shown")
					if question==1:
						app.idle_guide.reset();app.idle_guide._process(10.1)
						expect(game.assisted,"An actually displayed idle gesture marks this answer assisted")
					if question==2:
						var wrong: String=game.options[0] if game.options[0]!=game.target().id else game.options[1]
						touch(answer_point(game,wrong))
						expect(game.state==game.State.QUESTION and game.attempts==1,"Wrong response permits a calm retry")
					game.set_overlay_paused(true);game.choose(game.target().id)
					expect(game.state==game.State.QUESTION,"Parent pause blocks answers")
					game.set_overlay_paused(false)
					touch(answer_point(game,game.target().id))
					expect(game.state==game.State.FEEDBACK,"Real viewport input answers the target")
					if question==4:expect(AssessmentHistory.session(id).status=="completed","The final answer completes history immediately,even before praise animation ends")
					var stats_before: int=AssessmentHistory.session(id).answers.size()
					game.choose(game.target().id)
					expect(AssessmentHistory.session(id).answers.size()==stats_before,"Rapid duplicates never add a second question result")
					game.next_question();await frames()
				var row: Dictionary=AssessmentHistory.session(id)
				var stats: Dictionary=AssessmentHistory.metrics(row)
				expect(row.status=="completed" and stats.independent==3 and stats.assisted==1 and stats.retries==1,"First try,shown help and retries remain distinct")
				expect(game.has_node("CompletionParty"),"The completed check earns the common party")
				game._show_complete();expect(AssessmentHistory.session(id)==row,"Completion cannot duplicate or rewrite results")
				AssessmentHistory.reload();expect(AssessmentHistory.session(id)==JSON.parse_string(JSON.stringify(row)),"History survives disk reload with JSON number normalization")
				GameManager.navigate("world");await frames()
	# Comparable histories require language,level,revision andquestion set to match.
	var first := complete_history("plants","en","easy")
	var other_language := complete_history("plants","uk","easy")
	var other_level := complete_history("plants","en","advanced")
	var other_revision := complete_history("plants","en","easy",2)
	var last := complete_history("plants","en","easy")
	expect(AssessmentHistory.previous_comparable(last).id==first,"Comparison skips other languages,levels andcontent revisions")
	expect(AssessmentHistory.previous_comparable(other_language).is_empty() and AssessmentHistory.previous_comparable(other_level).is_empty() and AssessmentHistory.previous_comparable(other_revision).is_empty(),"Different check conditions are never presented as comparable")
	GameManager.world_topic="body";GameManager.navigate("world_topic");await frames();app.current_view.start_check();await frames()
	var interrupted: String=app.current_view.session_id
	GameManager.return_home();await frames()
	expect(AssessmentHistory.session(interrupted).status=="interrupted" and AssessmentHistory.previous_comparable(interrupted).is_empty(),"Leaving is incomplete,not a zero-score comparison")
	GameManager.parents_unlocked=true;GameManager.navigate("settings");await frames()
	app.current_view.find_child("OpenAssessmentHistory",true,false).pressed.emit();await frames()
	expect(GameManager.current_route=="assessment_history" and GameManager.parents_unlocked,"Adult settings opens protected history without another barrier")
	expect(app.current_view.table!=null and app.current_view.table.get_child_count()>6,"Actual history table renders completed andinterrupted checks")
	GameManager.return_home();await frames();expect(not GameManager.navigate("assessment_history"),"Returning to child flow locks history again")
	expect(ProgressManager.document.games.is_empty(),"Separate check history preserves old practice aggregates")
	app.queue_free();await frames()
	# Bounded retention,deep-copy getters,andfuture-schema protection.
	AssessmentHistory.storage_path=fixture+"/bounds.json";AssessmentHistory.reload()
	for i: int in range(103):complete_history("animals","en","easy")
	expect(AssessmentHistory.document.sessions.size()==100,"History retention is bounded to100checks")
	var saved: String=JSON.stringify(AssessmentHistory.document)
	var snapshot: Dictionary=AssessmentHistory.session(AssessmentHistory.document.sessions[0].id);snapshot.answers.clear()
	expect(JSON.stringify(AssessmentHistory.document)==saved,"Returned snapshots cannot mutate saved history")
	AssessmentHistory.storage_path=fixture+"/future.json"
	var file := FileAccess.open(AssessmentHistory.storage_path,FileAccess.WRITE);file.store_string('{"version":9,"sessions":[]}');file.close();AssessmentHistory.reload()
	var ids: Array[String]=["a","b","c","d","e"]
	expect(AssessmentHistory.begin_check("animals",1,"en","easy",ids)=="" and FileAccess.get_file_as_string(AssessmentHistory.storage_path)=='{"version":9,"sessions":[]}',"Newer history schemas are never overwritten")
	await AudioManager.shutdown()
	print("WORLD TESTS: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)
