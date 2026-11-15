extends Node

var app: Variant
var captures := 0
var issues: PackedStringArray = []
var output := "res://.local/qa/release"
const ROUTES := ["animals","colors","feeding","shapes","puzzles","memory","counting","drawing","coloring","xylophone"]

func _ready() -> void:
	call_deferred("_run")

func frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame

func capture(label: String, suffix: String) -> void:
	await frames()
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path(output+"/"+label+"_"+suffix+".png")
	if get_viewport().get_texture().get_image().save_png(path) != OK:
		issues.append("Capture failed: "+path)
	check_bounds(app,label+":"+suffix)
	captures += 1

func check_bounds(node: Node, context: String, scrolling: bool = false) -> void:
	if node is ScrollContainer:
		scrolling = true
	if not scrolling and node is BaseButton and node.is_visible_in_tree():
		if not get_viewport().get_visible_rect().grow(1).encloses(node.get_global_rect()):
			issues.append(context+": button outside viewport: "+str(node.name))
	for child: Node in node.get_children():
		check_bounds(child,context,scrolling)

func _run() -> void:
	get_window().title = "Little Wonder World - Release QA"
	var fixture := "user://test-runs/release-render-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture+"/settings.json"
	ProgressManager.storage_path = fixture+"/progress.json"
	ArtworkManager.directory = fixture+"/artwork"
	SettingsManager.reload()
	ProgressManager.reload()
	ArtworkManager.reload()
	SettingsManager.set_value("music_enabled",false)
	SettingsManager.set_value("voice_volume",0.0)
	SettingsManager.set_value("reduced_motion",true)
	SettingsManager.set_value("difficulty","advanced")
	app = preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768)]:
		get_window().size = resolution
		for locale: String in ["en","uk"]:
			GameManager.return_home()
			SettingsManager.set_value("locale",locale)
			var suffix := "%s_%dx%d" % [locale,resolution.x,resolution.y]
			await capture("home",suffix)
			GameManager.navigate("activities")
			await frames()
			for page: int in range(3):
				app.current_view.set_page(page)
				await capture("menu"+str(page+1),suffix)
			for route: String in ROUTES:
				GameManager.start_game(route)
				await capture(route,suffix)
				app.idle_guide.reset()
				app.idle_guide._process(10.1)
				await capture(route+"_guide",suffix)
			GameManager.navigate("meadow")
			await capture("meadow",suffix)
			app.open_parent_gate()
			await capture("parent_gate",suffix)
			app.modal.choose(app.modal.answer)
			await frames()
			await capture("settings_top",suffix)
			var scroll := app.current_view.find_child("SettingsScroll",true,false) as ScrollContainer
			scroll.scroll_vertical = 650
			await capture("settings_middle",suffix)
			scroll.scroll_vertical = 10000
			await capture("settings_bottom",suffix)
			GameManager.navigate("gallery")
			await capture("adult_gallery",suffix)
	GameManager.return_home()
	await frames()
	app.queue_free()
	await frames()
	await AudioManager.shutdown()
	print("RELEASE RENDER: %d screenshots, %d issues" % [captures,issues.size()])
	for issue: String in issues:
		print("LAYOUT: "+issue)
	get_tree().quit(0 if issues.is_empty() else 1)
