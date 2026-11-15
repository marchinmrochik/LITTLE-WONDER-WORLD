extends Control

var gallery: ArtworkGallery
var export_dialog: FileDialog
var export_id := ""

func _ready() -> void:
	gallery = ArtworkGallery.new()
	gallery.allow_delete = true
	gallery.allow_export = true
	gallery.export_requested.connect(request_export)
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

func request_export(id: String) -> void:
	if is_instance_valid(export_dialog):return
	if ArtworkManager.load_artwork(id) == null:return
	export_id=id
	export_dialog=FileDialog.new()
	export_dialog.access=FileDialog.ACCESS_FILESYSTEM
	export_dialog.file_mode=FileDialog.FILE_MODE_SAVE_FILE
	export_dialog.use_native_dialog=true
	export_dialog.filters=PackedStringArray(["*.png ; PNG"])
	export_dialog.mode_overrides_title=false
	export_dialog.title=LocalizationManager.text("DRAW_EXPORT")
	export_dialog.current_file="little-wonder-"+id+".png"
	export_dialog.file_selected.connect(finish_export)
	export_dialog.canceled.connect(close_export)
	add_child(export_dialog)
	export_dialog.current_dir=OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	export_dialog.popup_file_dialog()

func finish_export(path: String) -> void:
	var result := ArtworkManager.export_artwork(export_id,path)
	gallery.export_status.text=LocalizationManager.text("DRAW_EXPORTED" if result==OK else "DRAW_EXPORT_ERROR")
	close_export()

func close_export() -> void:
	if is_instance_valid(export_dialog):
		export_dialog.queue_free();export_dialog=null
	export_id=""

func handle_back() -> bool:
	if is_instance_valid(export_dialog):close_export();return true
	return false
