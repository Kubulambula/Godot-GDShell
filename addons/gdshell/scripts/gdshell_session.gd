@icon("res://addons/gdshell/icon.png")
class_name GDShellSession
extends Node


signal input_requested()
signal output_submitted(output: String)


signal _input_submitted(input: String)

var command_runner: GDShellCommandRunner
var command_db: GDShellCommandDB
var ui_handler: GDShellUIHandler

# Internal helper variables
var _ui_handler_canvas_layer: CanvasLayer
var _input_buffer: String = ""
var _input_requested: bool = false


func _ready() -> void:
	#print(GDShellCommand._reverse_flag_option_dictionary({"hello": "world", "test": ["foo", "bar", "baz"], "kokot": ["x", "y", "z"]}))
	
	#print(GDShellCommand.argv_parse(["a=x=x"], {}, {"foo": "a"}))
	#print(str_to_var("nulll") == null)
	#return
	command_db = GDShellCommandDB.new()
	printerr(command_db.add_command_from_file("res://addons/gdshell/commands/autorun.gd"))
	printerr(command_db.add_command_from_file("res://addons/gdshell/commands/test.gd"))
	var runner: GDShellCommandRunner = GDShellCommandRunner.new()
	add_child(runner, false, InternalMode.INTERNAL_MODE_FRONT)
	#var result: GDShellCommandRunner.RunnerResult = await runner.execute("autorun&", self)
	#printerr(result.error_description)
	
	
	
	#database.add_commands_from_directory("res://addons/gdshell/commands/")
	
	#print(database._commands)
	#
	#
	#print("ahoj".match("a*"))
	#return
	
	#var result = GDShellExpressionCompiler.compile("'        ahoj svete command' ; kokot")
	#print(result.input_expression_error_start_index)
	#print(result.description)
	#print(JSON.stringify(result.result, "\t", false))
	
	#if "autorun" in command_db.get_all_command_names():
		#@warning_ignore("return_value_discarded")
		#execute("autorun")


#func foo(stri):
	#print(stri)
	#stri = "foo"
	#print(stri)



func execute(expression: String) -> GDShellCommand.CommandResult:
	var compiled_expression: GDShellExpressionCompiler.CompilerResult = GDShellExpressionCompiler.compile(expression)
	if compiled_expression.status != GDShellExpressionCompiler.CompilerResult.Status.OK:
		# TODO: error reporting
		return null
	return execute_compiled(compiled_expression)


func execute_compiled(compiled_expression: GDShellExpressionCompiler.CompilerResult) -> GDShellCommand.CommandResult:
	# TODO: run the expression
	return null


func request_input() -> String:
	input_requested.emit()
	return await _input_submitted


func submit_input(input: String) -> void:
	_input_submitted.emit(input)


func submit_output(output: String) -> void:
	output_submitted.emit(output)






#func setup_with_default_values() -> void:
	# GDShellCommandRunner
	#set_command_runner(GDShellCommandRunner.new(), true)
	
	# GDShellCommandDB
	#var database: GDShellCommandDB = GDShellCommandDB.new()
	#for directory: String in ProjectSettings.get_setting(
		#GDShellEditorPlugin.COMMAND_SCANNED_DIRECTORIES,
		#GDShellEditorPlugin.COMMAND_SCANNED_DIRECTORIES_DEFAULT
	#):
		#database.add_commands_in_directory(directory)
	#set_command_db(database)
	
	#GDShellUIHandler
	#set_ui_handler(
		#GDShellSession._get_ui_handler_instance_from_path(
			#str(ProjectSettings.get_setting(
				#GDShellEditorPlugin.UI_SCENE_PATH,
				#GDShellEditorPlugin.UI_SCENE_PATH_DEFAULT
			#))
		#),
		#true
	#)


#func set_command_db(new_command_db: GDShellCommandDB) -> void:
	#if new_command_db == null:
		#push_error("[GDShell] Attempted to set GDShellCommandDB, but null value was given.")
		#return
	#command_db = new_command_db


#func unset_command_db() -> void:
	#command_db = null


#func set_command_runner(new_command_runner: GDShellCommandRunner, add_as_child: bool = true) -> void:
	#if new_command_runner == null:
		#push_error("[GDShell] Attempted to set GDShellCommandRunner, but null value was given.")
		#return
	## if new command runner is the same as the onld one, do nothing unless it is requested to be reparented
	#if new_command_runner == command_runner:
		#if add_as_child and new_command_runner.get_parent() != self:
			#new_command_runner.reparent(self)
		#return
	#
	#unset_command_runner()
	#
	#if add_as_child:
		#if new_command_runner.get_parent() != null:
			#push_error("[GDShell] Attempted to set GDShellCommandRunner, but runner already has a parent Node. Set 'add_as_child' to false if you wish to manage the runner yourself.")
			#return
		#add_child(new_command_runner)
	#
	#command_runner = new_command_runner
	#command_runner._PARENT_GDSHELL = self
	#
	#if command_runner.get_parent() == null:
		#push_warning("[GDShell] GDShellCommandRunner was set, but it has no parent. Make sure to give it a parent or remember to free it manually to prevent leaks if you wish to manage the runner yourself.")


