class_name GDShellMain
extends Node


const UI_HANDLER_PATH: String = "res://addons/gdshell/ui/default_ui/default_ui.tscn"
const DEFAULT_COMMAND_DIR: String = "res://addons/gdshell/commands/"

signal _input_submitted(input: String)

var _is_command_awaiting_input: bool = false
var _input_temp: String = ""

var command_runner: GDShellCommandRunner
var command_db: GDShellCommandDB
var ui_handler: GDShellUIHandler



func _ready() -> void:
	_setup()


func _setup() -> void:
	command_runner = GDShellCommandRunner.new()
	command_runner._PARENT_GDSHELL = self
	add_child(command_runner)
	
	@warning_ignore(unsafe_cast, unsafe_method_access)
	ui_handler = (load(UI_HANDLER_PATH).instantiate() as GDShellUIHandler)
	ui_handler._PARENT_GDSHELL = self
	add_child(ui_handler)
	
	command_db = GDShellCommandDB.new()
	command_db.add_commands_in_directory(DEFAULT_COMMAND_DIR)
	if "autorun" in command_db.get_all_command_names():
		execute("autorun")


func execute(input: String) -> Dictionary:
	var command_sequence: Dictionary = GDShellCommandParser.parse(input, command_db)
	if command_sequence["status"] == GDShellCommandParser.ParserResultStatus.OK:
		return await command_runner.execute(command_sequence)
	return command_sequence


func _get_ui_handler() -> GDShellUIHandler:
	return ui_handler


func _get_ui_handler_rich_text_label() -> RichTextLabel:
	return ui_handler._get_output_rich_text_label()


func _request_input_from_ui_handler(out: String="") -> String:
	_is_command_awaiting_input = true
	ui_handler._input_requested.emit(out)
	return await _input_submitted


func _request_output_from_ui_handler(output: String, append_new_line: bool) -> void:
	ui_handler._output_requested.emit(output, append_new_line)


func _submit_input(input: String) -> void:
	if _is_command_awaiting_input:
		_is_command_awaiting_input = false
		_request_output_from_ui_handler(input, true)
		_input_submitted.emit(input)
		return
	
	
	_input_temp += input
	var command_sequence: Dictionary = GDShellCommandParser.parse(_input_temp, command_db)
	match command_sequence["status"]:
		GDShellCommandParser.ParserResultStatus.OK:
			_request_output_from_ui_handler((ui_handler._get_input_prompt() if input == _input_temp else "") + input, true)
			_input_temp = ""
			await command_runner.execute(command_sequence)
			ui_handler._input_requested.emit("")
		GDShellCommandParser.ParserResultStatus.UNTERMINATED:
			_request_output_from_ui_handler((ui_handler._get_input_prompt() if input == _input_temp else "") + input, true)
			ui_handler._input_requested.emit("> ")
		GDShellCommandParser.ParserResultStatus.ERROR:
			_request_output_from_ui_handler(ui_handler._get_input_prompt() + _input_temp, true)
			_input_temp = ""
			# TODO better error announcement
			_request_output_from_ui_handler("[color=red]%s[/color]" % command_sequence["result"]["error"], true)
			ui_handler._input_requested.emit("")


static func get_gdshell_version() -> String:
	var config: ConfigFile = ConfigFile.new()
	if config.load("res://addons/gdshell/plugin.cfg"):
		return "Unknown"
	return str(config.get_value("plugin", "version", "Unknown"))
