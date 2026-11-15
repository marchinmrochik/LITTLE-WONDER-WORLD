class_name ArtworkGallery
extends VBoxContainer

signal opened(id: String)
signal delete_requested(id: String)
signal back_requested
var allow_delete := false

func _ready() -> void:
	add_theme_constant_override("separation", 16)
	refresh()

func refresh() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	var header := UiKit.row(16)
	add_child(header)
	header.add_child(UiKit.label("GALLERY", 32, UiKit.GREEN))
	header.add_child(UiKit.spacer())
	var back := UiKit.button("DRAW_BACK", func() -> void: back_requested.emit(), UiKit.MINT, "previous")
	back.name = "BackToDrawing"
	header.add_child(back)
	var count := UiKit.label("", 21, UiKit.MUTED)
	count.text = LocalizationManager.text("DRAW_GALLERY_COUNT").format({"count":ArtworkManager.entries.size(),"limit":ArtworkManager.MAX_ENTRIES})
	add_child(count)
	if ArtworkManager.last_error != OK:
		add_child(UiKit.paragraph("SAVE_ERROR"))
	if ArtworkManager.entries.is_empty():
		add_child(UiKit.paragraph("GALLERY_EMPTY" if ArtworkManager.status != "incompatible" else "INCOMPATIBLE"))
		return
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	scroll.add_child(grid)
	for entry: Dictionary in ArtworkManager.entries:
		var card := UiKit.card()
		card.custom_minimum_size = Vector2(320, 250)
		grid.add_child(card)
		var column := UiKit.column(10)
		card.add_child(column)
		var image := TextureRect.new()
		image.texture = ArtworkManager.thumbnail(entry.id)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(260, 156)
		column.add_child(image)
		var open := UiKit.button("DRAW_OPEN" if image.texture != null else "DRAW_DAMAGED", _open_item.bind(entry.id), UiKit.MINT)
		open.name = "Open_" + entry.id
		open.disabled = image.texture == null
		column.add_child(open)
		if allow_delete:
			var remove := UiKit.button("DRAW_DELETE", _remove_item.bind(entry.id), UiKit.CORAL)
			remove.name = "Delete_" + entry.id
			column.add_child(remove)

func _open_item(id: String) -> void:
	opened.emit(id)

func _remove_item(id: String) -> void:
	delete_requested.emit(id)
