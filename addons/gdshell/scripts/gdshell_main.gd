@icon("res://addons/gdshell/icon.png")
class_name GDShellMain
extends Node


signal _input_submitted(input: String)

const GDSHELL_TOGGLE_UI_ACTION: String = "gdshell_toggle_ui"

const COMMAND_DIR_PATH: String = "res://addons/gdshell/commands/"

const UI_HANDLER_PATH: String = "res://addons/gdshell/ui/default_ui/default_ui.tscn"
const GDSHELL_CANVAS_LAYER: int = 100

var command_runner: GDShellCommandRunner
var command_db: GDShellCommandDB
var ui_handler: GDShellUIHandler

var execute_autorun_on_startup: bool = true
var handle_gdshell_toggle_ui_action: bool = true

# Internal helper variables
var _is_command_awaiting_input: bool = false
var _input_buffer: String = ""


func _ready() -> void:
	if get_parent() == get_tree().root:  # is singleton
		setup_with_default_values()
	else:
		push_warning("GDShellMain was instanced directly. Don't forget to set it up manually.")


func setup_with_default_values() -> void:
	setup_command_runner()
	setup_command_db(COMMAND_DIR_PATH)
	setup_ui_handler(load_ui_handler_from_path(UI_HANDLER_PATH), true)
	
	if execute_autorun_on_startup:
		execute_autorun()


func setup_command_runner() -> void:
	command_runner = GDShellCommandRunner.new()
	command_runner._PARENT_GDSHELL = self
	add_child(command_runner)


func setup_command_db(command_dir_path: String = "") -> void:
	command_db = GDShellCommandDB.new()
	if not command_dir_path.is_empty():
		command_db.add_commands_in_directory(command_dir_path)


func setup_ui_handler(handler: GDShellUIHandler, add_as_child: bool = true) -> void:
	ui_handler = handler
	ui_handler._PARENT_GDSHELL = self
	ui_handler.set_visible(false)
	
	if add_as_child:
		var canvas_layer: CanvasLayer = CanvasLayer.new()
		canvas_layer.layer = GDSHELL_CANVAS_LAYER
		canvas_layer.add_child(handler)
		add_child(canvas_layer)


func execute_autorun() -> void:
	if "autorun" in command_db.get_all_command_names():
		execute("autorun")


func execute(command: String) -> Dictionary:
	var command_sequence: Dictionary = GDShellCommandParser.parse(command, command_db)
	if command_sequence["status"] == GDShellCommandParser.ParserResultStatus.OK:
		return await command_runner.execute(command_sequence)
	return command_sequence


func get_ui_handler() -> GDShellUIHandler:
	return ui_handler


func get_ui_handler_rich_text_label() -> RichTextLabel:
	return ui_handler._get_output_rich_text_label()


func _request_input_from_ui_handler(out: String = "") -> String:
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
	
	_input_buffer += input
	var command_sequence: Dictionary = GDShellCommandParser.parse(_input_buffer, command_db)
	match command_sequence["status"]:
		GDShellCommandParser.ParserResultStatus.OK:
			_request_output_from_ui_handler(
				(ui_handler._get_input_prompt() if input == _input_buffer else "") + input, true
			)
			_input_buffer = ""
			await command_runner.execute(command_sequence)
			ui_handler._input_requested.emit("")
		GDShellCommandParser.ParserResultStatus.UNTERMINATED:
			_request_output_from_ui_handler(
				(ui_handler._get_input_prompt() if input == _input_buffer else "") + input, true
			)
			ui_handler._input_requested.emit("> ")
		GDShellCommandParser.ParserResultStatus.ERROR:
			_request_output_from_ui_handler(
				ui_handler._get_input_prompt() + _input_buffer, true
			)
			_input_buffer = ""
			# TODO better error announcement
			_request_output_from_ui_handler(
				"[color=red]%s[/color]" % command_sequence["result"]["error"], true
			)
			ui_handler._input_requested.emit("")


static func load_ui_handler_from_path(path: String) -> GDShellUIHandler:
	return load(path).instantiate() as GDShellUIHandler


static func get_gdshell_version() -> String:
	var config: ConfigFile = ConfigFile.new()
	if config.load("res://addons/gdshell/plugin.cfg"):
		return "Unknown"
	return str(config.get_value("plugin", "version", "Unknown"))


func _input(event: InputEvent) -> void:
	if not handle_gdshell_toggle_ui_action:
		return
	if event.is_action(GDSHELL_TOGGLE_UI_ACTION) and not event.is_echo() and event.is_pressed():
		ui_handler.toggle_visible()
