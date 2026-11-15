class_name ParentGate
extends Control

signal unlocked
signal dismissed
var answer := 0
var hint: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.09, 0.19, 0.16, 0.4)
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var card := UiKit.card()
	card.custom_minimum_size = Vector2(640, 0)
	center.add_child(card)
	var content := UiKit.column(22)
	card.add_child(content)
	content.add_child(UiKit.label("PARENT_GATE_TITLE", 34))
	hint = UiKit.label("PARENT_GATE_HINT", 22, UiKit.MUTED)
	content.add_child(hint)
	var first := randi_range(17, 39)
	var second := randi_range(8, 19)
	answer = first + second
	var question := UiKit.label("", 48)
	question.text = "%d + %d = ?" % [first, second]
	question.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(question)
	var options: Array[int] = [answer, answer + 7, answer - 5]
	options.shuffle()
	var choices := UiKit.row()
	content.add_child(choices)
	for value: int in options:
		var choice := UiKit.button("", choose.bind(value), UiKit.MINT)
		choice.text = str(value)
		choice.custom_minimum_size.y = 80
		choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		choices.add_child(choice)
	content.add_child(UiKit.button("CANCEL", dismiss))

func choose(value: int) -> void:
	if value == answer:
		unlocked.emit()
		queue_free()
	else:
		hint.text = LocalizationManager.text("PARENT_GATE_RETRY")

func dismiss() -> void:
	dismissed.emit()
	queue_free()