#func unset_command_runner() -> void:
	#if ui_handler == null:
		#push_warning("[GDShell] Attempted to unset GDShellCommandRunner, but none was set.")
		#return
	#if command_runner.get_parent() == self:
		#command_runner.queue_free()
	#elif command_runner.get_parent() == null:
		#push_warning("[GDShell] Unset GDShellCommandRunner has no parent and was not freed. Remember to free it manually to prevent leaks.")
	#command_runner = null


#func set_ui_handler(new_ui_handler: GDShellUIHandler, add_as_child: bool = true) -> void:
	#if new_ui_handler == null:
		#push_error("[GDShell] Attempted to set GDShellUIHandler, but null value was given.")
		#return
	## if new handler is the same as the onld one, do nothing unless it is requested to be reparented
	#if new_ui_handler == ui_handler:
		#if add_as_child and new_ui_handler.get_parent() != _ui_handler_canvas_layer:
			#new_ui_handler.reparent(_ui_handler_canvas_layer)
		#return
	#
	#unset_ui_handler()
	#
	#if add_as_child:
		#if new_ui_handler.get_parent() != null:
			#push_error("[GDShell] Attempted to set GDShellUIHandler, but new_ui_handler already has a parent Node. Set 'add_as_child' to false if you wish to manage the handler yourself.")
			#return
		#_ui_handler_canvas_layer.add_child(new_ui_handler)
	#
	#ui_handler = new_ui_handler
	#ui_handler.set_visible(false)
	#if not ui_handler.input_submitted.is_connected(self._on_ui_handler_input_submitted):
		#@warning_ignore("return_value_discarded")
		#ui_handler.input_submitted.connect(self._on_ui_handler_input_submitted)
	#
	#if ui_handler.get_parent() == null:
		#push_warning("[GDShell] GDShellUIHandler was set, but it has no parent. Make sure to give it a parent or remember to free it manually to prevent leaks if you wish to manage the handler yourself.")


#func unset_ui_handler() -> void:
	#if ui_handler == null:
		#push_warning("[GDShell] Attempted to unset GDShellUIHandler, but none was set.")
		#return
	#
	#if ui_handler.input_submitted.is_connected(self._on_ui_handler_input_submitted):
		#ui_handler.input_submitted.disconnect(self._on_ui_handler_input_submitted)
	#if ui_handler.get_parent() == self:
		#ui_handler.queue_free()
	#elif ui_handler.get_parent() == null:
		#push_warning("[GDShell] Unset GDShellUIHandler has no parent and was not freed. Remember to free it manually to prevent leaks.")
	#ui_handler = null


#func _request_output_from_ui_handler(output: String, append_new_line: bool) -> void:
	#if ui_handler == null:
		#push_warning("[GDShell] No GDShellUIHandler is set. No output is outputted.")
		#return
	#ui_handler._output_requested(output)


#func _request_input_from_ui_handler(output: String = "") -> String:
	#if ui_handler == null:
		#push_warning("[GDShell] No GDShellUIHandler is set. Empty input is returned.")
		#return ""
	#ui_handler._input_requested(output)
	#return await _requested_input_submitted


#func _on_ui_handler_input_submitted(input: String) -> void:
	#if _input_requested: # The input is requested by a command. Do nothing and just forward it to it
		#_input_requested = false
		#_requested_input_submitted.emit(input)
		#return
	#
	#_input_buffer += input
	#var parser_result: GDShellCommandParser.ParserResult = GDShellCommandParser.parse(_input_buffer, command_db)
	#match parser_result.status:
		#GDShellCommandParser.ParserResult.Status.OK:
			#_request_output_from_ui_handler((ui_handler._get_input_prompt() if input == _input_buffer else "") + input, true)
			#_input_buffer = ""
			#await command_runner.execute(parser_result)
			##ui_handler._input_requested.emit("")
		#GDShellCommandParser.ParserResult.Status.UNTERMINATED:
			#_request_output_from_ui_handler((ui_handler._get_input_prompt() if input == _input_buffer else "") + input, true)
			##ui_handler._input_requested.emit("> ")
		#GDShellCommandParser.ParserResult.Status.ERROR:
			#_request_output_from_ui_handler(ui_handler._get_input_prompt() + _input_buffer, true)
			#_input_buffer = ""
			## TODO better error announcement
##			_request_output_from_ui_handler("[color=red]%s[/color]" % parser_result["result"]["error"], true)
			##ui_handler._input_requested.emit("")


#static func _get_ui_handler_instance_from_path(path: String) -> GDShellUIHandler:
	#var scene: Resource = load(path)
	#if not scene is PackedScene:
		#push_error("[GDShell] Attempted to get a GDShellUIHandler instance from '%s' but resource is to a scene." % path)
		#return null
	#
	#var instance: Node = (scene as PackedScene).instantiate()
	#if not instance is GDShellUIHandler:
		#push_error("[GDShell] Attempted to get a GDShellUIHandler instance from '%s' but scene root is not of GDShellUIHandler type." % path)
		#instance.queue_free()
		#return null
	#
	#return instance as GDShellUIHandler
