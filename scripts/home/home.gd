extends Control

var fox: FoxieView
var greeting: Label
var pet_buttons: Dictionary={}
var pet_scroll: TouchScroll

func _ready() -> void:
	var center := CenterContainer.new()
	var layout := UiKit.column(12);add_child(layout);layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.size_flags_vertical=Control.SIZE_EXPAND_FILL;layout.add_child(center)
	var content := UiKit.row(48)
	center.add_child(content)
	var left := UiKit.column(22)
	left.custom_minimum_size.x = 500
	left.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(left)
	var title := UiKit.label("WELCOME", 57)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(title)
	left.add_child(UiKit.paragraph("WELCOME_HINT", 25))
	var play := UiKit.button("PLAY", func() -> void: GameManager.navigate("activities"), Color("ffe0a1"), "play")
	play.name = "PlayButton"
	play.custom_minimum_size = Vector2(310, 88)
	play.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	play.add_theme_font_size_override("font_size", 32)
	left.add_child(play)
	var right := UiKit.column(0)
	content.add_child(right)
	var bubble := UiKit.card(Color("fffdf0"))
	bubble.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	right.add_child(bubble)
	greeting = UiKit.label(CompanionCatalog.label_key(SettingsManager.values.companion), 30, UiKit.GREEN)
	bubble.add_child(greeting)
	var portrait_button := Button.new()
	portrait_button.name = "FoxieButton"
	portrait_button.custom_minimum_size = Vector2(360, 360)
	portrait_button.flat = true
	portrait_button.tooltip_text = LocalizationManager.text("SAY_HELLO")
	var portrait_row := UiKit.row(8);right.add_child(portrait_row)
	var previous := UiKit.tool_button("BACK",step_pet.bind(-1),"previous");previous.name="PreviousPet";previous.size_flags_vertical=Control.SIZE_SHRINK_CENTER;portrait_row.add_child(previous)
	portrait_row.add_child(portrait_button)
	var next := UiKit.tool_button("NEXT",step_pet.bind(1),"next");next.name="NextPet";next.size_flags_vertical=Control.SIZE_SHRINK_CENTER;portrait_row.add_child(next)
	fox = FoxieView.new()
	portrait_button.add_child(fox)
	fox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait_button.pressed.connect(func() -> void:
		fox.react()
		fox.set_state("waving")
		AudioManager.play_sfx("sparkle")
		AudioManager.say(CompanionCatalog.word_key(SettingsManager.values.companion))
	)

	layout.add_child(UiKit.label("PET_CHOOSE",24,UiKit.GREEN))
	pet_scroll=TouchScroll.new();pet_scroll.name="PetScroll";pet_scroll.horizontal=true;pet_scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;pet_scroll.custom_minimum_size.y=120;layout.add_child(pet_scroll)
	var pets := UiKit.row(10);pets.name="PetRow";pet_scroll.add_child(pets)
	for id: String in CompanionCatalog.IDS:
		var button := UiKit.button(CompanionCatalog.label_key(id),choose_pet.bind(id),UiKit.MINT if id==SettingsManager.values.companion else UiKit.CREAM)
		button.name="Pet_"+id;button.icon=load(CompanionCatalog.illustration(id));button.expand_icon=true;button.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER;button.vertical_icon_alignment=VERTICAL_ALIGNMENT_TOP;button.add_theme_constant_override("icon_max_width",62);button.add_theme_font_size_override("font_size",19);button.custom_minimum_size=Vector2(112,110);button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		pet_buttons[id]=button;pets.add_child(button)
	call_deferred("reveal_pet",SettingsManager.values.companion)
func choose_pet(id: String) -> void:
	if not CompanionCatalog.valid(id):return
	SettingsManager.set_value("companion",id)
	greeting.text=LocalizationManager.text(CompanionCatalog.label_key(id))
	for key: String in pet_buttons:
		var button: Button=pet_buttons[key]
		button.add_theme_stylebox_override("normal",UiKit.panel(UiKit.MINT if key==id else UiKit.CREAM,22,18))
	fox.react();AudioManager.say(CompanionCatalog.word_key(id))
	call_deferred("reveal_pet",id)

func step_pet(direction: int) -> void:
	var index := CompanionCatalog.IDS.find(SettingsManager.values.companion)
	choose_pet(CompanionCatalog.IDS[posmod(index+direction,CompanionCatalog.IDS.size())])
func reveal_pet(id: String) -> void:
	if not is_inside_tree() or not is_instance_valid(pet_scroll):return
	await get_tree().process_frame
	if not is_inside_tree() or SettingsManager.values.companion!=id:return
	pet_scroll.cancel_gesture()
	var visible_rect := pet_scroll.get_global_rect()
	var selected_rect: Rect2=pet_buttons[id].get_global_rect()
	if selected_rect.position.x<visible_rect.position.x:pet_scroll.write_offset(pet_scroll.scroll_horizontal+selected_rect.position.x-visible_rect.position.x)
	elif selected_rect.end.x>visible_rect.end.x:pet_scroll.write_offset(pet_scroll.scroll_horizontal+selected_rect.end.x-visible_rect.end.x)
