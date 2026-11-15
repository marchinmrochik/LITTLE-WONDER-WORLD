class_name AnimalRound
extends RefCounted

const ROUND_COUNT := 5
const CHOICES := {"easy": 2, "normal": 3, "advanced": 4}

var ids: Array[String] = []
var targets: Array[String] = []
var options: Array[String] = []
var target := ""
var index := 0
var solved := 0
var round_solved := false
var completed := false
var choice_count := 2
var rng := RandomNumberGenerator.new()

func _init(animal_ids: Array[String]) -> void:
	ids.assign(animal_ids)

func begin(difficulty: String, random_seed: int = 0) -> bool:
	if ids.size() < 4 or not CHOICES.has(difficulty):
		return false
	if random_seed == 0:
		rng.randomize()
	else:
		rng.seed = random_seed
	choice_count = CHOICES[difficulty]
	targets.assign(ids)
	_shuffle(targets)
	targets.resize(mini(ROUND_COUNT, targets.size()))
	index = 0
	solved = 0
	completed = false
	_prepare()
	return true

func submit(id: String) -> String:
	if completed or round_solved or id not in options:
		return "ignored"
	if id != target:
		return "incorrect"
	round_solved = true
	solved += 1
	return "correct"

func advance() -> bool:
	if completed or not round_solved:
		return false
	if index + 1 >= targets.size():
		completed = true
		return false
	index += 1
	_prepare()
	return true

func _prepare() -> void:
	target = targets[index]
	round_solved = false
	var alternatives: Array[String] = []
	for id: String in ids:
		if id != target:
			alternatives.append(id)
	_shuffle(alternatives)
	options.assign(alternatives.slice(0, choice_count - 1))
	options.append(target)
	_shuffle(options)

func _shuffle(values: Array[String]) -> void:
	for position: int in range(values.size() - 1, 0, -1):
		var other := rng.randi_range(0, position)
		var saved := values[position]
		values[position] = values[other]
		values[other] = saved
