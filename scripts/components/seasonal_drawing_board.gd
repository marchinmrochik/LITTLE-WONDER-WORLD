class_name SeasonalDrawingBoard
extends LivingHouseBoard
var season: String:
 get:return game.story_id
func actor_position(part: Dictionary) -> Vector2:
 var at := Vector2(part.marker[0],part.marker[1])
 if effects.has(part.id) and not SettingsManager.values.reduced_motion:
  var t: float=4.0-effects[part.id]
  if part.id in ["bird","bee","butterfly","kite"]:at+=Vector2(sin(t*2)*45,-absf(sin(t*3))*30)
  elif part.id in ["bunny","frog","penguin","squirrel","sled"]:at+=Vector2(sin(t*PI/4)*90,-absf(sin(t*6))*22)
  else:at.y-=absf(sin(t*5))*5
 return at
func _draw() -> void:
 if game==null:return
 var sky: Color= Color("20364e") if night else {"spring":Color("e2f2eb"),"autumn":Color("f9ead4"),"winter":Color("deedf6")}[season]
 draw_rect(Rect2(Vector2.ZERO,size),sky)
 var scale_factor := camera_scale();var shift := image_rect().position-view.position*scale_factor
 draw_set_transform(shift,0,Vector2.ONE*scale_factor)
 var ground: Color= Color("405d61") if night else {"spring":Color("c1dda8"),"autumn":Color("e7c798"),"winter":Color("f4f8fc")}[season]
 paint_ellipse(Rect2(-450,450,1900,900),ground)
 if night:
  for star: Vector2 in [Vector2(300,10),Vector2(530,-35),Vector2(710,110),Vector2(940,280)]:draw_circle(star,3,Color("ffedb8"))
 if is_done("cloud"):DesignVisuals.sky_clouds(self,game.story_id,age,night)
 # Small non-interactive ground accents belong to the scenery, not hidden guides.
 for i: int in range(18):
  var at := Vector2(40+i*55,700+sin(i*1.8)*20)
  if season=="winter":draw_circle(at,3,Color("c3dbe9"))
  else:draw_line(at,at+Vector2(5,-9),Color("9ab077") if season=="spring" else Color("c59b68"),2,true)
 for i: int in range(game.parts.size()):
  if game.completed[i]:draw_actor(game.parts[i])
  elif i==game.part_index and game.state in [game.State.ZOOMING,game.State.TRACE]:outline(path_for(game.parts[i],0),Color(game.parts[i].color),2)
 if game.state==game.State.READY:
  for i: int in marker_indices():
   var pair: Array=game.parts[i].marker;var at := Vector2(pair[0],pair[1]);var pulse := 1.0 if SettingsManager.values.reduced_motion else 1+sin(age*3+i)*.12
   draw_circle(at,25*pulse/scale_factor,Color(1,.86,.42,.3));draw_circle(at,15/scale_factor,Color("efc65c"));draw_circle(at,15/scale_factor,UiKit.GREEN,false,3/scale_factor,true)
 elif game.state==game.State.TRACE:draw_guide()
 if effects.has("cloud"):
  for i: int in range(32):
   var at := Vector2(35+i*30,140+fmod(age*160+i*43,540))
   if season=="winter":draw_circle(at,4,Color.WHITE)
   else:draw_line(at,at+Vector2(-5,14),Color("7fb6d4"),3,true)
 if effects.has("tree") or effects.has("leaves"):
  for i: int in range(14):
   var at := Vector2(350+i*22+sin(age*2+i)*20,220+fmod(age*60+i*29,350))
   paint_ellipse(Rect2(at,Vector2(10,6)),Color("efc1cf") if season=="spring" else Color("c8794c"))
 draw_set_transform(Vector2.ZERO)
func polygon(points: Array,color: Color) -> void:
 var path := PackedVector2Array()
 for point: Vector2 in points:path.append(point)
 draw_colored_polygon(path,color)
func face(at: Vector2,color: Color=Color("344a42")) -> void:
 for x: int in [-10,10]:draw_circle(at+Vector2(x,-3),2.5,color)
 draw_arc(at+Vector2(0,3),7,0,PI,12,color,2,true)
