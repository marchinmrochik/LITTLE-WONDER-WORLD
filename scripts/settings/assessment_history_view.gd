extends Control
var table: GridContainer
func _ready() -> void:
	var column := UiKit.column(14);add_child(column);column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var top := UiKit.row(14);column.add_child(top)
	top.add_child(UiKit.button("BACK",func() -> void:GameManager.navigate("settings"),UiKit.MINT,"previous"))
	top.add_child(UiKit.label("HISTORY_TITLE",34,UiKit.GREEN))
	column.add_child(UiKit.paragraph("HISTORY_LIMIT",20))
	column.add_child(UiKit.paragraph("PROGRESS_HINT",18))
	if AssessmentHistory.last_save_error!=OK or AssessmentHistory.load_status in ["incompatible","unreadable","recovered"]:
		column.add_child(UiKit.paragraph("SAVE_ERROR" if AssessmentHistory.last_save_error!=OK else AssessmentHistory.load_status.to_upper(),20))
	var scroll := ScrollContainer.new();scroll.name="HistoryScroll";scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;column.add_child(scroll)
	if AssessmentHistory.document.sessions.is_empty():
		scroll.add_child(UiKit.paragraph("HISTORY_EMPTY",23));return
	var card := UiKit.card();card.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(card)
	table=GridContainer.new();table.name="HistoryTable";table.columns=6
	table.add_theme_constant_override("h_separation",12);table.add_theme_constant_override("v_separation",18);card.add_child(table)
	for key: String in ["HISTORY_DATE","HISTORY_TOPIC","HISTORY_MODE","HISTORY_FIRST","HISTORY_HELP","HISTORY_COMPARE"]:cell(LocalizationManager.text(key),true)
	var rows: Array=AssessmentHistory.document.sessions.duplicate();rows.reverse()
	for row: Dictionary in rows:
		var date: String=row.started.replace("T","\n").left(16)
		cell(date)
		var topic := WorldCatalog.topic(row.topic)
		cell(LocalizationManager.text(topic.get("title_key","HISTORY_UNKNOWN")))
		cell(LocalizationManager.text("ENGLISH" if row.locale=="en" else "UKRAINIAN")+"\n"+LocalizationManager.text(row.difficulty.to_upper()))
		if row.status!="completed":
			cell(LocalizationManager.text("HISTORY_INCOMPLETE"));cell("—");cell("—");continue
		var stats := AssessmentHistory.metrics(row)
		cell(str(stats.independent)+" / 5")
		var help := cell(str(stats.assisted)+" / 5")
		help.tooltip_text=LocalizationManager.text("HISTORY_RETRIES").format({"count":stats.retries})
		var previous := AssessmentHistory.previous_comparable(row.id)
		cell(LocalizationManager.text("HISTORY_NO_MATCH") if previous.is_empty() else "%d/5 → %d/5" % [AssessmentHistory.metrics(previous).independent,stats.independent])

func cell(text: String,heading: bool=false) -> Label:
	var label := UiKit.label("",20,UiKit.GREEN if heading else UiKit.INK)
	label.text=text;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	var widths := [145,135,180,160,150,210]
	label.custom_minimum_size=Vector2(widths[table.get_child_count()%6],45)
	label.mouse_filter=Control.MOUSE_FILTER_PASS
	table.add_child(label)
	return label
