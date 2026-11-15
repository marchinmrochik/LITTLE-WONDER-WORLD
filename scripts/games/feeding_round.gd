class_name FeedingRound
extends AnimalRound

const FOOD_CHOICES := {"easy": 3, "normal": 4, "advanced": 5}

func begin(difficulty: String, random_seed: int = 0) -> bool:
	if ids.size() < 5 or not FOOD_CHOICES.has(difficulty):
		return false
	if not super.begin(difficulty, random_seed):
		return false
	choice_count = FOOD_CHOICES[difficulty]
	_prepare()
	return true