func draw_actor(part: Dictionary) -> void:
 var actor_center := actor_position(part);var box: Array=part.box
 var world_scale := camera_scale();var shift := image_rect().position-view.position*world_scale
 draw_set_transform(shift,0,Vector2.ONE*world_scale)
 var reactive: bool=effects.has(part.id)
 var rotation := 0.0 if not reactive or SettingsManager.values.reduced_motion else age*.3 if part.id=="snowflake" else sin(age*5)*.045
 draw_set_transform(shift+actor_center*world_scale,rotation,Vector2.ONE*world_scale)
 if DesignVisuals.draw(self,"story/"+game.story_id+"/"+str(part.id),Rect2(-Vector2(box[2],box[3])*.5,Vector2(box[2],box[3])),"night" if night else "active" if reactive else "idle"):
  if reactive and part.id in ["star","gift","rainbow","lantern"]:
   draw_set_transform(shift+actor_center*world_scale,0,Vector2.ONE*minf(box[2],box[3])/100.0*world_scale);draw_sparkles(age)
  if reactive and part.id in ["pond","puddle"]:
   draw_set_transform(shift+actor_center*world_scale,0,Vector2.ONE*world_scale)
   for ring: int in range(3):draw_arc(Vector2.ZERO,(ring+1)*box[2]*.12+sin(age*3)*3,0,TAU,48,Color("e8f3e8"),2,true)
  draw_set_transform(shift,0,Vector2.ONE*world_scale);return
 var actor_scale: float=minf(box[2],box[3])/100.0
 draw_set_transform(shift+actor_center*world_scale,0,Vector2.ONE*actor_scale*world_scale)
 var active: bool=effects.has(part.id);var t := age if not SettingsManager.values.reduced_motion else 0.0
 var green := Color("639a72");var brown := Color("9d7152");var cream := Color("fff2d7")
 match part.id:
  "tree":
   draw_rect(Rect2(-9,-10,18,105),brown);draw_line(Vector2(0,30),Vector2(-28,0),brown,10,true)
   for circle: Vector3 in [Vector3(-32,-30,36),Vector3(30,-30,36),Vector3(0,-57,39),Vector3(0,0,38)]:draw_circle(Vector2(circle.x,circle.y),circle.z,Color("d99a58") if season=="autumn" else Color("98c387"))
   for i: int in range(7):
    var p := Vector2(sin(i*2)*40,cos(i*3)*35-25)
    if season=="spring":
     for j: int in range(5):draw_circle(p+Vector2.from_angle(j*TAU/5)*5,4,Color("f3c4d2"))
     draw_circle(p,3,Color("f6da80"))
    else:draw_circle(p,5,Color("d7764e"))
  "sun","moon":
   if night or part.id=="moon":draw_circle(Vector2.ZERO,32,Color("fff0b5"));draw_circle(Vector2(15,-10),28,Color("20364e") if night else Color("deedf6"))
   else:
    for i: int in range(12):
     var direction := Vector2.from_angle(i*TAU/12+t*.04);draw_line(direction*39,direction*48,Color("ebbb51"),4,true)
    draw_circle(Vector2.ZERO,32,Color("f4ce67"));face(Vector2.ZERO)
  "cloud":
   for circle: Vector3 in [Vector3(-30,0,20),Vector3(0,-12,27),Vector3(30,0,20)]:draw_circle(Vector2(circle.x,circle.y),circle.z,Color("d1deea") if active else Color.WHITE)
   draw_rect(Rect2(-30,0,60,20),Color("d1deea") if active else Color.WHITE)
  "flowers":
   for x: int in [-28,0,28]:
    var p := Vector2(x,-15+abs(x)*.6);draw_line(p,p+Vector2(0,45),green,4,true)
    for j: int in range(5):draw_circle(p+Vector2.from_angle(j*TAU/5)*12,9,Color("ed9bb9"))
    draw_circle(p,7,Color("f5d472"))
  "bird","bee","butterfly":
   var flap: float= 10+abs(sin(t*11))*13 if active else 14.0
   if part.id=="butterfly":
    paint_ellipse(Rect2(-flap*1.5,-25,flap*1.5,42),Color("e6a0c4"));paint_ellipse(Rect2(0,-25,flap*1.5,42),Color("ae9bd8"));draw_line(Vector2(0,-20),Vector2(0,23),brown,5,true)
   else:
    paint_ellipse(Rect2(-30,-18,60,38),Color("f2ca61") if part.id=="bee" else Color("84b9d0"))
    if part.id=="bee":
     for x: int in [-12,2,16]:draw_line(Vector2(x,-15),Vector2(x,15),brown,5,true)
     paint_ellipse(Rect2(-20,-flap-18,27,flap),Color("d5eef0"))
    else:draw_line(Vector2(-5,-2),Vector2(-22,-flap),Color("548ea6"),7,true)
    draw_circle(Vector2(22,-10),14,Color("f1d28c"));draw_circle(Vector2(26,-13),2.5,UiKit.GREEN);polygon([Vector2(35,-12),Vector2(45,-6),Vector2(35,-4)],Color("db9a53"))
  "nest":
   paint_ellipse(Rect2(-45,-7,90,40),brown)
   for i: int in range(6):draw_line(Vector2(-38+i*8,10),Vector2(-10+i*8,25),Color("c19b72"),3,true)
   for x: int in [-16,8,25]:paint_ellipse(Rect2(x-9,-26,18,28),Color("e3eef0"));draw_circle(Vector2(x,-14),2,Color("b9cdd0"))
   if active:draw_circle(Vector2(0,-18),12,Color("f2d076"));face(Vector2(0,-18))
  "frog":
   paint_ellipse(Rect2(-35,-15,70,47),green)
   for x: int in [-20,20]:draw_circle(Vector2(x,-18),15,Color("8abf83"));draw_circle(Vector2(x,-20),8,Color.WHITE);draw_circle(Vector2(x,-20),4,UiKit.GREEN)
   draw_arc(Vector2(0,-2),18,0,PI,16,UiKit.GREEN,3,true)
  "pond","puddle":
   paint_ellipse(Rect2(-49,-22,98,46),Color("8dc7da"))
   if active:
    for r: int in [18,30,42]:draw_arc(Vector2.ZERO,r+sin(t*4)*3,0,TAU,32,Color("d9eff4"),2,true)
   if part.id=="pond":
    var fish := Vector2(sin(t*2)*24 if active else 8,3);paint_ellipse(Rect2(fish-Vector2(10,5),Vector2(20,10)),Color("e9b365"));polygon([fish+Vector2(-8,0),fish+Vector2(-18,-7),fish+Vector2(-18,7)],Color("e9b365"))
    draw_circle(Vector2(-22,-5),11,Color("6eae82"))
  "rainbow":
   for i: int in range(6):draw_arc(Vector2(0,30),47-i*6,PI,TAU,40,[Color("df8b99"),Color("e9b46b"),Color("edcf75"),Color("9dc38b"),Color("8fbad0"),Color("b6a1cb")][i],6,true)
   if active:draw_sparkles(t)
  "bunny","squirrel","hedgehog":
   if part.id=="hedgehog":
    for i: int in range(10):polygon([Vector2(-40+i*8,8),Vector2(-36+i*8,-36-abs(sin(i))*10),Vector2(-26+i*8,10)],brown)
    paint_ellipse(Rect2(-36,-16,75,45),Color("d7b58b"));draw_circle(Vector2(28,5),3,UiKit.GREEN)
   else:
    if part.id=="squirrel":paint_ellipse(Rect2(4,-45,40,70),Color("c98e59"))
    paint_ellipse(Rect2(-24,-5,48,45),Color("dda975") if part.id=="squirrel" else cream)
    draw_circle(Vector2(-6,-19),23,Color("dda975") if part.id=="squirrel" else cream)
    for x: int in [-19,5]:paint_ellipse(Rect2(x,-65,13,40 if part.id=="bunny" else 24),Color("dda975") if part.id=="squirrel" else cream)
    face(Vector2(-6,-18));draw_circle(Vector2(-6,-13),3,Color("df9aa0"))
    if active:polygon([Vector2(-10,10),Vector2(14,8),Vector2(0,34)],Color("e99d55"))
  "leaves":
   for i: int in range(5):
    var at := Vector2(sin(i*2)*25,cos(i*2)*25);polygon([at+Vector2(0,-18),at+Vector2(14,0),at+Vector2(0,18),at+Vector2(-10,0)],Color("d98653") if i%2==0 else Color("edbb64"));draw_line(at+Vector2(0,-12),at+Vector2(0,20),brown,2,true)
  "mushrooms":
   for x: int in [-24,20]:
    draw_rect(Rect2(x-7,-5,14,39),cream);draw_circle(Vector2(x,-10),24,Color("cf7c6c"));draw_rect(Rect2(x-27,-8,54,12),Color("cf7c6c"));draw_circle(Vector2(x-9,-18),4,cream);draw_circle(Vector2(x+8,-10),4,cream)
  "pumpkin":
   for x: int in [-22,0,22]:paint_ellipse(Rect2(x-20,-27,40,62),Color("e8a35a") if x!=0 else Color("f0b166"))
   draw_line(Vector2(0,-25),Vector2(4,-41),green,7,true)
   if active:face(Vector2(0,0))
  "basket":
   draw_arc(Vector2(0,-7),32,PI,TAU,24,brown,5,true)
   for x: int in [-22,0,22]:draw_circle(Vector2(x,-8),13,Color("d68367"));draw_line(Vector2(x,-20),Vector2(x+3,-26),green,3,true)
   polygon([Vector2(-42,0),Vector2(42,0),Vector2(32,36),Vector2(-32,36)],Color("bb9061"))
   for y: int in [8,20,30]:draw_line(Vector2(-30,y),Vector2(30,y),Color("e4bf88"),3,true)
  "kite":
   polygon([Vector2(0,-46),Vector2(32,-7),Vector2(0,24),Vector2(-32,-7)],Color("d498ae"));draw_line(Vector2(0,-46),Vector2(0,24),cream,2,true);draw_line(Vector2(-32,-7),Vector2(32,-7),cream,2,true)
   draw_polyline(PackedVector2Array([Vector2(0,24),Vector2(10,37),Vector2(-8,50),Vector2(8,65)]),brown,2,true)
  "boots":
   for x: int in [-24,16]:polygon([Vector2(x-12,-38),Vector2(x+12,-38),Vector2(x+12,10),Vector2(x+26,16),Vector2(x+26,30),Vector2(x-12,30)],Color("e6ba61"));draw_line(Vector2(x-8,25),Vector2(x+22,25),brown,3,true)
  "cottage":
   draw_rect(Rect2(-43,-20,86,84),Color("cba48c"));polygon([Vector2(-55,-20),Vector2(0,-72),Vector2(55,-20)],Color("8eafbd"));draw_line(Vector2(-48,-21),Vector2(0,-65),Color.WHITE,9,true);draw_line(Vector2(0,-65),Vector2(48,-21),Color.WHITE,9,true)
   draw_rect(Rect2(-9,21,23,43),Color("82a6ae"));draw_rect(Rect2(-32,3,20,23),Color("f5d682") if night or active else Color("c7e7ed"));draw_rect(Rect2(20,3,20,23),Color("f5d682") if night or active else Color("c7e7ed"))
   if active:draw_sparkles(t)
  "pine":
   draw_rect(Rect2(-6,18,12,33),brown)
   for y: int in [14,-9,-30]:polygon([Vector2(0,y-37),Vector2(38+y*.2,y+20),Vector2(-38-y*.2,y+20)],green);draw_line(Vector2(-18,y+7),Vector2(12,y+7),Color.WHITE,5,true)
   if active:
    for i: int in range(7):draw_circle(Vector2(sin(i*3)*25,-25+i*9),4,[Color("e9b568"),Color("df91a7"),Color("a3d1e6")][i%3])
  "snowman":
   draw_circle(Vector2(0,22),30,Color.WHITE);draw_circle(Vector2(0,-14),23,Color.WHITE);draw_rect(Rect2(-28,-41,56,9),Color("577282"));draw_rect(Rect2(-17,-60,34,22),Color("577282"));face(Vector2(0,-14));polygon([Vector2(0,-12),Vector2(23,-7),Vector2(0,-5)],Color("e8a25d"));draw_line(Vector2(-21,5),Vector2(20,5),Color("d58d9a"),8,true)
   for y: int in [15,29]:draw_circle(Vector2(0,y),3,UiKit.GREEN)
   var hand_y := -14+sin(t*5)*15 if active else 0.0
   draw_line(Vector2(-24,12),Vector2(-48,hand_y),brown,4,true);draw_line(Vector2(24,12),Vector2(48,hand_y),brown,4,true)
  "penguin":
   paint_ellipse(Rect2(-30,-42,60,80),Color("587381"));paint_ellipse(Rect2(-22,-15,44,50),cream);face(Vector2(0,-23),cream);polygon([Vector2(-6,-18),Vector2(6,-18),Vector2(0,-9)],Color("e9b15f"))
   for x: int in [-15,15]:paint_ellipse(Rect2(x-13,32,26,9),Color("e9b15f"))
  "sled":
   draw_line(Vector2(-40,29),Vector2(37,29),Color("7195a8"),5,true);draw_arc(Vector2(37,18),11,0,PI/2,12,Color("7195a8"),5,true)
   for x: int in [-25,25]:draw_line(Vector2(x,25),Vector2(x,-1),brown,5,true)
   draw_rect(Rect2(-42,-10,84,16),Color("d39976"));draw_polyline(PackedVector2Array([Vector2(40,-3),Vector2(52,-27),Vector2(62,-20)]),brown,2,true)
  "gift":
   draw_rect(Rect2(-33,-25,66,58),Color("ce95b1"));draw_rect(Rect2(-38,-31,76,13),Color("dca9c0"));draw_line(Vector2(0,-28),Vector2(0,32),Color("f6db95"),9,true)
   for x: int in [-13,13]:draw_arc(Vector2(x,-35),13,0,TAU,24,Color("f6db95"),4,true)
   if active:draw_sparkles(t)
  "lantern":
   if active or night:draw_circle(Vector2.ZERO,47,Color(1,.85,.5,.15))
   draw_rect(Rect2(-22,-22,44,55),Color("f6d58b") if active or night else Color("bdd9e5"));draw_rect(Rect2(-28,-30,56,10),Color("7a94a0"));draw_rect(Rect2(-28,31,56,7),Color("7a94a0"));draw_arc(Vector2(0,-30),17,PI,TAU,18,Color("7a94a0"),4,true)
   draw_line(Vector2(0,-20),Vector2(0,31),cream,3,true)
  "star":
   var points: Array=[]
   for i: int in range(10):points.append(Vector2.from_angle(-PI/2+i*TAU/10)*(42 if i%2==0 else 19))
   polygon(points,Color("f1d381"));face(Vector2.ZERO)
   if active:draw_sparkles(t)
  "snowflake":
   for i: int in range(6):
    var direction := Vector2.from_angle(i*TAU/6+(t*.3 if active else 0));draw_line(direction*5,direction*43,Color("a1c9e2"),4,true)
    for side: float in [-.65,.65]:draw_line(direction*28,direction*28+direction.rotated(PI+side)*16,Color("a1c9e2"),3,true)
 draw_set_transform(shift,0,Vector2.ONE*world_scale)
func draw_sparkles(t: float) -> void:
 for i: int in range(6):draw_circle(Vector2.from_angle(i*TAU/6+t*.5)*48,3,Color("fff0b5"))
func play_object(id: String) -> void:
 effects[id]=4.0;effect_count+=1
 if id in ["sun","moon"]:night=not night
 AudioManager.play_sfx("sparkle" if id in ["star","gift","rainbow","snowflake"] else "tap");queue_redraw()
func object_at(point: Vector2) -> String:
 for i: int in range(game.parts.size()-1,-1,-1):
  if not game.completed[i]:continue
  var part: Dictionary=game.parts[i];var box: Array=part.box
  if Rect2(actor_position(part)-Vector2(box[2],box[3])*.5,Vector2(box[2],box[3])).has_point(point):return part.id
 return ""
