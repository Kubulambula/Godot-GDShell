@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandRunner
extends Node


# Command execution flags
const F_EXECUTE_CONDITION_MET: int = 1 << 0
const F_PIPE_PREVIOUS: int = 1 << 1
const F_BACKGROUND: int = 1 << 2
const F_NEGATED: int = 1 << 3

var _PARENT_GDSHELL: GDShellMain

var _background_commands: Array[GDShellCommand] = []

var _is_running_command: bool = false


func execute(command_sequence: Dictionary) -> Dictionary:
	if command_sequence["status"] != GDShellCommandParser.ParserResultStatus.OK:
		return {
			"error": 1,
			"error_string": 'Cannot execute command sequence. See "data" for the command_sequence',
			"data": command_sequence,
		}
	
	_is_running_command = true
	
	var current_token: int = 0
	var current_command_flags: int = F_EXECUTE_CONDITION_MET
	var last_command_result: Dictionary = GDShellCommand.DEFAULT_COMMAND_RESULT
	
	@warning_ignore("unsafe_method_access")
	while current_token < command_sequence["result"].size():
		match command_sequence["result"][current_token]["type"]:
			GDShellCommandParser.ParserBlockType.COMMAND:
				var command: String = command_sequence["result"][current_token]["data"]["command"]
				var params: Dictionary = command_sequence["result"][current_token]["data"]["params"]
				
				if not current_command_flags & F_EXECUTE_CONDITION_MET:
					current_command_flags = F_EXECUTE_CONDITION_MET
					continue
				
				if current_command_flags & F_PIPE_PREVIOUS:
					params["data"] = last_command_result["data"]
				
				if current_command_flags & F_BACKGROUND:
					last_command_result = GDShellCommand.DEFAULT_COMMAND_RESULT
					_execute_command(command, params)
				else:
					last_command_result = await _execute_command(command, params)
				
				if current_command_flags & F_NEGATED:
					last_command_result["error"] = 0 if last_command_result["error"] else 1
				
				current_command_flags = F_EXECUTE_CONDITION_MET
			
			GDShellCommandParser.ParserBlockType.BACKGROUND:
				current_command_flags |= F_BACKGROUND
			
			GDShellCommandParser.ParserBlockType.NOT:
				current_command_flags |= F_NEGATED
			
			GDShellCommandParser.ParserBlockType.PIPE:
				current_command_flags |= F_PIPE_PREVIOUS
			
			GDShellCommandParser.ParserBlockType.AND:
				if last_command_result["error"]:
					current_command_flags ^= F_EXECUTE_CONDITION_MET
				else:
					current_command_flags |= F_EXECUTE_CONDITION_MET
			
			GDShellCommandParser.ParserBlockType.OR:
				if last_command_result["error"]:
					current_command_flags |= F_EXECUTE_CONDITION_MET
				else:
					current_command_flags ^= F_EXECUTE_CONDITION_MET
		
		current_token += 1
	
	_is_running_command = false
	return last_command_result


func _execute_command(path: String, params: Dictionary, in_background: bool = false) -> Dictionary:
	@warning_ignore("unsafe_method_access", "unsafe_cast")
	var command: GDShellCommand = ResourceLoader.load(path, "GDScript").new() as GDShellCommand
	add_child(command)
	command._PARENT_PROCESS = self
	if in_background:
		_background_commands.append(command)
	
	@warning_ignore("redundant_await")
	var result = await command._main(params["argv"], params["data"])
	
	if typeof(result) != TYPE_DICTIONARY:
		push_error("[GDShell] The '%s' command does not return a value of TYPE_DICTIONARY.\n'GDShellCommand.DEFAULT_COMMAND_RESULT' will be returned instead."
				% params["argv"][0]
		)
		# This assert statement acts as a hard error in the editor
		assert(
			typeof(result) == TYPE_DICTIONARY,
			"""[GDShell] The command does not return a value of TYPE_DICTIONARY.
				'GDShellCommand.DEFAULT_COMMAND_RESULT' will be returned instead.
				See the Errors for more information about the failing command."""
		)
		result = GDShellCommand.DEFAULT_COMMAND_RESULT
	else:
		@warning_ignore("unsafe_method_access")
		result.merge(GDShellCommand.DEFAULT_COMMAND_RESULT)
	
	command.queue_free()
	_background_commands.erase(command)
	
	return result


##############################################
# GDShellCommand-GDShell interface functions #
##############################################


func _handle_execute(command: String) -> Dictionary:
	return await _PARENT_GDSHELL.execute(command)


func _handle_input(command: GDShellCommand, out: String) -> String:
	if command in _background_commands:
		return ""
	return await _PARENT_GDSHELL._request_input_from_ui_handler(out)


func _handle_output(out: String, append_new_line: bool = true) -> void:
	_PARENT_GDSHELL._request_output_from_ui_handler(out, append_new_line)


func _handle_get_ui_handler() -> GDShellUIHandler:
	return _PARENT_GDSHELL.get_ui_handler()


func _handle_get_ui_handler_rich_text_label() -> RichTextLabel:
	return _PARENT_GDSHELL.get_ui_handler_rich_text_label()
