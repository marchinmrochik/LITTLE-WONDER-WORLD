extends Control
const STORIES := [
 {"id":"house","title":"LIVE_HOUSE_STORY","icon":"res://assets/ui/living_house.svg","node":"HouseStory"},
 {"id":"spring","title":"SEASON_SPRING","icon":"res://assets/ui/living_spring.svg","node":"SpringStory"},
 {"id":"autumn","title":"SEASON_AUTUMN","icon":"res://assets/ui/living_autumn.svg","node":"AutumnStory"},
 {"id":"winter","title":"SEASON_WINTER","icon":"res://assets/ui/living_winter.svg","node":"WinterStory"}]
var scroll := TouchScroll.new()
func _ready() -> void:
 var column := UiKit.column(18);add_child(column);column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var title := UiKit.label("LIVE_GALLERY",38,UiKit.GREEN);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(title)
 scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;column.add_child(scroll)
 var grid := GridContainer.new();grid.columns=4;grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_theme_constant_override("h_separation",16);scroll.add_child(grid)
 for item: Dictionary in STORIES:
  var card := UiKit.button(item.title,open_story.bind(item.id),UiKit.CREAM)
  card.name=item.node;card.custom_minimum_size=Vector2(0,290);card.size_flags_horizontal=Control.SIZE_EXPAND_FILL;card.icon=load(item.icon);card.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER;card.vertical_icon_alignment=VERTICAL_ALIGNMENT_TOP;card.add_theme_constant_override("icon_max_width",160);card.add_theme_font_size_override("font_size",21);grid.add_child(card)
func open_story(id: String) -> void:
 if scroll.dragging:return
 GameManager.living_story=id;GameManager.start_game("living_drawing")
func get_idle_action() -> Dictionary:return {"from":find_child("HouseStory",true,false).get_global_rect().get_center()}
func set_overlay_paused(value: bool) -> void:scroll.interaction_enabled=not value;scroll.cancel_gesture()
