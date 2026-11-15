extends SeasonalDrawingBoard
var selected := 0
func _process(_delta: float) -> void:pass
func _draw() -> void:
 if game!=null:draw_actor(game.parts[selected])
