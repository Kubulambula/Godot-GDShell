@tool
extends GDShellUIHandler


const DEFAULT_FONT: Font = preload("res://addons/gdshell/ui/fonts/roboto_mono/RobotoMono-Regular.ttf")


# This looks scary, doesn't it?
@export_category("GDShell UI")

@export var font: Font = DEFAULT_FONT:
	set(value):
		if not value:
			value = DEFAULT_FONT
		font = value
		if not is_inside_tree():
			await ready
		%OutputRichTextLabel.add_theme_font_override("normal_font", font)
		%InputPromptLabel.add_theme_font_override("font", font)
		%InputLineEdit.add_theme_font_override("font", font)
@export_group("Input Bar")
@export var input_prompt: String = "gdsgell@godot$> ":
	set(value):
		input_prompt = value
		if not is_inside_tree():
			await ready
		%InputPromptLabel.text = input_prompt
@export var input_bar_color: Color = Color("2d3238"):
	set(value):
		input_bar_color = value
		if not is_inside_tree():
			await ready
		%InputBarPanel.get_theme_stylebox(&"panel").bg_color = value
@export var input_bar_uneditable_color: Color = Color("252b34"):
	set(value):
		input_bar_uneditable_color = value

@export_group("Backgroud")
@export var background_color: Color = Color("1d2229b4"):
	set(value):
		background_color = value
		if not is_inside_tree():
			await ready
		%BackgroundPanel.get_theme_stylebox(&"panel").bg_color = value


@onready var output_rich_text_label: RichTextLabel = %OutputRichTextLabel as RichTextLabel
@onready var input_bar_panel: Panel = %InputBarPanel as Panel
@onready var input_prompt_label: Label = %InputPromptLabel as Label
@onready var input_line_edit: LineEdit = %InputLineEdit as LineEdit
@onready var background_panel: Panel = %BackgroundPanel as Panel


var _is_input_requested: bool = true:
	set(value):
		_is_input_requested = value
		
		if _is_input_requested:
			input_line_edit.editable = true
			input_line_edit.grab_focus()
			input_bar_panel.get_theme_stylebox(&"panel").bg_color = input_bar_color
		else:
			input_line_edit.editable = false
			input_bar_panel.get_theme_stylebox(&"panel").bg_color = input_bar_uneditable_color


func _ready():
	set_deferred(&"_is_input_requested", true)
	_input_requested.connect(_handle_input)
	_output_requested.connect(_handle_output)
	input_line_edit.grab_focus()
	font = font

# Regrab input_line_edit focus when lost
#func _on_input_line_edit_focus_exited():
#	input_line_edit.grab_focus.call_deferred() # You have to call it deffered or it will not work


func _handle_input(out: String) -> void:
	set_deferred(&"_is_input_requested", true)
	_handle_output(out, false)


func _handle_output(output: String, append_new_line: bool=true) -> void:
	output_rich_text_label.append_text(("%s\n" if append_new_line else "%s") % output)


func _on_input_line_edit_text_submitted(input: String) -> void:
	input_line_edit.clear()
	if _is_input_requested:
		submit_input(input)
		_is_input_requested = false


func _get_output_rich_text_label() -> RichTextLabel:
	return output_rich_text_label


func _get_input_prompt() -> String:
	return input_prompt
