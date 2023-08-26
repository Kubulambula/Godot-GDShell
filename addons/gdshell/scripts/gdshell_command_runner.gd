@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandRunner
extends Node


# Command execution flags
const F_EXECUTE_CONDITION_MET: int = 1
const F_PIPE_PREVIOUS: int = 2
const F_BACKGROUND: int = 4
const F_NEGATED: int = 8

var _PARENT_GDSHELL: GDShellMain

var _background_commands: Array[GDShellCommand] = []


func _init() -> void:
	name = "GDShellCommandRunner   - "


func execute(parser_result: GDShellCommandParser.ParserResult, piped_result: GDShellCommand.CommandResult=null) -> GDShellCommand.CommandResult:
	if parser_result.status != GDShellCommandParser.ParserResult.Status.OK:
		push_error("[GDShell] Attempted to run invalid GDShellCommandParser.ParserResult.")
		return null
	if parser_result.tokens.is_empty():
		push_error("[GDShell] Attempted to run an empty input.")
		return null
	if parser_result.command_db == null:
		push_error("[GDShell] Attempted to run a command, but GDShellCommandParser.ParserResult.command_db is null.")
		return null
	
	var command_execution_flags: int = F_EXECUTE_CONDITION_MET
	var last_command_result: GDShellCommand.CommandResult = piped_result
	
	var current_token_index: int = 0
	while current_token_index < parser_result.tokens.size():
		match parser_result.tokens[current_token_index].type:
			
			GDShellCommandParser.Token.Type.WORD:
				var next_non_word_token_index: int = _get_next_non_word_token_index(parser_result.tokens, current_token_index)
				var executed_command_result: GDShellCommand.CommandResult = await _execute_words(
					parser_result.tokens.slice(current_token_index, next_non_word_token_index),
					parser_result.command_db,
					last_command_result,
					command_execution_flags
				)
				
				if executed_command_result != null:
					last_command_result = executed_command_result
				
				command_execution_flags &= F_EXECUTE_CONDITION_MET
				current_token_index = next_non_word_token_index
			
			GDShellCommandParser.Token.Type.OPERATOR_PIPE:
				pass
			
			GDShellCommandParser.Token.Type.OPERATOR_AND:
				if not last_command_result.err:
					command_execution_flags |= F_BACKGROUND
				else:
					command_execution_flags ^= F_BACKGROUND
			
			GDShellCommandParser.Token.Type.OPERATOR_OR:
				if last_command_result.err:
					command_execution_flags |= F_BACKGROUND
				else:
					command_execution_flags ^= F_BACKGROUND
			
			GDShellCommandParser.Token.Type.OPERATOR_NOT:
				command_execution_flags |= F_NEGATED
			
			GDShellCommandParser.Token.Type.OPERATOR_BACKGROUND:
				command_execution_flags |= F_BACKGROUND
			
			GDShellCommandParser.Token.Type.OPERATOR_SEQUENCE:
				command_execution_flags |= F_EXECUTE_CONDITION_MET
			
			GDShellCommandParser.Token.Type.OPERATOR_OPENING_PARENTHESIS:
				var parentheses_content: Array[GDShellCommandParser.Token] = _get_parenthesis_inner_tokens(parser_result.tokens, current_token_index)
				var executed_parentheses_result: GDShellCommand.CommandResult = await execute(
					GDShellCommandParser.ParserResult.new(
						GDShellCommandParser.ParserResult.Status.OK,
						"",
						parentheses_content,
						parser_result.command_db
					)
				)
				if executed_parentheses_result == null:
					return null
				
				last_command_result = executed_parentheses_result
			
			GDShellCommandParser.Token.Type.OPERATOR_CLOSING_PARENTHESIS:
				pass # Do nothing (don't delete this. This token should not trigger an error)
			
			var token_type:
				push_error("[GDShell] GDShellCommandRunner encountered an unexpected '%s' token." % str(GDShellCommandParser.Token.Type.find_key(token_type)))
				return null
		
		current_token_index += 1
	
	return last_command_result


func _execute_words(tokens: Array[GDShellCommandParser.Token], command_db: GDShellCommandDB, last_result: GDShellCommand.CommandResult, command_execution_flags: int) -> GDShellCommand.CommandResult:
	if not command_execution_flags & F_EXECUTE_CONDITION_MET:
		return null
	
	var command_result: GDShellCommand.CommandResult = await _execute_command(
		tokens,
		command_db,
		last_result if command_execution_flags & F_PIPE_PREVIOUS else null,
		command_execution_flags & F_BACKGROUND
	)
	
	if command_execution_flags & F_NEGATED:
		command_result.err = OK if command_result.err else FAILED
	
	return command_result


func _execute_command(words: Array[GDShellCommandParser.Token], command_db: GDShellCommandDB, piped_result: GDShellCommand.CommandResult=null, in_background: bool=false) -> GDShellCommand.CommandResult:
	# Get argv
	var argv: Array = words.map(
		func(token: GDShellCommandParser.Token) -> String:
			return token.content
	)
	
	# Create command instance
	var command: GDShellCommand = command_db.get_gdshell_command_instance(argv[0])
	if command == null:
		return null
	
	# Set up command
	command._PARENT_COMMAND_RUNNER = self
	command.name = "GDShellCommand: " + command.COMMAND_NAME
	add_child(command, true)
	if in_background:
		command.name += " (in background)"
		_background_commands.append(command)
	
	# Run command
	@warning_ignore("redundant_await") # We don't know if the user override will have await
	var command_result: GDShellCommand.CommandResult = await command._main(argv, piped_result)
	
	# Cleanup command
	_background_commands.erase(command)
	command.queue_free()
	return command_result


func _get_next_non_word_token_index(tokens: Array[GDShellCommandParser.Token], starting_from: int) -> int:
	var next_non_word_token_index: int = starting_from + 1
	while next_non_word_token_index < tokens.size():
		if tokens[next_non_word_token_index].type != GDShellCommandParser.Token.Type.WORD:
			break
		next_non_word_token_index += 1
	return next_non_word_token_index


func _find_matching_parenthesis_index(tokens: Array[GDShellCommandParser.Token], opening_parenthesis_index: int) -> int:
	var current: int = opening_parenthesis_index
	var parenthesis_level: int = 1
	
	while current < tokens.size():
		if tokens[current].type == GDShellCommandParser.Token.Type.OPERATOR_OPENING_PARENTHESIS:
			parenthesis_level += 1
		elif tokens[current].type == GDShellCommandParser.Token.Type.OPERATOR_CLOSING_PARENTHESIS:
			parenthesis_level -= 1
			if parenthesis_level == 0:
				return current
	return -1


func _get_parenthesis_inner_tokens(tokens: Array[GDShellCommandParser.Token], opening_parenthesis_index: int) -> Array[GDShellCommandParser.Token]:
	var matching_parenthesis_index: int = _find_matching_parenthesis_index(tokens, opening_parenthesis_index)
	if matching_parenthesis_index == -1:
		return []
	return tokens.slice(opening_parenthesis_index + 1, matching_parenthesis_index)


func _handle_execute(command: String) -> GDShellCommand.CommandResult:
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

