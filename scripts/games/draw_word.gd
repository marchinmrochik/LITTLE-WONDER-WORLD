extends Control
var deck := DrawWordDeck.new()
var editor: Variant
var family := false
var task: Array=[]
var group := "all"
var phase := "setup"
var task_difficulty := "normal"
var task_category := "all"
var hide_word_caption: bool:
 get:return family
var overlay_paused := false
var focus_paused := false
var root := UiKit.column(8)
var top := UiKit.row(10)
var clue := UiKit.row(8)
var host := Control.new()
var curtain: Control
var heard_index := -1
var storage_path: String:
 get:return ArtworkManager.directory+"/draw-word-task.json"
func _ready() -> void:
 add_child(root);root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.add_child(top);top.add_child(UiKit.label("CROC_TITLE",27,UiKit.GREEN));top.add_child(UiKit.spacer())
 top.add_child(UiKit.button("CROC_OPTIONS",show_setup,UiKit.CREAM));top.add_child(UiKit.button("MATERIAL_CHOOSE",choose_task,UiKit.MINT,"gallery"))
 root.add_child(clue);clue.custom_minimum_size.y=64
 host.size_flags_vertical=Control.SIZE_EXPAND_FILL;root.add_child(host)
 editor=preload("res://scripts/games/magic_drawing.gd").new();editor.draft_slot="draw-word";editor.allow_gallery=false;editor.play_intro=false;editor.compact_inset=true;host.add_child(editor);editor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 editor.column.get_child(editor.column.get_child_count()-1).get_child(0).text=LocalizationManager.text("CROC_TITLE")
 var saved := JsonStore.read_document(storage_path,valid_state)
 if not saved.document.is_empty() and saved.document.locale==SettingsManager.values.locale:
  task_difficulty=saved.document.difficulty;task_category=saved.document.category
  family=saved.document.family;group=saved.document.category;deck.configure(SettingsManager.values.locale,saved.document.difficulty,group)
  for id: String in saved.document.ids:
   for entry: Dictionary in deck.pool:
    if entry.id==id:task.append(entry);break
 if task.size()==deck.count_required() and not task.is_empty():deck.last_id=task[0].id;start_drawing()
 else:show_setup()
func valid_state(data: Dictionary) -> bool:
 if data.get("version")!=1 or data.get("locale","") not in ["en","uk"] or not data.get("family") is bool:return false
 if data.get("category","") not in DrawWordDeck.CATEGORIES or data.get("difficulty","") not in ["easy","normal","advanced"] or not data.get("ids") is Array:return false
 if data.ids.size()!=(2 if data.difficulty=="advanced" else 1) or data.ids.any(func(id: Variant) -> bool:return data.ids.count(id)>1):return false
 return data.ids.all(func(id: Variant) -> bool:return id is String and id.length()<160)
func persist() -> void:
 if task.is_empty():return
 var ids: Array=[]
 for entry: Dictionary in task:ids.append(entry.id)
 if JsonStore.write_document(storage_path,{"version":1,"locale":SettingsManager.values.locale,"family":family,"category":task_category,"difficulty":task_difficulty,"ids":ids},valid_state)!=OK:
  editor.status.text=LocalizationManager.text("SAVE_ERROR")
func panel(title: String) -> VBoxContainer:
 if is_instance_valid(curtain):curtain.queue_free()
 curtain=Control.new();add_child(curtain);curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var shade := ColorRect.new();shade.color=Color(.1,.2,.15,.55);curtain.add_child(shade);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var center := CenterContainer.new();curtain.add_child(center);center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var card := UiKit.card();card.custom_minimum_size=Vector2(790,0);center.add_child(card)
 var column := UiKit.column(12);card.add_child(column);column.add_child(UiKit.label(title,30,UiKit.GREEN));update_pause();return column
