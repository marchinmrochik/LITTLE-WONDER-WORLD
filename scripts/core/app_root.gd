extends Control

var safe := MarginContainer.new()
var column := UiKit.column(8)
var header := UiKit.row()
var slot := Control.new()
var current_view: Control
var modal: Control
var transition: Tween
var hold_button: ParentHoldButton
var suspended := false
var idle_guide := IdleGuide.new()

func _ready() -> void:
	add_to_group("app_root")
	theme = UiKit.make_theme()
	var background := TextureRect.new()
	background.texture = preload("res://assets/backgrounds/meadow.svg")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(safe)
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.add_child(column)
	column.add_child(header)
	slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(slot)
	get_viewport().size_changed.connect(_safe_layout)
	GameManager.route_changed.connect(_show_route)
	LocalizationManager.locale_changed.connect(func() -> void: call_deferred("_refresh_locale"))
	_safe_layout()
	_show_route(GameManager.current_route)
	idle_guide.app = self
	add_child(idle_guide)

func _refresh_locale() -> void:
	# Read the route when rebuilding, so rapid navigation cannot restore an old screen.
	_show_route(GameManager.current_route)

func _safe_layout() -> void:
	var insets := Vector4(36, 28, 36, 28)
	if OS.has_feature("android"):
		var area := DisplayServer.get_display_safe_area()
		var pixels := Vector2(get_window().size)
		if pixels.x > 0 and pixels.y > 0 and area.has_area():
			var ratio := get_viewport_rect().size / pixels
			insets = Vector4(maxf(28, area.position.x * ratio.x + 20), maxf(20, area.position.y * ratio.y + 16), maxf(28, (pixels.x - area.end.x) * ratio.x + 20), maxf(20, (pixels.y - area.end.y) * ratio.y + 16))
	for index: int in range(4):
		safe.add_theme_constant_override(["margin_left", "margin_top", "margin_right", "margin_bottom"][index], int(insets[index]))

func _show_route(route: String) -> void:
	idle_guide.reset()
	close_modal()
	if transition != null:
		transition.kill()
	if is_instance_valid(current_view):
		slot.remove_child(current_view)
		current_view.queue_free()
	for child: Node in header.get_children():
		header.remove_child(child)
		child.queue_free()
	if route == "home":
		var mark := TextureRect.new()
		mark.texture = preload("res://assets/ui/app_icon.svg")
		mark.custom_minimum_size = Vector2(64, 64)
		mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		header.add_child(mark)
		header.add_child(UiKit.label("WORDMARK", 25, UiKit.GREEN))
	else:
		var back := UiKit.button("BACK",_back,UiKit.CREAM,"back");back.name="BackButton";header.add_child(back)
	var companion := FoxieView.new()
	companion.name="TravelCompanion";companion.custom_minimum_size=Vector2(64,64);header.add_child(companion)
	header.add_child(WordTranslationCaption.new())
	if route not in ["settings", "gallery", "assessment_history"]:
		hold_button = ParentHoldButton.new()
		header.add_child(hold_button)
		hold_button.hold_completed.connect(open_parent_gate)
	else:
		header.add_child(UiKit.label("SETTINGS_TITLE", 28, UiKit.GREEN))
	current_view = (load(GameManager.scene_for_route(route)) as PackedScene).instantiate() as Control
	slot.add_child(current_view)
	current_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if current_view.has_signal("reset_requested"):
		current_view.connect("reset_requested", confirm_reset)
	if not SettingsManager.values.reduced_motion:
		current_view.modulate.a = 0
		transition = create_tween()
		transition.tween_property(current_view, "modulate:a", 1.0, 0.18)

func open_parent_gate() -> void:
	if is_instance_valid(modal):
		return
	AudioManager.stop_voice()
	if is_instance_valid(current_view) and current_view.has_method("set_overlay_paused"):
		current_view.set_overlay_paused(true)
	var gate := ParentGate.new()
	modal = gate
	add_child(gate)
	gate.dismissed.connect(close_modal)
	gate.unlocked.connect(func() -> void:
		GameManager.parents_unlocked = true
		GameManager.navigate("settings")
	)

func close_modal() -> void:
	if is_instance_valid(modal):
		remove_child(modal)
		modal.queue_free()
		if is_instance_valid(current_view) and current_view.has_method("set_overlay_paused"):
			current_view.set_overlay_paused(false)
	modal = null

func confirm_reset() -> void:
	_show_confirmation("RESET_TITLE", "RESET_HINT", "RESET_CONFIRM", func() -> void:
		ProgressManager.reset_progress()
		_show_route("settings")
	)

func _show_confirmation(title: String, hint: String, confirm: String, action: Callable) -> void:
	close_modal()
	modal = Control.new()
	add_child(modal)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.09, 0.19, 0.16, 0.4)
	modal.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	modal.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var card := UiKit.card()
	card.custom_minimum_size = Vector2(620, 0)
	center.add_child(card)
	var content := UiKit.column(22)
	card.add_child(content)
	content.add_child(UiKit.label(title, 34))
	var description := UiKit.paragraph(hint)
	description.custom_minimum_size.x = 550
	content.add_child(description)
	content.add_child(UiKit.button(confirm, func() -> void: close_modal(); action.call(), UiKit.CORAL))
	content.add_child(UiKit.button("KEEP_PLAYING" if confirm == "EXIT" else "CANCEL", close_modal, UiKit.MINT))

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()
		get_viewport().set_input_as_handled()

func _back() -> void:
	if is_instance_valid(modal):
		close_modal()
	elif is_instance_valid(current_view) and current_view.has_method("handle_back") and current_view.handle_back():
		return
	elif GameManager.current_route != "home":
		GameManager.go_back()
	else:
		_show_confirmation("EXIT_TITLE", "EXIT_HINT", "EXIT", _quit)

func _quit() -> void:
	if is_instance_valid(current_view) and current_view.has_method("_commit_volumes"):
		current_view._commit_volumes()
	SettingsManager.save()
	ProgressManager.save()
	await AudioManager.shutdown()
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_back()
	elif what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if is_instance_valid(hold_button):
			hold_button.cancel_hold()
		if not suspended:
			suspended = true
			if is_instance_valid(current_view) and current_view.has_method("_commit_volumes"):
				current_view._commit_volumes()
			AudioManager.suspend()
			SettingsManager.save()
			ProgressManager.save()
	elif what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_APPLICATION_FOCUS_IN:
		if suspended:
			suspended = false
			AudioManager.resume()
