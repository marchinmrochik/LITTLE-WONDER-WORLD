class_name FoodCard
extends DragCard

# Compatibility name for the existing feeding activity.
var food_id: String:
	get:
		return item_id
	set(value):
		item_id = value
