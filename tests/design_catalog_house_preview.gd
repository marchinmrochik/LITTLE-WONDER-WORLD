extends LivingHouseBoard
var selected := 0
func _process(_delta: float) -> void:pass
func _draw() -> void:
 if game==null:return
 var factor := camera_scale();draw_set_transform(image_rect().position-view.position*factor,0,Vector2.ONE*factor)
 draw_part(selected)
 if game.parts[selected].id=="chimney":draw_smoke(age)
 draw_set_transform(Vector2.ZERO)
