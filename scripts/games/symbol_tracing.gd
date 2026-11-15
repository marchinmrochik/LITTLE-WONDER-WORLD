class_name SymbolTracing
extends Control
var data: Dictionary
var pool: Array=[]
var bag: Array[int]=[]
var mode := "letters"
var show_mode_switch := true
var fixed_mode := ""
var current_index := -1
var stroke_index := 0
var trace := GuidedTrace.new()
var board := SymbolTraceBoard.new()
var overlay_paused := false
var focus_paused := false
var celebrating := false
var celebration_age := 0.0
var spoken_key := ""
var repetitions := 0
var mode_buttons: Dictionary={}
func _ready() -> void:
 data=JSON.parse_string(FileAccess.get_file_as_string("res://data/game_content/symbol_tracing.json"))
 var column := UiKit.column(10);add_child(column);column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var row := UiKit.row(12);column.add_child(row)
 for id: String in (["letters","digits"] if show_mode_switch else []):
  var button := UiKit.button("TRACE_LETTERS" if id=="letters" else "TRACE_NUMBERS",choose_mode.bind(id),UiKit.MINT if id==mode else UiKit.CREAM)
  button.name="TraceLetters" if id=="letters" else "TraceDigits";mode_buttons[id]=button;row.add_child(button)
 row.add_child(UiKit.spacer())
 var repeat := UiKit.tool_button("VOICE_TEST",repeat_symbol,"speaker");repeat.name="RepeatSymbol";row.add_child(repeat)
 var restart := UiKit.tool_button("TRACE_AGAIN",restart_symbol,"replay");restart.name="RestartSymbol";row.add_child(restart)
 var hint := UiKit.paragraph("TRACE_HINT",24);hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(hint)
 board.lesson=self;board.size_flags_vertical=Control.SIZE_EXPAND_FILL;column.add_child(board);board.stroke_finished.connect(finish_stroke)
 choose_mode(mode)
func entry() -> Dictionary:return pool[current_index]
func paused() -> bool:return overlay_paused or focus_paused
func choose_mode(value: String) -> void:
 if paused() or not value in ["letters","digits"] or (not fixed_mode.is_empty() and value!=fixed_mode):return
 AudioManager.stop_voice();mode=value;bag.clear();current_index=-1;pool=data.letters[SettingsManager.values.locale] if mode=="letters" else data.digits
 for id: String in mode_buttons:
  mode_buttons[id].add_theme_stylebox_override("normal",UiKit.panel(UiKit.MINT if id==mode else UiKit.CREAM,22,18))
 next_symbol();AudioManager.say("TRACE_HINT")
func next_symbol() -> void:
 if bag.is_empty():
  for i: int in range(pool.size()):bag.append(i)
  bag.shuffle()
  if bag.size()>1 and bag[-1]==current_index:var first: int=bag[0];bag[0]=bag[-1];bag[-1]=first
 current_index=bag.pop_back();restart_symbol()
func restart_symbol() -> void:
 if paused():return
 board.cancel_pointer();celebrating=false;celebration_age=0;stroke_index=0;trace.configure(entry().strokes[0]);board.queue_redraw()
func finish_stroke() -> void:
 if paused() or celebrating or not trace.complete:return
 if stroke_index+1<entry().strokes.size():stroke_index+=1;trace.configure(entry().strokes[stroke_index]);AudioManager.play_sfx("tap")
 else:
  celebrating=true;celebration_age=0;repetitions+=1;spoken_key=entry().word_key;AudioManager.say(spoken_key);AudioManager.play_sfx("sparkle")
 board.queue_redraw()
func repeat_symbol() -> void:
 if not paused():AudioManager.say(entry().word_key)
func _process(delta: float) -> void:
 if paused() or not celebrating:return
 celebration_age+=delta
 # Keep the symbol visible until its spoken name and the small fireworks finish.
 if celebration_age>=1.5 and not AudioManager.voice.playing:next_symbol()
func get_idle_action() -> Dictionary:
 if paused() or celebrating:return {}
 return {"from":board.global_position+board.from_world(trace.current_point()),"to":board.global_position+board.from_world(trace.points[trace.edge+1])}
func set_overlay_paused(value: bool) -> void:
 var was_paused := paused();overlay_paused=value;board.cancel_pointer()
 if was_paused and not paused() and celebrating:repeat_symbol()
func set_focus_paused(value: bool) -> void:
 var was_paused := paused();focus_paused=value;board.cancel_pointer()
 if was_paused and not paused() and celebrating:repeat_symbol()
func _exit_tree() -> void:board.cancel_pointer()