func show_setup() -> void:
 AudioManager.stop_voice();heard_index=-1;phase="setup";top.show()
 var column := panel("CROC_TITLE");column.add_child(UiKit.paragraph("CROC_HINT",22))
 var modes := UiKit.row(12);column.add_child(modes)
 modes.add_child(UiKit.button("CROC_CHILD",func() -> void:family=false;show_setup(),UiKit.MINT if not family else UiKit.CREAM))
 modes.add_child(UiKit.button("CROC_FAMILY",func() -> void:family=true;show_setup(),UiKit.MINT if family else UiKit.CREAM))
 column.add_child(UiKit.paragraph("CROC_FAMILY_HINT" if family else "CROC_CHILD_HINT",20))
 var categories := OptionButton.new();categories.name="DrawWordCategory"
 for id: String in DrawWordDeck.CATEGORIES:categories.add_item(LocalizationManager.text("CROC_CAT_"+id.to_upper()))
 categories.select(DrawWordDeck.CATEGORIES.find(group));categories.item_selected.connect(func(index: int) -> void:group=DrawWordDeck.CATEGORIES[index];show_setup());column.add_child(categories)
 var levels := DifficultyStrip.new();column.add_child(levels)
 for level: String in levels.buttons:levels.buttons[level].pressed.connect(show_setup)
 deck.configure(SettingsManager.values.locale,SettingsManager.values.difficulty,group)
 var row := UiKit.row(10);column.add_child(row)
 var start := UiKit.button("CROC_RANDOM",func() -> void:request_change(func() -> void:task=deck.next();begin_task()),UiKit.MINT,"replay");start.disabled=not deck.available();row.add_child(start)
 var choose := UiKit.button("MATERIAL_CHOOSE",choose_task,UiKit.CREAM,"gallery");choose.disabled=not deck.available();row.add_child(choose)
 if not task.is_empty():row.add_child(UiKit.button("KEEP_PLAYING",start_drawing,UiKit.CREAM))
 if not deck.available():column.add_child(UiKit.paragraph("CROC_EMPTY",20))
func request_change(action: Callable) -> void:
 editor.canvas.finish_stroke();heard_index=-1;AudioManager.stop_voice()
 if editor.canvas.document.is_blank():action.call();return
 if not editor.unpublished:
  blank_page();action.call();return
 var app: Variant=get_tree().get_first_node_in_group("app_root")
 app._show_confirmation("CROC_NEXT_TITLE","CROC_NEXT_HINT","CROC_SAVE_NEXT",func() -> void:
  var id := ArtworkManager.save_artwork(editor.canvas.document.image)
  if id.is_empty():
   app._show_confirmation("CROC_SAVE_BLOCKED","DRAW_FULL" if ArtworkManager.last_error==ERR_OUT_OF_MEMORY else "SAVE_ERROR","KEEP_PLAYING",start_drawing);set_overlay_paused(true);return
  blank_page();action.call()
 );set_overlay_paused(true)
func blank_page() -> void:
 var image := Image.create(PaintDocument.SIZE.x,PaintDocument.SIZE.y,false,Image.FORMAT_RGBA8);image.fill(Color.WHITE)
 editor.canvas.document.load_image(image);editor.canvas.refresh();editor.unpublished=true;editor.flush_draft();editor._update_controls()
func choose_task() -> void:
 if overlay_paused or focus_paused:return
 if deck.pool.is_empty():deck.configure(SettingsManager.values.locale,SettingsManager.values.difficulty,group)
 if not deck.available():show_setup();return
 var picker := MaterialPicker.show_for(self,deck.pool,func(ids: Array) -> void:
  request_change(func() -> void:
   task=[]
   if ids.is_empty():task=deck.next()
   else:
    for id: String in ids:
     for entry: Dictionary in deck.pool:
      if entry.id==id:task.append(entry);break
   begin_task()
  )
 ,deck.count_required())
 if picker!=null:picker.speak_selection=not family
func begin_task() -> void:
 if task.is_empty():show_setup();return
 task_difficulty=deck.difficulty;task_category=group;deck.last_id=task[0].id
 persist()
 if family:private_prompt()
 else:start_drawing();say_task()
func private_prompt() -> void:
 phase="private";AudioManager.stop_voice();heard_index=-1
 var column := panel("CROC_PRIVATE");column.add_child(UiKit.paragraph("CROC_PRIVATE_HINT",21));column.add_child(pictures())
 column.add_child(UiKit.button("CROC_HIDE_DRAW",start_drawing,UiKit.MINT))
func pictures() -> HBoxContainer:
 var row := UiKit.row(16);row.alignment=BoxContainer.ALIGNMENT_CENTER
 for entry: Dictionary in task:
  if row.get_child_count()>0:row.add_child(UiKit.label("+",30,UiKit.GREEN))
  var column := UiKit.column(4);row.add_child(column)
  var picture := TextureRect.new();picture.custom_minimum_size=Vector2(150,120);picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  var texture: Texture2D=load(entry.illustration)
  if not entry.art_region.is_empty():
   var r: Array=entry.art_region;var atlas := AtlasTexture.new();atlas.atlas=texture;atlas.region=Rect2(r[0],r[1],r[2],r[3]);texture=atlas
  picture.texture=texture;column.add_child(picture);var label := UiKit.label(entry.text,24,UiKit.GREEN);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(label)
 return row
