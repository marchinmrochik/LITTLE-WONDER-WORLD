class_name ArtworkGallery
extends VBoxContainer

signal opened(id: String)
signal delete_requested(id: String)
signal export_requested(id: String)
signal back_requested
var allow_delete := false
var allow_export := false
var export_status: Label
var scroll: TouchScroll
var grid: Control
var cards: Array[PanelContainer]=[]
var thumbnails: Dictionary={}
var signature := ""

func _ready() -> void:
	add_theme_constant_override("separation",12)
	refresh()

func refresh() -> void:
	for child: Node in get_children():remove_child(child);child.queue_free()
	cards.clear();thumbnails.clear();signature=""
	var header := UiKit.row(16);add_child(header)
	header.add_child(UiKit.label("GALLERY",32,UiKit.GREEN));header.add_child(UiKit.spacer())
	var back := UiKit.button("DRAW_BACK",func() -> void:back_requested.emit(),UiKit.MINT,"previous")
	back.name="BackToDrawing";header.add_child(back)
	var count := UiKit.label("",21,UiKit.MUTED)
	count.text=LocalizationManager.text("DRAW_GALLERY_COUNT").format({"count":ArtworkManager.entries.size(),"limit":ArtworkManager.MAX_ENTRIES});add_child(count)
	export_status=UiKit.label("",19,UiKit.GREEN);export_status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;add_child(export_status)
	if ArtworkManager.last_error!=OK:export_status.text=LocalizationManager.text("SAVE_ERROR")
	if ArtworkManager.entries.is_empty():
		add_child(UiKit.paragraph("GALLERY_EMPTY" if ArtworkManager.status!="incompatible" else "INCOMPATIBLE"));return
	scroll=TouchScroll.new();scroll.name="ArtworkScroll";scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
	grid=Control.new();grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(grid)
	scroll.get_v_scroll_bar().value_changed.connect(func(_v: float) -> void:sync())
	scroll.resized.connect(func() -> void:call_deferred("sync"));sync();call_deferred("sync")

func sync() -> void:
	if not is_instance_valid(scroll):return
	var width := maxf(900 if scroll.size.x<=0 else 300,scroll.size.x-scroll.get_v_scroll_bar().size.x)
	var columns := clampi(floori(width/300),1,3)
	var row_height := 380.0 if allow_delete else 280.0
	grid.custom_minimum_size.y=ceili(ArtworkManager.entries.size()/float(columns))*row_height
	var first := maxi(0,floori(scroll.scroll_vertical/row_height)-1)*columns
	var count := maxi(0,mini(ArtworkManager.entries.size()-first,(ceili(maxf(400,scroll.size.y)/row_height)+2)*columns))
	var next_signature := str([first,count,width,columns])
	if signature==next_signature:return
	signature=next_signature
	while cards.size()<count:
		var card := UiKit.card();card.add_theme_stylebox_override("panel",UiKit.panel(UiKit.CREAM,24,12));grid.add_child(card);cards.append(card)
		var content := UiKit.column(6);card.add_child(content)
		var image := TextureRect.new();image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;image.custom_minimum_size=Vector2(200,125);image.size_flags_vertical=Control.SIZE_EXPAND_FILL;content.add_child(image)
		var open := UiKit.button("DRAW_OPEN",func() -> void:opened.emit(str(card.get_meta("id"))),UiKit.MINT);content.add_child(open)
		if allow_export:
			var export_button := UiKit.button("DRAW_EXPORT",func() -> void:export_requested.emit(str(card.get_meta("id"))),UiKit.CREAM,"save");content.add_child(export_button)
		if allow_delete:
			var remove := UiKit.button("DRAW_DELETE",func() -> void:delete_requested.emit(str(card.get_meta("id"))),UiKit.CORAL);content.add_child(remove)
	for i: int in range(cards.size()):
		var card := cards[i];card.visible=i<count
		if not card.visible:continue
		var index := first+i;var id: String=ArtworkManager.entries[index].id
		card.set_meta("id",id);card.position=Vector2((index%columns)*width/columns,floori(index/float(columns))*row_height);card.size=Vector2(width/columns-12,row_height-12)
		if not thumbnails.has(id):
			if thumbnails.size()>=24:thumbnails.erase(thumbnails.keys()[0])
			thumbnails[id]=ArtworkManager.thumbnail(id)
		var content: Node=card.get_child(0);content.get_child(0).texture=thumbnails[id]
		var open: ChildButton=content.get_child(1);open.name="Open_"+id;open.disabled=thumbnails[id]==null;open.text=LocalizationManager.text("DRAW_DAMAGED" if open.disabled else "DRAW_OPEN")
		var next := 2
		if allow_export:content.get_child(next).name="Export_"+id;content.get_child(next).disabled=open.disabled;next+=1
		if allow_delete:content.get_child(next).name="Delete_"+id
