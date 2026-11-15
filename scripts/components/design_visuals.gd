class_name DesignVisuals
extends RefCounted
static var loaded := false
static var overrides: Dictionary={}
static var textures: Dictionary={}
static func draw(item: CanvasItem,id: String,box: Rect2) -> bool:
 if not loaded:
  var path := "res://data/game_content/design_visual_overrides.json"
  if FileAccess.file_exists(path):
   var parsed: Variant=JSON.parse_string(FileAccess.get_file_as_string(path))
   if parsed is Dictionary:overrides=parsed.get("overrides",{})
  loaded=true
 if not overrides.has(id):return false
 var path: String=overrides[id].get("texture","")
 if not textures.has(path):textures[path]=load(path) if ResourceLoader.exists(path) else null
 var texture: Texture2D=textures[path]
 if texture==null:return false
 var fitted := texture.get_size()*minf(box.size.x/texture.get_width(),box.size.y/texture.get_height())
 item.draw_texture_rect(texture,Rect2(box.get_center()-fitted*.5,fitted),false)
 return true
