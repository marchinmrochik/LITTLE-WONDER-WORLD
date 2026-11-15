class_name MemoryCard
extends ChildButton

signal flip_finished

var front_texture: Texture2D
var picture := TextureRect.new()
var face_up := false
var flipping := false
var flip_tween: Tween
var queued_face := false
const BACK = preload("res://assets/ui/memory_back.svg")

func _ready() -> void:
	super._ready()
	add_child(picture)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	picture.offset_left = 14
	picture.offset_right = -14
	picture.offset_top = 12
	picture.offset_bottom = -12
	picture.texture = BACK

func show_face(value: bool, animate: bool = true) -> void:
	if flip_tween != null:
		flip_tween.kill()
	queued_face = value
	flipping = true
	# Keep the hit box stable; only the inner artwork rotates/scales.
	if not animate or SettingsManager.values.reduced_motion:
		_apply_face()
		_finish_flip()
		return
	picture.pivot_offset = picture.size * 0.5
	flip_tween = create_tween()
	flip_tween.tween_property(picture, "scale:x", 0.04, 0.12).set_trans(Tween.TRANS_SINE)
	flip_tween.tween_callback(_apply_face)
	flip_tween.tween_property(picture, "scale:x", 1.0, 0.12).set_trans(Tween.TRANS_SINE)
	flip_tween.tween_callback(_finish_flip)

func _apply_face() -> void:
	face_up = queued_face
	picture.texture = front_texture if face_up else BACK

func _finish_flip() -> void:
	picture.scale = Vector2.ONE
	flipping = false
	flip_finished.emit()

func set_flip_paused(value: bool) -> void:
	if flip_tween != null and flip_tween.is_valid():
		if value:
			flip_tween.pause()
		else:
			flip_tween.play()

func _exit_tree() -> void:
	if flip_tween != null:
		flip_tween.kill()
