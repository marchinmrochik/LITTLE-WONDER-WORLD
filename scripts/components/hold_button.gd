class_name ParentHoldButton
extends Button

signal hold_completed
const HOLD_SECONDS := 2.0
var elapsed := 0.0
var holding := false

func _ready() -> void:
	text = LocalizationManager.text("PARENT_SETTINGS_BUTTON")
	tooltip_text = LocalizationManager.text("HOLD_HINT")
	icon = preload("res://assets/ui/settings.svg")
	expand_icon = false
	custom_minimum_size = Vector2(190, 62)
	button_down.connect(func() -> void: holding = true; elapsed = 0)
	button_up.connect(cancel_hold)
	mouse_exited.connect(cancel_hold)

func _process(delta: float) -> void:
	if not holding:
		return
	elapsed += delta
	queue_redraw()
	if elapsed >= HOLD_SECONDS:
		cancel_hold()
		hold_completed.emit()

func cancel_hold() -> void:
	holding = false
	elapsed = 0
	queue_redraw()

func _draw() -> void:
	if holding:
		draw_style_box(UiKit.panel(Color("78af89"), 3, 0), Rect2(16, size.y - 7, (size.x - 32) * minf(elapsed / HOLD_SECONDS, 1), 5))

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		cancel_hold()
