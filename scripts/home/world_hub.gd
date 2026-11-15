extends Control
var body := UiKit.column(18)
func _ready() -> void:
	add_child(body);body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := UiKit.label("WORLD_TITLE",38,UiKit.GREEN)
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;body.add_child(title)
	var center := CenterContainer.new();center.size_flags_vertical=Control.SIZE_EXPAND_FILL;body.add_child(center)
	var row := UiKit.row(24);center.add_child(row)
	for topic: Dictionary in WorldCatalog.topics():
		var button := UiKit.button(topic.title_key,open_topic.bind(topic.id),UiKit.CREAM)
		button.name="Topic_"+topic.id
		button.custom_minimum_size=Vector2(330,300)
		button.icon=load(topic.illustration)
		button.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment=VERTICAL_ALIGNMENT_TOP
		button.add_theme_constant_override("icon_max_width",170)
		row.add_child(button)
func open_topic(id: String) -> void:
	GameManager.world_topic=id;GameManager.navigate("world_topic")
func get_idle_action() -> Dictionary:
	return {"from":find_child("Topic_animals",true,false).get_global_rect().get_center()}
