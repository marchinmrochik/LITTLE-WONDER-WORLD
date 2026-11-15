extends Control
var body := UiKit.column(12)
var alphabet := "uk"
var selected_key := ""
var grid: GridContainer
var overlay_paused := false
var focus_paused := false
var picture_mode := false
var card_index := 0
var tracing_mode := false
var tracing: SymbolTracing
var card_area: Control
var swipe_owner := -2
var swipe_start := Vector2.ZERO

func _ready() -> void:
	alphabet=SettingsManager.values.locale
	add_child(body);body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	build()

func entries() -> Array:return LetterCatalog.load_data().alphabets[alphabet]
func build() -> void:
	swipe_owner=-2;card_area=null;grid=null;tracing=null
	for child: Node in body.get_children():body.remove_child(child);child.queue_free()
	var top := UiKit.row(12);body.add_child(top)
	top.add_child(UiKit.label("ALPH_TITLE",32,UiKit.GREEN));top.add_child(UiKit.spacer())
	for mode: bool in [false,true]:
		var button := UiKit.button("ALPH_PICTURES" if mode else "ALPH_LETTERS",set_picture_mode.bind(mode),UiKit.MINT if not tracing_mode and picture_mode==mode else UiKit.CREAM,"gallery" if mode else "letters")
		button.name="PictureTab" if mode else "LettersTab";top.add_child(button)
	var trace_tab := UiKit.button("TRACE_TAB",set_tracing_mode,UiKit.MINT if tracing_mode else UiKit.CREAM,"drawing")
	trace_tab.name="TraceTab";top.add_child(trace_tab)
	if tracing_mode:
		tracing=SymbolTracing.new();tracing.show_mode_switch=false;tracing.fixed_mode="letters";tracing.name="SymbolTracing";tracing.size_flags_vertical=Control.SIZE_EXPAND_FILL;body.add_child(tracing);tracing.set_overlay_paused(overlay_paused);tracing.set_focus_paused(focus_paused)
	elif picture_mode:build_card()
	else:build_grid()

func build_grid() -> void:
	var hint := UiKit.label("ALPH_HINT",24,UiKit.GREEN);hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;body.add_child(hint)
	var scroll := ScrollContainer.new();scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;body.add_child(scroll)
	var center := CenterContainer.new();center.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(center)
	grid=GridContainer.new();grid.columns=8
	grid.add_theme_constant_override("h_separation",8);grid.add_theme_constant_override("v_separation",8);center.add_child(grid)
	for i: int in range(entries().size()):
		var entry: Dictionary=entries()[i]
		var button := UiKit.button("",select_letter.bind(i),[UiKit.CREAM,UiKit.MINT,Color("f5e2bd"),Color("e8dfee")][i%4])
		button.text=entry.upper+" "+entry.lower;button.name="Letter_"+entry.id
		button.custom_minimum_size=Vector2(102,78);button.add_theme_font_size_override("font_size",36);grid.add_child(button)

