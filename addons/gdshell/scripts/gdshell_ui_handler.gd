@icon("res://addons/gdshell/icon.png")
class_name GDShellUIHandler
extends Control


signal _input_requested(output: String)
signal _output_requested(output: String, append_new_line: bool)

var _PARENT_GDSHELL: GDShellMain

var history: Array = []
var hist_index = -1

func submit_input(input: String) -> void:
	_PARENT_GDSHELL._submit_input(input)
	history.push_front(input)
	history_reset_index()

func autocomplete(input: String) -> String:
	var all_commands = _PARENT_GDSHELL.command_db.get_all_command_names()
	var matches = all_commands.filter(func(str: String): return str.begins_with(input))
	if matches.size() > 0:
		return matches[0]
	return input
	
func history_get_next() -> String:
	if (history.size() == 0):
		return ""
	hist_index = clamp(hist_index + 1, 0, history.size() - 1)
	return history[hist_index]
	
func history_get_previous() -> String:
	if (history.size() == 0):
		return ""
	hist_index = clamp(hist_index - 1, 0, history.size() - 1)
	return history[hist_index]
	
func history_reset_index() -> void:
	hist_index = -1

func toggle_visible() -> void:
	visible = not visible


func _get_output_rich_text_label() -> RichTextLabel:
	push_error("'_get_output_rich_text_label()' is not implemented for the custom GDShellUIHandler.")
	return null


func _get_input_prompt() -> String:
	return ""
