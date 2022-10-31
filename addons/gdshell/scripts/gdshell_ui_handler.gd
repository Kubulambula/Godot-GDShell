class_name GDShellUIHandler
extends Control
@icon("res://addons/gdshell/icon.png")


signal _input_requested(output: String)
signal _output_requested(output: String, append_new_line: bool)


var _PARENT_GDSHELL: GDShellMain


func submit_input(input: String) -> void:
	_PARENT_GDSHELL._submit_input(input)


func _get_output_rich_text_label() -> RichTextLabel:
	push_error("'_get_output_rich_text_label()' is not implemented for the custom GDShellUIHandler.")
	return null


func _get_input_prompt() -> String:
	return ""
