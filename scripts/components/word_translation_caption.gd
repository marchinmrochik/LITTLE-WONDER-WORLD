class_name WordTranslationCaption
extends CenterContainer
var card := PanelContainer.new()
var english := Label.new()
var ukrainian := Label.new()
var remaining := 0.0
var current_key := ""
var lookup: Dictionary={}
func _ready() -> void:
 name="WordTranslationCaption";mouse_filter=Control.MOUSE_FILTER_IGNORE;size_flags_horizontal=Control.SIZE_EXPAND_FILL
 lookup=JSON.parse_string(FileAccess.get_file_as_string("res://data/game_content/word_translations.json")).captions
 card.name="WordTranslationCard";card.mouse_filter=Control.MOUSE_FILTER_IGNORE;card.add_theme_stylebox_override("panel",UiKit.panel(Color("fff8ec"),18,4));add_child(card)
 var column := UiKit.column(0);column.mouse_filter=Control.MOUSE_FILTER_IGNORE;card.add_child(column)
 for label: Label in [english,ukrainian]:
  label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.mouse_filter=Control.MOUSE_FILTER_IGNORE;label.add_theme_font_size_override("font_size",20 if label==ukrainian else 18);label.add_theme_color_override("font_color",UiKit.GREEN if label==ukrainian else UiKit.INK);column.add_child(label)
 card.hide();AudioManager.speech_requested.connect(_on_speech);SettingsManager.changed.connect(_setting_changed)
func enabled() -> bool:
 var app: Variant=get_tree().get_first_node_in_group("app_root")
 if app!=null and is_instance_valid(app.current_view) and app.current_view.get("hide_word_caption")==true:return false
 return SettingsManager.values.english_ukrainian_translation and SettingsManager.values.locale=="en" and (GameManager.games.has(GameManager.current_route) or GameManager.current_route=="world_topic")
func _setting_changed(_key: String) -> void:
 if not enabled():clear_caption()
func clear_caption() -> void:remaining=0;current_key="";card.hide()
func _on_speech(key: String,locale: String) -> void:
 if not is_inside_tree() or not enabled():return
 if locale!="en":clear_caption();return
 if not lookup.has(key):return
 var pair: Dictionary=lookup[key]
 current_key=key;english.text=pair.english;ukrainian.text=pair.ukrainian;remaining=6.0;card.show()
func _process(delta: float) -> void:
 if not enabled():clear_caption();return
 var app: Variant=get_tree().get_first_node_in_group("app_root")
 if app!=null and (app.suspended or is_instance_valid(app.modal)):card.hide();return
 remaining=maxf(0,remaining-delta);card.visible=remaining>0 and not current_key.is_empty()
