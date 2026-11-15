class_name MaterialPicker
extends Control
const COLUMNS := 4
const ROW_HEIGHT := 176.0
var entries: Array=[]
var filtered: Array=[]
var chosen: Array[String]=[]
var required := 1
var speak_selection := true
var action: Callable
var app: Control
var scroll := TouchScroll.new()
var grid := Control.new()
var cells: Array[ChildButton]=[]
var play_button: ChildButton
var count_label: Label
var group := "all"
var binding_signature := ""
var filter_buttons: Dictionary={}

static func show_for(owner: Node,items: Array,callback: Callable,count: int=1) -> MaterialPicker:
 var root: Control=owner.get_tree().get_first_node_in_group("app_root")
 if root==null or is_instance_valid(root.modal):return null
 var picker := MaterialPicker.new();picker.app=root;picker.entries=items;picker.action=callback;picker.required=count
 AudioManager.stop_voice()
 if root.current_view.has_method("set_overlay_paused"):root.current_view.set_overlay_paused(true)
 root.modal=picker;root.add_child(picker);return picker

func _ready() -> void:
 name="MaterialPicker";set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var shade := ColorRect.new();shade.color=Color(.08,.17,.13,.55);add_child(shade);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var margin := MarginContainer.new();add_child(margin);margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for side: String in ["left","right","top","bottom"]:margin.add_theme_constant_override("margin_"+side,40)
 var panel := UiKit.card();margin.add_child(panel);var column := UiKit.column(10);panel.add_child(column)
 var top := UiKit.row(12);column.add_child(top);top.add_child(UiKit.label("MATERIAL_CHOOSE",30,UiKit.GREEN));top.add_child(UiKit.spacer());top.add_child(UiKit.button("CANCEL",app.close_modal,UiKit.CREAM))
 var groups := UiKit.row(8);column.add_child(groups)
 for item: Array in [["all","MATERIAL_ALL"],["animals","WORLD_ANIMALS"],["food","MATERIAL_FOOD"],["shapes","SHAPES_TITLE"]]:
  if item[0]!="all" and not entries.any(func(e: Dictionary) -> bool:return category(e)==item[0]):continue
  var button := UiKit.button(item[1],filter_group.bind(item[0]),UiKit.MINT);button.add_theme_font_size_override("font_size",20);groups.add_child(button);filter_buttons[item[0]]=button
 scroll.name="MaterialScroll";scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;column.add_child(scroll)
 grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(grid)
 scroll.get_v_scroll_bar().value_changed.connect(func(_v: float) -> void:sync())
 scroll.resized.connect(func() -> void:call_deferred("sync"))
 var bottom := UiKit.row(12);column.add_child(bottom);count_label=UiKit.label("",22,UiKit.GREEN);bottom.add_child(count_label);bottom.add_child(UiKit.spacer())
 bottom.add_child(UiKit.button("MATERIAL_RANDOM",func() -> void:finish([]),UiKit.CREAM))
 play_button=UiKit.button("PLAY",func() -> void:finish(chosen.duplicate()),UiKit.MINT);play_button.name="PlaySelected";bottom.add_child(play_button)
 filter_group("all")
func category(entry: Dictionary) -> String:
 var path: String=entry.get("illustration","")
 for kind: String in ["animals","food","shapes"]:
  if "/"+kind+"/" in path:return kind
 return "other"
func filter_group(value: String) -> void:
 for id: String in filter_buttons:filter_buttons[id].add_theme_stylebox_override("normal",UiKit.panel(UiKit.MINT if id==value else UiKit.CREAM,16,10))
 group=value;filtered=entries.filter(func(e: Dictionary) -> bool:return value=="all" or category(e)==value);scroll.scroll_vertical=0;call_deferred("sync")
func sync() -> void:
 if not is_inside_tree() or scroll.size.y<=0:return
 grid.custom_minimum_size.y=ceili(filtered.size()/float(COLUMNS))*ROW_HEIGHT
 var first := maxi(0,int(scroll.scroll_vertical/ROW_HEIGHT)-1)*COLUMNS
 var count := maxi(0,mini(filtered.size()-first,(ceili(scroll.size.y/ROW_HEIGHT)+2)*COLUMNS))
 var signature := str([first,count,scroll.size,group,chosen,SettingsManager.values.locale])
 if signature==binding_signature:return
 binding_signature=signature
 while cells.size()<count:
  var button := UiKit.button("",func() -> void:pass,UiKit.CREAM);grid.add_child(button)
  var content := UiKit.column(2);button.add_child(content);content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);content.offset_left=10;content.offset_right=-10;content.offset_top=8;content.offset_bottom=-8;content.mouse_filter=Control.MOUSE_FILTER_IGNORE
  var image := TextureRect.new();image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;image.size_flags_vertical=Control.SIZE_EXPAND_FILL;image.mouse_filter=Control.MOUSE_FILTER_IGNORE;content.add_child(image)
  var label := UiKit.label("",20);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.mouse_filter=Control.MOUSE_FILTER_IGNORE;content.add_child(label)
  button.pressed.connect(func() -> void:
   if not scroll.dragging:select(str(button.get_meta("entry_id")))
  );cells.append(button)
 var width := maxf(400,scroll.size.x-scroll.get_v_scroll_bar().size.x)
 for i: int in range(cells.size()):
  var button := cells[i];button.visible=i<count
  if not button.visible:continue
  var index := first+i;var entry: Dictionary=filtered[index];button.set_meta("entry_id",str(entry.id));button.name="Material_"+str(index)
  button.position=Vector2((index%COLUMNS)*width/COLUMNS,floori(index/float(COLUMNS))*ROW_HEIGHT);button.size=Vector2(width/COLUMNS-10,ROW_HEIGHT-10)
  var image: TextureRect=button.get_child(0).get_child(0);var texture: Texture2D=load(entry.illustration)
  if not entry.get("art_region",[]).is_empty():
   var region: Array=entry.art_region;var atlas := AtlasTexture.new();atlas.atlas=texture;atlas.region=Rect2(region[0],region[1],region[2],region[3]);texture=atlas
  image.texture=texture
  var key: String=entry.get("word_key","");var text: String=entry.get("text",LocalizationManager.text(key))
  button.get_child(0).get_child(1).text=("✓ " if str(entry.id) in chosen else "")+text
  button.add_theme_stylebox_override("normal",UiKit.panel(UiKit.MINT if str(entry.id) in chosen else UiKit.CREAM,18,8))
 count_label.text=LocalizationManager.text("MATERIAL_SELECTED").format({"count":chosen.size(),"total":required});play_button.disabled=chosen.size()!=required
func select(id: String) -> void:
 if id in chosen:chosen.erase(id)
 elif chosen.size()<required:chosen.append(id)
 else:chosen.pop_front();chosen.append(id)
 for entry: Dictionary in entries:
  if str(entry.id)==id:
   if speak_selection:AudioManager.say(entry.get("word_key",""))
   break
 sync()
func finish(ids: Array) -> void:
 var callback := action;app.close_modal();AudioManager.stop_voice();callback.call(ids)
