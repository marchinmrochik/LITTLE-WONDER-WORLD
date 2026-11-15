class_name PuzzleRound
extends RefCounted

const PICTURES_PER_SESSION := 3
const LAYOUTS := {"easy": Vector2i(2, 1), "normal": Vector2i(2, 2), "advanced": Vector2i(3, 2)}
var ids: Array[String] = []
var pictures: Array[String] = []
var tray_order: Array[int] = []
var placed: Array[int] = []
var layout := Vector2i(2, 1)
var index := 0
var completed := false
var rng := RandomNumberGenerator.new()

func _init(picture_ids: Array[String]) -> void:
	ids.assign(picture_ids)

func begin(difficulty: String, random_seed: int = 0) -> bool:
	if not LAYOUTS.has(difficulty) or ids.size() < PICTURES_PER_SESSION:
		return false
	var unique := {}
	for id: String in ids:
		if id.is_empty() or unique.has(id):
			return false
		unique[id] = true
	if random_seed == 0:
		rng.randomize()
	else:
		rng.seed = random_seed
	layout = LAYOUTS[difficulty]
	pictures.assign(ids)
	for i: int in range(pictures.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var saved := pictures[i]
		pictures[i] = pictures[j]
		pictures[j] = saved
	pictures.resize(PICTURES_PER_SESSION)
	index = 0
	completed = false
	reset_picture()
	return true

func piece_count() -> int:
	return layout.x * layout.y

func picture_id() -> String:
	return pictures[index] if not pictures.is_empty() else ""

func region(piece: int, image_size: Vector2) -> Rect2:
	if piece < 0 or piece >= piece_count():
		return Rect2()
	var cell := image_size / Vector2(layout)
	return Rect2(Vector2(piece % layout.x, floori(piece / float(layout.x))) * cell, cell)

func submit(piece: int, slot: int) -> String:
	if pictures.is_empty() or completed or piece < 0 or slot < 0 or piece >= piece_count() or slot >= piece_count() or piece in placed or slot in placed:
		return "ignored"
	if piece != slot:
		return "incorrect"
	placed.append(piece)
	return "correct"

func picture_complete() -> bool:
	return placed.size() == piece_count()

func advance() -> bool:
	if completed or not picture_complete():
		return false
	if index + 1 >= pictures.size():
		completed = true
		return false
	index += 1
	reset_picture()
	return true

func reset_picture() -> void:
	if completed:
		return
	placed.clear()
	tray_order.clear()
	for piece: int in range(piece_count()):
		tray_order.append(piece)
	for i: int in range(tray_order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var saved := tray_order[i]
		tray_order[i] = tray_order[j]
		tray_order[j] = saved
	var original: Array[int] = []
	for piece: int in range(piece_count()):
		original.append(piece)
	if tray_order == original:
		tray_order.push_back(tray_order.pop_front())
