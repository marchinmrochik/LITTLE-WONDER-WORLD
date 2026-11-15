class_name CountingRound
extends RefCounted

const ROUND_COUNT := 5
const LIMITS := {"easy": 5, "normal": 10, "advanced": 10}
const CHOICES := {"easy": 2, "normal": 3, "advanced": 4}
var theme_ids: Array[String] = []
var targets: Array[int] = []
var options: Array[int] = []
var in_basket: Array[int] = []
var themes: Array[String] = []
var mode := "choice"
var limit := 5
var choice_count := 2
var target := 0
var theme := ""
var index := 0
var solved := 0
var round_solved := false
var completed := false
var started := false
var rng := RandomNumberGenerator.new()

func _init(ids: Array[String]) -> void:
	theme_ids.assign(ids)

func begin(difficulty: String, selected_mode: String, random_seed: int = 0) -> bool:
	if not LIMITS.has(difficulty) or selected_mode not in ["choice", "basket"] or theme_ids.size() < 3:
		return false
	var unique := {}
	for id: String in theme_ids:
		if id.is_empty() or unique.has(id):
			return false
		unique[id] = true
	if random_seed == 0:
		rng.randomize()
	else:
		rng.seed = random_seed
	mode = selected_mode
	limit = LIMITS[difficulty]
	choice_count = CHOICES[difficulty]
	targets.clear()
	for value: int in range(1, limit + 1):
		targets.append(value)
	_shuffle(targets)
	targets.resize(ROUND_COUNT)
	themes.assign(theme_ids)
	_shuffle(themes)
	index = 0
	solved = 0
	completed = false
	started = true
	_prepare()
	return true

func answer(number: int) -> String:
	if not started or mode != "choice" or completed or round_solved or number not in options:
		return "ignored"
	return _evaluate(number == target)

func add_object(instance: int) -> bool:
	if not _basket_active() or instance < 0 or instance >= limit or instance in in_basket:
		return false
	in_basket.append(instance)
	return true

func remove_object(instance: int) -> bool:
	if not _basket_active() or instance not in in_basket:
		return false
	in_basket.erase(instance)
	return true

func check_basket() -> String:
	if not _basket_active():
		return "ignored"
	return _evaluate(in_basket.size() == target)

func _basket_active() -> bool:
	return started and mode == "basket" and not completed and not round_solved

func _evaluate(correct: bool) -> String:
	if not correct:
		return "incorrect"
	round_solved = true
	solved += 1
	return "correct"

func advance() -> bool:
	if not started or completed or not round_solved:
		return false
	if index + 1 == targets.size():
		completed = true
		return false
	index += 1
	_prepare()
	return true

func _prepare() -> void:
	target = targets[index]
	theme = themes[index % themes.size()]
	round_solved = false
	in_basket.clear()
	options.clear()
	for value: int in range(1, limit + 1):
		if value != target:
			options.append(value)
	_shuffle(options)
	options.resize(choice_count - 1)
	options.append(target)
	_shuffle(options)

func _shuffle(values: Array) -> void:
	for i: int in range(values.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var saved: Variant = values[i]
		values[i] = values[j]
		values[j] = saved
