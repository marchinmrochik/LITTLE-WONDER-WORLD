extends Control

var gallery: ArtworkGallery

func _ready() -> void:
	gallery = ArtworkGallery.new()
	gallery.allow_delete = true
	add_child(gallery)
	gallery.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gallery.back_requested.connect(func() -> void: GameManager.navigate("settings"))
	gallery.opened.connect(func(id: String) -> void:
		ArtworkManager.pending_open_id = id
		GameManager.start_game(ArtworkManager.artwork_route(id))
	)
	gallery.delete_requested.connect(func(id: String) -> void:
		get_tree().get_first_node_in_group("app_root")._show_confirmation("DRAW_DELETE_TITLE", "DRAW_DELETE_HINT", "DRAW_DELETE", func() -> void:
			ArtworkManager.remove_artwork(id)
			gallery.refresh()
		)
	)
