extends Node

signal route_changed(route: String)

const ROUTES := {
	"living_gallery":"res://scenes/home/living_gallery.tscn",
	"world":"res://scenes/home/world_hub.tscn",
	"world_topic":"res://scenes/games/world_topic.tscn",
	"assessment_history":"res://scenes/settings/assessment_history.tscn",
	"home": "res://scenes/home/home.tscn",
	"meadow": "res://scenes/companion/meadow.tscn",
	"settings": "res://scenes/settings/parent_settings.tscn",
	"gallery": "res://scenes/settings/parent_gallery.tscn",
	"activities": "res://scenes/home/activities.tscn",
}

var current_route := "home"
var parents_unlocked := false
var games: Dictionary = {}
var activities_scroll := 0
var meadow_parent := "home"
var world_topic := "animals"
var living_story := "house"
var living_drafts: Dictionary = {}

func _ready() -> void:
	register_game("animals", "res://scenes/games/learn_animals.tscn", "english")

	register_game("colors", "res://scenes/games/learn_colors.tscn", "english")
	register_game("feeding", "res://scenes/games/feed_animals.tscn", "english")
	register_game("shapes", "res://scenes/games/shape_sorting.tscn", "english")
	register_game("puzzles", "res://scenes/games/animal_puzzles.tscn", "thinking")
	register_game("memory", "res://scenes/games/memory_match.tscn", "thinking")
	register_game("counting", "res://scenes/games/lets_count.tscn", "thinking")
	register_game("draw_word","res://scenes/games/draw_word.tscn","creative")
	register_game("drawing", "res://scenes/games/magic_drawing.tscn", "creative")
	register_game("coloring", "res://scenes/games/coloring_book.tscn", "creative")
	register_game("xylophone", "res://scenes/games/magic_xylophone.tscn", "creative")
	register_game("letters","res://scenes/games/alphabet_garden.tscn","learning")
	register_game("syllables","res://scenes/games/syllable_garden.tscn","learning")
	register_game("living_drawing","res://scenes/games/living_drawing.tscn","creative")
	register_game("balloons","res://scenes/games/balloon_meadow.tscn","creative")

func navigate(route: String) -> bool:
	if (not ROUTES.has(route) and not games.has(route)) or (route in ["settings", "gallery", "assessment_history"] and not parents_unlocked):
		return false
	if route == current_route:
		return true
	AudioManager.stop_voice()
	AudioManager.set_resting(false)
	if route not in ["settings", "gallery", "assessment_history"]:
		parents_unlocked = false
	if route == "meadow":
		meadow_parent="activities" if current_route=="activities" or games.has(current_route) else "home"
		ProgressManager.record_companion_visit()
	current_route = route
	route_changed.emit(route)
	return true

func register_game(id: String, scene_path: String, section: String) -> bool:
	if id.is_empty() or games.has(id) or ROUTES.has(id) or not ResourceLoader.exists(scene_path):
		return false
	games[id] = {"scene": scene_path, "section": section}
	return true

func scene_for_route(route: String) -> String:
	return str(ROUTES.get(route, games.get(route, {}).get("scene", "")))

func start_game(id: String) -> bool:
	return games.has(id) and navigate(id)

func return_home() -> void:
	navigate("home")

func parent_route(route: String="") -> String:
	var id := current_route if route.is_empty() else route
	if id=="meadow":return meadow_parent
	var parents := {"living_drawing":"living_gallery","living_gallery":"activities","world_topic":"world","world":"activities","gallery":"settings","assessment_history":"settings"}
	if parents.has(id):return parents[id]
	return "activities" if games.has(id) else "home"
func go_back() -> void:
	navigate(parent_route())
