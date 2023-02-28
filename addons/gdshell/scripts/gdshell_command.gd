@icon("res://addons/gdshell/icon.png")
class_name GDShellCommand
extends Node


signal command_end

const DEFAULT_COMMAND_RESULT: Dictionary = {
	"error": 0,
	"error_string": "No error description",
	"data": null,
}

@warning_ignore("unsafe_method_access")
var COMMAND_NAME: String = get_script().get_path().get_file().get_basename()
var COMMAND_AUTO_ALIASES: Dictionary = {}

var _PARENT_PROCESS: GDShellCommandRunner


func _main(_argv: Array, _data) -> Dictionary:
	return DEFAULT_COMMAND_RESULT


func execute(command: String) -> Dictionary:
	return await _PARENT_PROCESS._handle_execute(command)


func input(out: String = "") -> String:
	return await _PARENT_PROCESS._handle_input(self, out)


func output(out, append_new_line: bool = true) -> void:
	_PARENT_PROCESS._handle_output(str(out), append_new_line)


func get_ui_handler() -> GDShellUIHandler:
	return _PARENT_PROCESS._handle_get_ui_handler()


func get_ui_handler_rich_text_label() -> RichTextLabel:
	return _PARENT_PROCESS._handle_get_ui_handler_rich_text_label()


func _get_manual() -> String:
	return (
"""
[b]NAME[/b]
	{COMMAND_NAME}

[b]AUTO ALIASES[/b]
	{COMMAND_AUTO_ALIASES}

[b]NO MANUAL[/b]
	-Override the [b]_get_manual()[/b] function for a custom manual page.
""".format(
			{
				"COMMAND_NAME": COMMAND_NAME,
				"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
			}
		)
	)


static func argv_parse_options(argv: Array, strip_name_dashes: bool = false, next_arg_as_value: bool = false) -> Dictionary:
	var options: Dictionary = {}
	for i in argv.size():
		if argv[i][0] == "-":
			var option_name: String = argv[i].get_slice("=", 0).lstrip("-") if strip_name_dashes else argv[i].get_slice("=", 0)
			var option_value: String = argv[i].get_slice("=", 1) if "=" in argv[i] else ""
			if (
					option_value.length() == 0 and next_arg_as_value and not "=" in argv[i]
					and i+1 < argv.size() and argv[i+1][0] != "-"
			):
				option_value = argv[i+1]
			
			options[option_name] = option_value
	
	return options
