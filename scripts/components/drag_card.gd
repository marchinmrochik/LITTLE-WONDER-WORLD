class_name DragCard
extends PanelContainer

signal grabbed(id: String, pointer: int, position: Vector2)
signal word_requested(id: String)

var item_id := ""

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		grabbed.emit(item_id, event.index, get_global_transform() * event.position)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		grabbed.emit(item_id, -1, get_global_transform() * event.position)
		accept_event()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_SPACE]:
		word_requested.emit(item_id)
		accept_event()
