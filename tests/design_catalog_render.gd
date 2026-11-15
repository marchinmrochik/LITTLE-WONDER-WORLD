extends Node
const OUT := "res://.local/design-catalog/previews/"
var app: Variant
var captures := 0
func _ready() -> void:call_deferred("run")
func frames() -> void:
 for i: int in range(4):await get_tree().process_frame
func capture(name: String) -> void:
 await frames();await RenderingServer.frame_post_draw
 var image := get_viewport().get_texture().get_image()
 if image.save_png(ProjectSettings.globalize_path(OUT+name+".png"))!=OK:push_error("Catalog screenshot failed: "+name)
 captures+=1
func ui_preview(id: String,control: Control) -> void:
 var sub := SubViewport.new();sub.size=Vector2i(420,180);sub.transparent_bg=true;sub.render_target_update_mode=SubViewport.UPDATE_ALWAYS;add_child(sub)
 var root := CenterContainer.new();root.theme=UiKit.make_theme();root.size=Vector2(420,180);sub.add_child(root);root.add_child(control)
 await frames();await RenderingServer.frame_post_draw;sub.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT+"ui_"+id+".png"));captures+=1
 sub.queue_free();await frames()
func run() -> void:
 get_window().title="Little Wonder World - Catalog Renderer";get_window().size=Vector2i(1280,800)
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
 var fixture := "user://test-runs/design-catalog-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("sfx_volume",0.0);SettingsManager.set_value("locale","uk");SettingsManager.set_value("reduced_motion",false)
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);app.idle_guide.set_process(false);await frames();await capture("screen_home")
 for route: String in GameManager.games:
  GameManager.start_game(route);await frames();app.suspended=false
  if app.current_view.get("focus_paused")!=null:app.current_view.focus_paused=false
  await capture("screen_"+route)
 for route: String in ["activities","world","living_gallery","settings"]:
  GameManager.parents_unlocked=true;GameManager.navigate(route);await capture("screen_"+route)
 for topic: String in ["animals","body","plants"]:
  GameManager.world_topic=topic;GameManager.navigate("world_topic");await frames();await capture("screen_world_"+topic);GameManager.navigate("world");await frames()
 for story: String in ["house","spring","autumn","winter"]:
  GameManager.living_story=story;GameManager.start_game("living_drawing");await frames();var game: Variant=app.current_view;game.focus_paused=false;game.restart()
  for i: int in range(game.parts.size()):game.completed[i]=true
  game.state=game.State.PLAY;game.update_labels();await capture("screen_story_"+story)
  game.board.play_object("sun" if story!="winter" else "moon");game.board.play_object("cloud");game.board.play_object("tree" if story!="house" and story!="winter" else "dog" if story=="house" else "snowman");await capture("screen_story_"+story+"_react")
  for i: int in range(game.parts.size()):
   var part: Dictionary=game.parts[i];var box: Array=part.zoom
   var sub := SubViewport.new();sub.size=Vector2i(320,320);sub.transparent_bg=true;sub.render_target_update_mode=SubViewport.UPDATE_ALWAYS;add_child(sub)
   var board: Variant=load("res://tests/design_catalog_house_preview.gd" if story=="house" else "res://tests/design_catalog_season_preview.gd").new()
   board.game=game;board.selected=i;board.size=Vector2(320,320);board.view=Rect2(box[0],box[1],box[2],box[3]);sub.add_child(board);board.custom_minimum_size=Vector2.ZERO;board.size=Vector2(320,320);board.set_process(false)
   for state: String in ["idle","react","react2"]:
    board.effects.clear();board.age=0 if state=="idle" else .45 if state=="react" else .95
    board.night=false
    if state!="idle":board.effects[part.id]=3.6 if story!="house" or part.id in ["dog","cloud","flowers"] else 1.4;board.lit[part.id]=true
    board.queue_redraw();await frames();await RenderingServer.frame_post_draw
    sub.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT+story+"_"+part.id+"_"+state+".png"));captures+=1
   sub.queue_free();await frames()
  GameManager.navigate("living_gallery");await frames()
 await ui_preview("button_primary",UiKit.button("PLAY",func() -> void:pass,UiKit.MINT))
 await ui_preview("button_secondary",UiKit.button("BACK",func() -> void:pass,UiKit.CREAM))
 var disabled := UiKit.button("PLAY",func() -> void:pass,UiKit.MINT);disabled.disabled=true;await ui_preview("button_disabled",disabled)
 var pressed := UiKit.button("PLAY",func() -> void:pass,UiKit.MINT);pressed.toggle_mode=true;pressed.button_pressed=true;await ui_preview("button_pressed",pressed)
 await ui_preview("back",UiKit.button("BACK",func() -> void:pass,UiKit.CREAM,"back"))
 await ui_preview("icon",UiKit.compact_tool_button("DRAW_SAVE",func() -> void:pass,"save"))
 var card := UiKit.card();card.custom_minimum_size=Vector2(300,120);card.add_child(UiKit.label("ANIMALS_TITLE",30));await ui_preview("card",card)
 var slider := HSlider.new();slider.value=65;slider.custom_minimum_size=Vector2(330,50);await ui_preview("slider",slider)
 var tabs := UiKit.row(10);tabs.add_child(UiKit.button("COUNT_CHOICE",func() -> void:pass,UiKit.MINT));tabs.add_child(UiKit.button("COUNT_BASKET",func() -> void:pass,UiKit.CREAM));await ui_preview("tabs",tabs)
 var caption := PanelContainer.new();caption.add_theme_stylebox_override("panel",UiKit.panel(UiKit.CREAM,18,8));var words := UiKit.column(0);caption.add_child(words);words.add_child(UiKit.label("Cat",20));words.add_child(UiKit.label("Кіт",20,UiKit.GREEN));await ui_preview("caption",caption)
 var meta := {"captured_at":Time.get_datetime_string_from_system(),"captures":captures,"paints":PaintPalette.available_paints(),"engine":Engine.get_version_info().string}
 var file := FileAccess.open("res://.local/design-catalog/native.json",FileAccess.WRITE);file.store_string(JSON.stringify(meta,"  "));file.close()
 app.queue_free();await frames();await AudioManager.shutdown();print("DESIGN CATALOG RENDER: ",captures," captures");get_tree().quit()
