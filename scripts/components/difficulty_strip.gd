class_name DifficultyStrip
extends HBoxContainer
var buttons: Dictionary={}
var group := ButtonGroup.new()
func _ready() -> void:
 name="DifficultyStrip";alignment=BoxContainer.ALIGNMENT_CENTER;add_theme_constant_override("separation",10)
 add_child(UiKit.label("DIFFICULTY",23,UiKit.GREEN))
 for entry: Array in [["easy","EASY","●"],["normal","NORMAL","●●"],["advanced","ADVANCED","●●●"]]:
  var value: String=entry[0]
  var button := UiKit.button(entry[1],choose.bind(value),UiKit.CREAM)
  button.toggle_mode=true;button.button_group=group;button.set_meta("caption",entry[2]+"  "+LocalizationManager.text(entry[1]))
  button.name="Level_"+value;button.text=str(button.get_meta("caption"));button.add_theme_font_size_override("font_size",20)
  button.custom_minimum_size=Vector2(185,54);add_child(button);buttons[value]=button
 SettingsManager.changed.connect(func(key: String) -> void:
  if key=="difficulty":refresh()
 );refresh()
func choose(value: String) -> void:
 SettingsManager.set_value("difficulty",value);refresh()
func refresh() -> void:
 for value: String in buttons:
  var selected: bool=SettingsManager.values.difficulty==value
  var color: Color=UiKit.MINT if selected else UiKit.CREAM
  for state: String in ["normal","hover","pressed"]:
   var style := UiKit.panel(color.lightened(.04) if state=="hover" else color,16,10)
   style.set_border_width_all(3 if selected else 0);style.border_color=UiKit.GREEN
   buttons[value].add_theme_stylebox_override(state,style)
  buttons[value].set_pressed_no_signal(selected)
  buttons[value].text=("✓ " if selected else "")+str(buttons[value].get_meta("caption"))
