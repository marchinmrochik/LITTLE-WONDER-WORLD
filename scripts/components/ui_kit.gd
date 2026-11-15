class_name UiKit
extends RefCounted

const INK := Color("243b36")
const MUTED := Color("64796f")
const GREEN := Color("367b64")
const CREAM := Color("fff8ec")
const MINT := Color("d8eddf")
const CORAL := Color("ffd1ab")
const FONT = preload("res://assets/fonts/Nunito-Variable.ttf")

static func make_theme() -> Theme:
	var theme := Theme.new()
	var font := FontVariation.new()
	font.base_font = FONT
	font.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 700.0}
	theme.default_font = font
	theme.default_font_size = 23
	theme.set_color("font_color", "Label", INK)
	theme.set_color("font_color", "Button", INK)
	theme.set_color("font_hover_color", "Button", INK)
	theme.set_color("font_pressed_color", "Button", INK)
	theme.set_stylebox("normal", "Button", panel(Color("fffdf7"), 24, 18))
	theme.set_stylebox("hover", "Button", panel(Color("f0f6e9"), 24, 18))
	theme.set_stylebox("pressed", "Button", panel(Color("d7e8ce"), 24, 18))
	theme.set_stylebox("disabled", "Button", panel(Color("eeeede"), 24, 18))
	theme.set_color("font_disabled_color", "Button", Color("829087"))
	var focus := panel(Color(0, 0, 0, 0), 24, 0)
	focus.set_border_width_all(3)
	focus.border_color = Color("b18336")
	theme.set_stylebox("focus", "Button", focus)
	theme.set_constant("h_separation", "Button", 14)
	theme.set_constant("icon_max_width", "Button", 30)
	theme.set_stylebox("slider", "HSlider", panel(Color("d9e3d8"), 6, 5))
	theme.set_stylebox("grabber_area", "HSlider", panel(GREEN, 6, 5))
	theme.set_stylebox("grabber_area_highlight", "HSlider", panel(GREEN, 6, 5))
	theme.set_icon("grabber", "HSlider", preload("res://assets/ui/slider_thumb.svg"))
	theme.set_icon("grabber_highlight", "HSlider", preload("res://assets/ui/slider_thumb.svg"))
	return theme

static func panel(color: Color, radius: int = 28, padding: int = 28) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	box.content_margin_left = padding
	box.content_margin_right = padding
	box.content_margin_top = padding
	box.content_margin_bottom = padding
	return box

static func label(key: String, font_size: int = 24, color: Color = INK) -> Label:
	var result := Label.new()
	result.text = LocalizationManager.text(key)
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result

static func paragraph(key: String, font_size: int = 21) -> Label:
	var result := label(key, font_size, MUTED)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return result

static func button(key: String, action: Callable, color: Color = Color("fffdf7"), icon: String = "") -> ChildButton:
	var result := ChildButton.new()
	result.text = LocalizationManager.text(key)
	result.custom_minimum_size = Vector2(0, 64)
	result.add_theme_stylebox_override("normal", panel(color, 22, 18))
	result.add_theme_stylebox_override("hover", panel(color.lightened(0.07), 22, 18))
	result.add_theme_stylebox_override("pressed", panel(color.darkened(0.07), 22, 18))
	if not icon.is_empty():
		result.icon = load("res://assets/ui/" + icon + ".svg") as Texture2D
		result.expand_icon = false
	result.pressed.connect(action)
	return result

static func column(separation: int = 18) -> VBoxContainer:
	var result := VBoxContainer.new()
	result.add_theme_constant_override("separation", separation)
	return result

static func tool_button(key: String, action: Callable, icon: String) -> ChildButton:
	var result := button("",action,MINT,icon)
	result.tooltip_text = LocalizationManager.text(key)
	result.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.custom_minimum_size = Vector2(70,64)
	result.add_theme_constant_override("icon_max_width",42)
	return result

static func row(separation: int = 16) -> HBoxContainer:
	var result := HBoxContainer.new()
	result.add_theme_constant_override("separation", separation)
	return result

static func spacer() -> Control:
	var result := Control.new()
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return result

static func card(color: Color = Color("fffdf7")) -> PanelContainer:
	var result := PanelContainer.new()
	result.add_theme_stylebox_override("panel", panel(color))
	return result

static func compact_tool_button(key: String,action: Callable,icon: String) -> ChildButton:
	var button := tool_button(key,action,icon)
	button.custom_minimum_size=Vector2(54,54);button.add_theme_constant_override("icon_max_width",32)
	for state: String in ["normal","hover","pressed","disabled"]:button.add_theme_stylebox_override(state,panel(MINT if state=="normal" else MINT.lightened(.06) if state=="hover" else Color("e7ecdf") if state=="disabled" else MINT.darkened(.06),18,8))
	return button
