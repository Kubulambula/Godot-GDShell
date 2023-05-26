@icon("res://addons/gdshell/icon.png")
class_name GDShellMain
extends Node


signal _input_submitted(input: String)


var UI_TOGGLE_ACTION: String = ProjectSettings.get_setting(
	GDShellEditorPlugin.UI_TOGGLE_ACTION,
	GDShellEditorPlugin.UI_TOGGLE_ACTION_DEFAULT
)

var command_runner: GDShellCommandRunner
var command_db: GDShellCommandDB
var ui_handler: GDShellUIHandler

# Internal helper variables
var _is_command_awaiting_input: bool = false
var _input_buffer: String = ""


func _ready() -> void:
	if get_parent() == get_tree().root:  # is singleton
		setup_as_singleton()
	else:
		push_warning("GDShellMain was instanced directly so don't forget to set it up manually. For reference checkout GDShellMain.setup_as_singleton()")


func setup_as_singleton() -> void:
	setup_command_runner()
	
	setup_command_db(
		ProjectSettings.get_setting(
			GDShellEditorPlugin.COMMAND_SCANNED_DIRECTORIES,
			GDShellEditorPlugin.COMMAND_SCANNED_DIRECTORIES_DEFAULT
		)
	)
	
	setup_ui_handler(
		GDShellMain.load_ui_handler_from_path(
			ProjectSettings.get_setting(
				GDShellEditorPlugin.UI_SCENE_PATH,
				GDShellEditorPlugin.UI_SCENE_PATH_DEFAULT
			)
		),
		true,
		ProjectSettings.get_setting(
			GDShellEditorPlugin.UI_CANVAS_LAYER,
			GDShellEditorPlugin.UI_CANVAS_LAYER_DEFAULT
		)
	)
	
	execute_autorun()


func setup_command_runner() -> void:
	command_runner = GDShellCommandRunner.new()
	command_runner._PARENT_GDSHELL = self
	add_child(command_runner)


func setup_command_db(command_dir_paths: Array) -> void:
	command_db = GDShellCommandDB.new()
	
	if (
		command_dir_paths.is_empty()
		or command_dir_paths.all(
			func(path): return typeof(path) != TYPE_STRING
		)
		or not command_dir_paths.any(
			func(path): return DirAccess.dir_exists_absolute(path)
		)
	):
		push_error("[GDShell] No commands were loaded as there are no dir paths in 'Project/ProjectSettings/%s'" % GDShellEditorPlugin.COMMAND_SCANNED_DIRECTORIES)
		return
	
	for dir in command_dir_paths:
		if typeof(dir) == TYPE_STRING:
			command_db.add_commands_in_directory(dir)


func setup_ui_handler(handler: GDShellUIHandler, add_as_child: bool = true, canvas_layer: int = 100) -> void:
	ui_handler = handler
	ui_handler._PARENT_GDSHELL = self
	ui_handler.set_visible(false)
	
	if add_as_child:
		var cl: CanvasLayer = CanvasLayer.new()
		cl.layer = canvas_layer
		cl.add_child(handler)
		add_child(cl)


func execute_autorun() -> void:
	if "autorun" in command_db.get_all_command_names():
		@warning_ignore("return_value_discarded")
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
	@warning_ignore("unsafe_cast", "unsafe_method_access")
	return load(path).instantiate() as GDShellUIHandler


static func get_gdshell_version() -> String:
	var config: ConfigFile = ConfigFile.new()
	if config.load("res://addons/gdshell/plugin.cfg"):
		return "Unknown"
	return str(config.get_value("plugin", "version", "Unknown"))


func _input(event: InputEvent) -> void:
	if event.is_action(UI_TOGGLE_ACTION) and not event.is_echo() and event.is_pressed():
		ui_handler.toggle_visible()
