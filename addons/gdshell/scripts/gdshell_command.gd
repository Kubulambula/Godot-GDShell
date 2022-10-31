class_name GDShellCommand
extends Node
@icon("res://addons/gdshell/icon.png")


signal command_end


const DEFAULT_COMMAND_PARAMS: Dictionary = {
		"argv": [],
		"data": null,
	}

const DEFAULT_COMMAND_RESULT: Dictionary = {
		"error": 0,
		"error_string": "No error description",
		"data": null,
	}

@warning_ignore(unsafe_method_access)
var COMMAND_NAME: String = get_script().get_path().get_file().get_basename()
var COMMAND_AUTO_ALIASES: Dictionary = {}
var COMMAND_MANUAL: String = ""

# Waiting for https://github.com/godotengine/godot/pull/65752
#var _PARENT_PROCESS: GDShellCommandRunner
var _PARENT_PROCESS


func _main(_params: Dictionary) -> Dictionary:
	return DEFAULT_COMMAND_RESULT


func execute(_input: String) -> Dictionary:
	return await _PARENT_PROCESS._handle_execute(_input)


func input(out: String="") -> String:
	return await _PARENT_PROCESS._handle_input(self, out)


func output(out: String, append_new_line: bool=true) -> void:
	_PARENT_PROCESS._handle_output(out, append_new_line)


func get_ui_handler() -> GDShellUIHandler:
	return _PARENT_PROCESS._handle_get_ui_handler()


func get_ui_handler_rich_text_label() -> RichTextLabel:
	return _PARENT_PROCESS._handle_get_ui_handler_rich_text_label()


func end_command() -> void:
	command_end.emit()


static func get_default_command_params() -> Dictionary:
	return DEFAULT_COMMAND_PARAMS


static func get_default_command_result() -> Dictionary:
	return DEFAULT_COMMAND_RESULT
