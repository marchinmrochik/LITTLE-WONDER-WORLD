class_name ShapeBoard
extends RefCounted

const BOARD_COUNT := 3
const COUNTS := {"easy": 2, "normal": 3, "advanced": 4}
var ids: Array[String] = []
var boards: Array = []
var sources: Array[String] = []
var targets: Array[String] = []
var placed: Array[String] = []
var index := 0
var solved := 0
var completed := false
var rng := RandomNumberGenerator.new()

func _init(shape_ids: Array[String]) -> void:
	ids.assign(shape_ids)

func begin(difficulty: String, random_seed: int = 0) -> bool:
	if not COUNTS.has(difficulty) or ids.size() != 6:
		return false
	var unique := {}
	for id: String in ids:
		unique[id] = true
	if unique.size() != ids.size():
		return false
	if random_seed == 0:
		rng.randomize()
	else:
		rng.seed = random_seed
	var pool := ids.duplicate()
	_shuffle(pool)
	boards.clear()
	var count: int = COUNTS[difficulty]
	for board: int in range(BOARD_COUNT):
		var values: Array[String] = []
		for item: int in range(count):
			values.append(pool[(board * count + item) % pool.size()])
		boards.append(values)
	index = 0
	solved = 0
	completed = false
	_prepare()
	return true

func submit(piece: String, slot: String) -> String:
	if completed or piece not in sources or slot not in targets or piece in placed or slot in placed:
		return "ignored"
	if piece != slot:
		return "incorrect"
	placed.append(piece)
	solved += 1
	return "correct"

func board_complete() -> bool:
	return not targets.is_empty() and placed.size() == targets.size()

func advance() -> bool:
	if completed or not board_complete():
		return false
	if index + 1 >= boards.size():
		completed = true
		return false
	index += 1
	_prepare()
	return true

func _prepare() -> void:
	sources.assign(boards[index])
	targets.assign(boards[index])
	_shuffle(sources)
	_shuffle(targets)
	if sources == targets:
		targets.push_back(targets.pop_front())
	placed.clear()

func _shuffle(values: Array[String]) -> void:
	for i: int in range(values.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var value := values[i]
		values[i] = values[j]
		values[j] = value
