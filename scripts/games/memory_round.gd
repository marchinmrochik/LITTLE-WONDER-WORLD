class_name MemoryRound
extends RefCounted

const PAIRS := {"easy": 2, "normal": 3, "advanced": 4}
var ids: Array[String] = []
var deck: Array[String] = []
var matched: Array[int] = []
var first := -1
var second := -1
var locked := false
var completed := false
var started := false
var pair_count := 0
var rng := RandomNumberGenerator.new()

func _init(item_ids: Array[String]) -> void:
	ids.assign(item_ids)

func begin(difficulty: String, random_seed: int = 0) -> bool:
	if not PAIRS.has(difficulty) or ids.size() < PAIRS[difficulty]:
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
	pair_count = PAIRS[difficulty]
	var available := ids.duplicate()
	_shuffle(available)
	deck.clear()
	for id: String in available.slice(0, pair_count):
		deck.append(id)
		deck.append(id)
	_shuffle(deck)
	matched.clear()
	first = -1
	second = -1
	locked = false
	completed = false
	started = true
	return true

func reveal(index: int) -> String:
	if not started or completed or locked or index < 0 or index >= deck.size() or index in matched or index == first:
		return "ignored"
	if first == -1:
		first = index
		return "first"
	second = index
	locked = true
	return "match" if deck[first] == deck[second] else "mismatch"

func resolve() -> bool:
	if not locked or second == -1:
		return false
	if deck[first] == deck[second]:
		matched.append(first)
		matched.append(second)
	first = -1
	second = -1
	locked = false
	completed = matched.size() == deck.size()
	return true

func face_up(index: int) -> bool:
	return started and index >= 0 and index < deck.size() and (index in matched or index == first or index == second)

func _shuffle(values: Array[String]) -> void:
	for i: int in range(values.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var saved := values[i]
		values[i] = values[j]
		values[j] = saved