func build_card() -> void:
	var entry: Dictionary=entries()[card_index]
	var hint := UiKit.label("ALPH_SWIPE" if entry.initial else "ALPH_INSIDE",22,UiKit.GREEN);hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;body.add_child(hint)
	var card := UiKit.card();card.name="AlphabetCard";card.size_flags_vertical=Control.SIZE_EXPAND_FILL;body.add_child(card);card_area=card
	var column := UiKit.column(8);card.add_child(column)
	var row := UiKit.row(24);row.size_flags_vertical=Control.SIZE_EXPAND_FILL;column.add_child(row)
	var letter := UiKit.button("",speak.bind(entry.word_key),UiKit.MINT)
	letter.name="CardLetter";letter.text=entry.upper+" "+entry.lower;letter.add_theme_font_size_override("font_size",100);letter.custom_minimum_size=Vector2(250,200);letter.size_flags_vertical=Control.SIZE_EXPAND_FILL;row.add_child(letter)
	var picture := UiKit.button("",speak.bind(entry.example_key),UiKit.CREAM)
	picture.name="CardPicture";picture.icon=load(entry.illustration);picture.expand_icon=true;picture.add_theme_constant_override("icon_max_width",340);picture.size_flags_horizontal=Control.SIZE_EXPAND_FILL;picture.size_flags_vertical=Control.SIZE_EXPAND_FILL;picture.custom_minimum_size=Vector2(240,200);row.add_child(picture)
	picture.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var word := RichTextLabel.new();word.name="ExampleWord";word.bbcode_enabled=true;word.fit_content=true;word.mouse_filter=Control.MOUSE_FILTER_IGNORE;word.add_theme_font_size_override("normal_font_size",40)
	word.add_theme_color_override("default_color",UiKit.INK)
	word.add_theme_font_override("normal_font",UiKit.FONT);word.add_theme_font_override("bold_font",UiKit.FONT)
	word.add_theme_font_size_override("bold_font_size",40)
	var at: int=entry.highlight_index
	word.text="[center]"+entry.example.substr(0,at)+"[color=#b26039][b]"+entry.example.substr(at,1)+"[/b][/color]"+entry.example.substr(at+1)+"[/center]";column.add_child(word)
	var navigation := UiKit.row(16);body.add_child(navigation)
	var previous := UiKit.tool_button("BACK",step.bind(-1),"previous");previous.name="PreviousLetter";previous.disabled=card_index==0;navigation.add_child(previous)
	var counter := UiKit.label("",25,UiKit.GREEN);counter.text=str(card_index+1)+" / "+str(entries().size());counter.size_flags_horizontal=Control.SIZE_EXPAND_FILL;counter.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;navigation.add_child(counter)
	var next := UiKit.tool_button("NEXT",step.bind(1),"next");next.name="NextLetter";next.disabled=card_index==entries().size()-1;navigation.add_child(next)

func set_picture_mode(value: bool) -> void:
	if overlay_paused or focus_paused:return
	AudioManager.stop_voice();tracing_mode=false;picture_mode=value;build()
func set_tracing_mode() -> void:
	if overlay_paused or focus_paused:return
	AudioManager.stop_voice();tracing_mode=true;picture_mode=false;build()
func select_letter(index: int) -> void:
	card_index=index;speak(entries()[index].word_key)
func step(direction: int) -> void:
	if overlay_paused or focus_paused:return
	var next := clampi(card_index+direction,0,entries().size()-1)
	if next==card_index:return
	AudioManager.stop_voice();card_index=next;build()
func choose_alphabet(mode: String) -> void:
	# Compatibility for existing fixtures: language is controlled only by app settings.
	if mode!=SettingsManager.values.locale:return
	alphabet=mode;selected_key="";build()
func speak(key: String) -> void:
	if overlay_paused or focus_paused:return
	selected_key=key;AudioManager.say(key,alphabet)
func _input(event: InputEvent) -> void:
	if not picture_mode or overlay_paused or focus_paused or not is_instance_valid(card_area):return
	if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:return
	var point := Vector2.ZERO;var owner := -2;var pressed := false;var released := false
	if event is InputEventScreenTouch:
		point=event.position;owner=event.index;pressed=event.pressed;released=not event.pressed
		if event.canceled:swipe_owner=-2;return
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		point=event.position;owner=-1;pressed=event.pressed;released=not event.pressed
	else:return
	if pressed and swipe_owner==-2 and card_area.get_global_rect().has_point(point):swipe_owner=owner;swipe_start=point
	elif released and owner==swipe_owner:
		swipe_owner=-2
		var distance := point-swipe_start
		if absf(distance.x)>65 and absf(distance.x)>absf(distance.y)*1.3:
			step(-1 if distance.x>0 else 1);get_viewport().set_input_as_handled()
func get_idle_action() -> Dictionary:
	if overlay_paused or focus_paused:return {}
	if tracing_mode and is_instance_valid(tracing):return tracing.get_idle_action()
	var target: Control=find_child("CardLetter",true,false) if picture_mode else grid.get_child(0)
	return {"from":target.get_global_rect().get_center()}
func set_overlay_paused(value: bool) -> void:
	overlay_paused=value;swipe_owner=-2
	if is_instance_valid(tracing):tracing.set_overlay_paused(value)
func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT]:focus_paused=true;swipe_owner=-2
	elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN]:focus_paused=false
	else:return
	if is_instance_valid(tracing):tracing.set_focus_paused(focus_paused)