func start_drawing() -> void:
 phase="drawing";top.hide()
 persist()
 if is_instance_valid(curtain):remove_child(curtain);curtain.queue_free()
 curtain=null
 for child: Node in clue.get_children():clue.remove_child(child);child.queue_free()
 if family:
  clue.add_child(UiKit.label("CROC_SECRET",23,UiKit.GREEN));clue.add_child(UiKit.button("CROC_PEEK",private_prompt,UiKit.CREAM))
 else:
  for entry: Dictionary in task:
   if clue.get_child_count()>0:clue.add_child(UiKit.label("+",24,UiKit.GREEN))
   var texture := TextureRect.new();texture.texture=task_texture(entry);texture.custom_minimum_size=Vector2(65,64);texture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;texture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;clue.add_child(texture);clue.add_child(UiKit.label(entry.text,22,UiKit.GREEN))
  clue.add_child(UiKit.button("",say_task,UiKit.MINT,"speaker"))
 clue.add_child(UiKit.spacer());clue.add_child(UiKit.compact_tool_button("CROC_OPTIONS",show_setup,"settings"));clue.add_child(UiKit.compact_tool_button("MATERIAL_CHOOSE",choose_task,"gallery"));clue.add_child(UiKit.button("CROC_REVEAL" if family else "CROC_DONE",show_answer,UiKit.MINT));clue.add_child(UiKit.button("CROC_NEXT",next_task,UiKit.CREAM,"replay"))
 for node: Node in clue.get_children():
  if node is Button:node.custom_minimum_size.y=52;node.add_theme_font_size_override("font_size",20)
 update_pause()
func say_task() -> void:
 if family or overlay_paused or focus_paused or task.is_empty():return
 heard_index=0;AudioManager.say(task[0].word_key)
func _process(_delta: float) -> void:
 if heard_index<0 or family or overlay_paused or focus_paused:return
 if not AudioManager.voice.playing:
  heard_index+=1
  if heard_index>=task.size():heard_index=-1
  else:AudioManager.say(task[heard_index].word_key)
func show_answer() -> void:
 if overlay_paused or focus_paused:return
 phase="answer";heard_index=-1;AudioManager.stop_voice();editor.canvas.finish_stroke();editor.flush_draft()
 var column := panel("CROC_ANSWER" if family else "CROC_WELL_DONE");column.add_child(pictures())
 if family:column.add_child(UiKit.button("CROC_GUESSED",func() -> void:AudioManager.play_sfx("sparkle");start_drawing(),UiKit.MINT))
 column.add_child(UiKit.button("CROC_NEXT",next_task,UiKit.MINT,"replay"));column.add_child(UiKit.button("KEEP_PLAYING",start_drawing,UiKit.CREAM));AudioManager.play_sfx("sparkle")
func next_task() -> void:
 if overlay_paused or focus_paused:return
 request_change(func() -> void:task=deck.next();begin_task())
func update_pause() -> void:
 if is_instance_valid(editor):editor.set_overlay_paused(overlay_paused or focus_paused or is_instance_valid(curtain))
func set_overlay_paused(value: bool) -> void:
 overlay_paused=value;update_pause()
func handle_back() -> bool:
 if phase!="drawing" and not task.is_empty():start_drawing();return true
 return false
func get_idle_action() -> Dictionary:
 if overlay_paused or focus_paused or is_instance_valid(curtain):return {}
 return {"from":editor.canvas.get_global_rect().get_center()}
func _notification(what: int) -> void:
 if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT]:focus_paused=true;heard_index=-1;AudioManager.stop_voice();update_pause()
 elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN]:focus_paused=false;update_pause()

func task_texture(entry: Dictionary) -> Texture2D:
 var texture: Texture2D=load(entry.illustration)
 if not entry.art_region.is_empty():
  var r: Array=entry.art_region;var atlas := AtlasTexture.new();atlas.atlas=texture;atlas.region=Rect2(r[0],r[1],r[2],r[3]);return atlas
 return texture
