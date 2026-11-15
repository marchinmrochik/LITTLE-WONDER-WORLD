class_name FoxieView
extends Control

var portrait := TextureRect.new()
var motion: Tween
var idle: Tween
var resting := false
var current_state := "idle"

const STATES := {
	"idle": "res://assets/characters/foxie.svg",
	"resting": "res://assets/characters/foxie_rest.svg",
	"happy": "res://assets/characters/foxie_happy.svg",
	"waving": "res://assets/characters/foxie_waving.svg",
	"thinking": "res://assets/characters/foxie_thinking.svg",
	"encouraging": "res://assets/characters/foxie_encouraging.svg",
	"celebrating": "res://assets/characters/foxie_celebrating.svg",
}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.texture = load(CompanionCatalog.illustration(SettingsManager.values.companion))
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_layout)
	SettingsManager.changed.connect(_settings_changed)
	_layout()
	_update_idle()

func react(quiet: bool = false) -> void:
	set_state("resting" if quiet else "happy")
	if motion != null:
		motion.kill()
	_update_idle()
	if SettingsManager.values.reduced_motion:
		portrait.scale = Vector2.ONE
		return
	motion = create_tween()
	motion.tween_property(portrait, "scale", Vector2.ONE * (0.97 if quiet else 1.04), 0.2).set_trans(Tween.TRANS_SINE)
	motion.tween_property(portrait, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SINE)

func set_state(value: String) -> void:
	if not STATES.has(value):
		return
	current_state = value
	resting = value == "resting"
	portrait.texture = load(STATES[value] if SettingsManager.values.companion=="fox" else CompanionCatalog.illustration(SettingsManager.values.companion)) as Texture2D
	if is_inside_tree():
		_update_idle()

func _layout() -> void:
	portrait.pivot_offset = size * 0.5

func _settings_changed(key: String) -> void:
	if key=="companion":set_state(current_state)
	if key == "reduced_motion":
		if motion != null:
			motion.kill()
		portrait.scale = Vector2.ONE
		_update_idle()

func _update_idle() -> void:
	if idle != null:
		idle.kill()
	portrait.rotation = 0
	if not SettingsManager.values.reduced_motion and not resting:
		idle = create_tween().set_loops()
		idle.tween_property(portrait, "rotation", 0.018, 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		idle.tween_property(portrait, "rotation", -0.018, 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
