class_name PaintPalette
extends HBoxContainer

signal paint_selected(paint: String)
var side_layout := false
const EXTRA := ["ffffff","111820","f7b6a2","a71d36","f4bd80","bf6829","fff1a6","92c75b","237650","9bded3","287e91","b7d8ee","29458b","c6afe7","642f89","f8c8df"]
const GRADIENTS := ["d95b59:efce55","578dc2:e995b4","6ba46f:efce55","9672b7:9bded3","ec984b:e995b4","29458b:b7d8ee"]

func _ready() -> void:
	add_theme_constant_override("separation",6)
	var holder: Container=self
	if side_layout:
		var grid := GridContainer.new();grid.columns=2;grid.add_theme_constant_override("h_separation",6);grid.add_theme_constant_override("v_separation",6);add_child(grid);holder=grid
	for index: int in range(PaintDocument.COLORS.size()):
		var value: String=PaintDocument.COLORS[index].to_html(false)
		var button := swatch(value)
		button.custom_minimum_size=Vector2(50,48) if side_layout else Vector2(40,44)
		button.name="Color_"+str(index)
		holder.add_child(button)
	var more := UiKit.compact_tool_button("PALETTE_MORE",open_picker,"palette")
	more.name="MoreColors"
	more.custom_minimum_size=Vector2(50,48) if side_layout else Vector2(50,44)
	holder.add_child(more)

func swatch(value: String) -> ChildButton:
	var button := UiKit.button("",func() -> void: paint_selected.emit(value))
	button.custom_minimum_size=Vector2(56,56)
	button.tooltip_text=LocalizationManager.text("PALETTE_GRADIENT" if value.begins_with("gradient:") else "DRAW_COLOR")
	var base := UiKit.CREAM if value.begins_with("gradient:") else Color(value)
	for state: String in ["normal","hover","pressed"]:button.add_theme_stylebox_override(state,UiKit.panel(base if state=="normal" else base.lightened(.06) if state=="hover" else base.darkened(.06),18,8))
	if value.begins_with("gradient:"):
		var parts := value.split(":")
		var gradient := Gradient.new()
		gradient.colors=PackedColorArray([Color(parts[1]),Color(parts[2])])
		var texture := GradientTexture2D.new()
		texture.gradient=gradient
		texture.width=48;texture.height=36
		button.icon=texture
		button.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER
		button.add_theme_constant_override("icon_max_width",48)
	else:
		button.add_theme_stylebox_override("normal",UiKit.panel(Color(value),18,8))
	return button

func open_picker() -> void:
	var app: Variant=get_tree().get_first_node_in_group("app_root")
	app.close_modal()
	if app.current_view.has_method("set_overlay_paused"): app.current_view.set_overlay_paused(true)
	var overlay := Control.new()
	app.modal=overlay
	app.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color=Color(0.1,0.2,0.15,0.4)
	overlay.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var card := UiKit.card()
	card.custom_minimum_size.x=824
	center.add_child(card)
	var column := UiKit.column(14)
	card.add_child(column)
	column.add_child(UiKit.label("PALETTE_MORE",28,UiKit.GREEN))
	var scroll := TouchScroll.new();scroll.name="PaletteScroll";scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.custom_minimum_size=Vector2(768,336);column.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns=12
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",8)
	scroll.add_child(grid)
	var paints := available_paints()
	for value: String in paints:
		var button := swatch(value)
		button.name="Paint_"+value.replace(":","_")
		# Close the palette before applying selection so drawing resumes immediately.
		for connection: Dictionary in button.pressed.get_connections(): button.pressed.disconnect(connection.callable)
		button.pressed.connect(func() -> void: app.close_modal();paint_selected.emit(value))
		grid.add_child(button)
	column.add_child(UiKit.button("CANCEL",app.close_modal,UiKit.MINT))

static func available_paints() -> Array[String]:
	var paints: Array[String]=[]
	for color: Color in PaintDocument.COLORS:paints.append(color.to_html(false))
	for value: String in EXTRA:
		if value not in paints:paints.append(value)
	for shade: Vector2 in [Vector2(.30,1.0),Vector2(.60,1.0),Vector2(.95,1.0),Vector2(.95,.80),Vector2(.95,.60),Vector2(.95,.40)]:
		for hue: int in range(18):
			var value := Color.from_hsv(hue/18.0,shade.x,shade.y).to_html(false)
			if value not in paints:paints.append(value)
	for step: int in range(11):
		var value := Color(step/10.0,step/10.0,step/10.0).to_html(false)
		if value not in paints:paints.append(value)
	for pair: String in GRADIENTS:paints.append("gradient:"+pair)
	return paints
