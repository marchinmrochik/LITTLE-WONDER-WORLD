class_name PointerDrag
extends Node

signal moved(position: Vector2)
signal released(position: Vector2, traveled: bool)
signal canceled

const NONE := -2
var pointer_owner := NONE
var origin := Vector2.ZERO
var position := Vector2.ZERO
var traveled := false

func begin(pointer: int, point: Vector2) -> bool:
	if pointer_owner != NONE:
		return false
	pointer_owner = pointer
	origin = point
	position = point
	traveled = false
	return true

func move(point: Vector2) -> void:
	if pointer_owner == NONE:
		return
	position = point
	traveled = traveled or origin.distance_to(point) > 12.0
	moved.emit(point)

func release(point: Vector2) -> void:
	if pointer_owner == NONE:
		return
	var did_travel := traveled or origin.distance_to(point) > 12.0
	pointer_owner = NONE
	released.emit(point, did_travel)

func cancel() -> void:
	if pointer_owner == NONE:
		return
	pointer_owner = NONE
	canceled.emit()

func _input(event: InputEvent) -> void:
	if pointer_owner == NONE:
		return
	var handled := true
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		cancel()
	elif event is InputEventScreenDrag and event.index == pointer_owner:
		move(event.position)
	elif event is InputEventScreenTouch and event.index == pointer_owner and not event.pressed:
		if event.canceled:
			cancel()
		else:
			release(event.position)
	elif pointer_owner == -1 and event is InputEventMouseMotion:
		move(event.position)
	elif pointer_owner == -1 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		release(event.position)
	else:
		handled = false
	if handled:
		get_viewport().set_input_as_handled()
