class_name DesignVisuals
extends RefCounted
static var loaded := false
static var overrides: Dictionary={}
static var textures: Dictionary={}
static func draw(item: CanvasItem,id: String,box: Rect2,state: String="idle",opacity: float=1.0) -> bool:
 if not loaded:
  var path := "res://data/game_content/design_visual_overrides.json"
  if FileAccess.file_exists(path):
   var parsed: Variant=JSON.parse_string(FileAccess.get_file_as_string(path))
   if parsed is Dictionary:overrides=parsed.get("overrides",{})
  loaded=true
 if not overrides.has(id):return false
 var entry: Dictionary=overrides[id]
 var path: String=entry.get("variants",{}).get(state,entry.get("texture",""))
 if not textures.has(path):textures[path]=load(path) if ResourceLoader.exists(path) else null
 var texture: Texture2D=textures[path]
 if texture==null:return false
 var fitted := box.size if entry.get("fit","")=="stretch" else texture.get_size()*minf(box.size.x/texture.get_width(),box.size.y/texture.get_height())
 item.draw_texture_rect(texture,Rect2(box.get_center()-fitted*.5,fitted),false,Color(1,1,1,opacity))
 return true

static func sky_clouds(item: CanvasItem,story: String,age: float,night: bool) -> void:
 var drift := 0.0 if SettingsManager.values.reduced_motion else sin(age*.08)*9
 draw(item,"story/"+story+"/cloud",Rect2(245+drift,-28,135,81),"idle",.5 if night else .8)
 draw(item,"story/"+story+"/cloud",Rect2(485-drift,18,105,63),"idle",.4 if night else .7)
