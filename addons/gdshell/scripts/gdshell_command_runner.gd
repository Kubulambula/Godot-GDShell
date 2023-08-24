@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandRunner
extends Node


# Command execution flags
#const F_EXECUTE_CONDITION_MET: int = 1 #1 << 0
#const F_PIPE_PREVIOUS: int = 2 #1 << 1
#const F_BACKGROUND: int = 4 #1 << 2
#const F_NEGATED: int = 8 #1 << 3

#var _PARENT_GDSHELL: GDShellMain

var _background_commands: Array[GDShellCommand] = []


func execute(parser_result: GDShellCommandParser.ParserResult, piped_data: Variant=null) -> GDShellCommand.CommandResult:
	if parser_result.status != GDShellCommandParser.ParserResult.Status.OK:
		push_error("[GDShell] Attempted to run invalid GDShellCommandParser.ParserResult.")
		return null
	if parser_result.tokens.is_empty():
		push_error("[GDShell] Attempted to run an empty input.")
		return null
	if parser_result.command_db == null:
		push_error("[GDShell] Attempted to run a command, but GDShellCommandParser.ParserResult.command_db is null.")
		return null
	
	
	
	return null
#	return _execute_helper(parser_result.tokens)


# This is a if monster, but it just checks if the right file is loaded.
func _execute_command(parser_result: GDShellCommandParser.ParserResult, start_word_token_index: int=0, piped_data: Variant=null, in_background: bool=false) -> GDShellCommand.CommandResult:
	var command: GDShellCommand = parser_result.command_db.get_gdshell_command_instance(parser_result.tokens[start_word_token_index].content)
	if command == null:
		return null
	
	command.name = "GDShellCommand: " + command.COMMAND_NAME
	add_child(command, true)
	if in_background:
		command.name += " (in background)"
		_background_commands.append(command)
	
	var last_word_token_index: int = start_word_token_index
	while true:
		start_word_token_index += 1
		if last_word_token_index > parser_result.tokens.size():
			break
		if parser_result.tokens[last_word_token_index].type != GDShellCommandParser.Token.Type.WORD:
			break
	
	var words: Array[GDShellCommandParser.Token] = parser_result.tokens.slice(start_word_token_index, last_word_token_index)
	
	return null







#	print(command_script.new().get_script == )
#	var command_gdscript: GDScript = (command_script as GDScript).new()
#	if not command_gdscript is GDShellCommand:
#		pass
#		push_error("can't load (non existent command)")
#		return {}
#
#	var command: GDShellCommand = command_script.new()
#	add_child(command)
#
#	if background:
#		_background_commands.append(command)
#
#	var command_result: Dictionary = await command._main(
#			words.map(func(word: GDShellCommandParser.Token) -> String: return word.content),
#			piped_data
#	)
#
#	# Validate the command result 
#	if typeof(command_result) != TYPE_DICTIONARY:
#		push_error("[GDShell] The '%s' command does not return a value of TYPE_DICTIONARY.
#				'GDShellCommand.DEFAULT_COMMAND_RESULT' will be returned instead." % words[0].content)
#		# This assert statement acts as a hard error in the editor
#		assert(typeof(command_result) == TYPE_DICTIONARY, """[GDShell] The command does not return a value of TYPE_DICTIONARY.
#				'GDShellCommand.DEFAULT_COMMAND_RESULT' will be returned instead.
#				See the Errors for more information about the failing command.""")
#		command_result = GDShellCommand.DEFAULT_COMMAND_RESULT
#	else:
##		@warning_ignore("unsafe_method_access")
#		command_result.merge(GDShellCommand.DEFAULT_COMMAND_RESULT)
#
#	_background_commands.erase(command)
#	command.queue_free()
#	return command_result


#func _find_matching_parenthesis_index(tokens: Array[GDShellCommandParser.Token], opening_parenthesis_index: int) -> int:
#	var current: int = opening_parenthesis_index
#	var parenthesis_level: int = 1
#
#	while current < tokens.size():
#		if tokens[current].type == GDShellCommandParser.Token.Type.OPERATOR_OPENING_PARENTHESIS:
#			parenthesis_level += 1
#		elif tokens[current].type == GDShellCommandParser.Token.Type.OPERATOR_CLOSING_PARENTHESIS:
#			parenthesis_level -= 1
#			if parenthesis_level == 0:
#				return current
#	return -1
#	return null


#func _execute_helper(tokens: Array[GDShellCommandParser.Token], piped_data: Variant=null) -> Dictionary:
#	var last_command_result: Dictionary = {}
#	var word_accum: Array[GDShellCommandParser.Token] = []
#	var current_command_flags: int = F_EXECUTE_CONDITION_MET
#
#	var current: int = 0
#
#
#	var execute_command_helper: Callable = func() -> void:
#		if not current_command_flags & F_EXECUTE_CONDITION_MET:
#			current_command_flags = F_EXECUTE_CONDITION_MET
#			word_accum.clear()
#			return
#
#		if current_command_flags & F_BACKGROUND:
##			last_command_result = GDShellCommand.CommandResult.new()
#			_execute_command(
#					word_accum,
#					last_command_result if current_command_flags & F_PIPE_PREVIOUS else null,
#					true
#			)
#		else:
#			last_command_result = await _execute_command(
#					word_accum,
#					last_command_result if current_command_flags & F_PIPE_PREVIOUS else null,
#					false
#			)
#
#		if current_command_flags & F_NEGATED:
#			last_command_result["error"] = 0 if last_command_result["error"] else 1
#
#		current_command_flags = F_EXECUTE_CONDITION_MET
#		word_accum.clear()
#
#
#	var execute_parenthesis_helper: Callable = func() -> int:
#		# find the closing parenthesis index
#		var parenthesis_level: int = 1
#		while current < tokens.size():
#			if tokens[current].type == GDShellCommandParser.Token.Type.OPERATOR_OPENING_PARENTHESIS:
#				parenthesis_level += 1
#			elif tokens[current].type == GDShellCommandParser.Token.Type.OPERATOR_CLOSING_PARENTHESIS:
#				parenthesis_level -= 1
#				if parenthesis_level == 0:
#					break
#			current += 1
#
#
#
#		return -1
#
#
#	while current < tokens.size():
#		match tokens[current]:
#			GDShellCommandParser.Token.Type.WORD:
#				word_accum.append(tokens[current])
#
#			GDShellCommandParser.Token.Type.OPERATOR_PIPE:
#				current_command_flags |= F_PIPE_PREVIOUS
#				execute_command_helper.call()
#
#			GDShellCommandParser.Token.Type.OPERATOR_AND:
#				execute_command_helper.call()
#				if last_command_result["error"] != 0:
#					current_command_flags &= ~F_EXECUTE_CONDITION_MET
#
#			GDShellCommandParser.Token.Type.OPERATOR_OR:
#				execute_command_helper.call()
#				if last_command_result["error"] == 0:
#					current_command_flags &= ~F_EXECUTE_CONDITION_MET
#
#			GDShellCommandParser.Token.Type.OPERATOR_NOT:
#				current_command_flags |= F_NEGATED
#
#			GDShellCommandParser.Token.Type.OPERATOR_BACKGROUND:
#				current_command_flags |= F_BACKGROUND
#				execute_command_helper.call()
#
#			GDShellCommandParser.Token.Type.OPERATOR_SEQUENCE:
#				execute_command_helper.call()
#
#			GDShellCommandParser.Token.Type.OPERATOR_OPENING_PARENTHESIS:
#				execute_parenthesis_helper.call()



#				var matching_parenthesis_index: int = _find_matching_parenthesis_index(tokens, current)
#				if matching_parenthesis_index == -1:
#					push_error("no matching parenthesis")
#					return {}
#
#
#				if not current_command_flags & F_EXECUTE_CONDITION_MET: # negace + background (pipe)
#					current = matching_parenthesis_index + 1 # check if it is a &
#					continue
#
#				if tokens[matching_parenthesis_index+1].type == GDShellCommandParser.Token.Type.OPERATOR_BACKGROUND:
#					current_command_flags |= F_BACKGROUND
#
#
#				last_command_result = _execute_helper(tokens.slice(current+1, matching_parenthesis_index+1))
#
#
#
#				var original: Array[GDShellCommandParser.Token] = parser_result.result
#				parser_result.result = parser_result.result.slice(current+1, matching_parenthesis_index+1)
#				last_command_result = execute(parser_result)
#				parser_result.result = original


#			_: # ERROR, SPACE, WORD_UNTERMINATED, OPERATOR_EXPAND, OPERATOR_CLOSING_PARENTHESIS
#				push_error("Unexpected token. These tokens should be handled earlier")
#				return {}
#
#		current += 1
#
#	return {}



#func _execute_command(words: Array[GDShellCommandParser.Token], piped_data: Variant=null, background: bool=false) -> Dictionary:
#	var command_script: Resource = ResourceLoader.load(_find_command_path(words[0].content), "GDScript")
#	if not command_script:
#		push_error("can't load (non existent command)")
#		return {}
#
#	var command: GDShellCommand = command_script.new()
#	add_child(command)
#
#	if background:
#		_background_commands.append(command)
#
#	var command_result: Dictionary = await command._main(
#			words.map(func(word: GDShellCommandParser.Token) -> String: return word.content),
#			piped_data
#	)
#
#	# Validate the command result 
#	if typeof(command_result) != TYPE_DICTIONARY:
#		push_error("[GDShell] The '%s' command does not return a value of TYPE_DICTIONARY.
#				'GDShellCommand.DEFAULT_COMMAND_RESULT' will be returned instead." % words[0].content)
#		# This assert statement acts as a hard error in the editor
#		assert(typeof(command_result) == TYPE_DICTIONARY, """[GDShell] The command does not return a value of TYPE_DICTIONARY.
#				'GDShellCommand.DEFAULT_COMMAND_RESULT' will be returned instead.
#				See the Errors for more information about the failing command.""")
#		command_result = GDShellCommand.DEFAULT_COMMAND_RESULT
#	else:
##		@warning_ignore("unsafe_method_access")
#		command_result.merge(GDShellCommand.DEFAULT_COMMAND_RESULT)
#
#	_background_commands.erase(command)
#	command.queue_free()
#	return command_result


#func _find_matching_parenthesis_index(tokens: Array[GDShellCommandParser.Token], opening_parenthesis_index: int) -> int:
#	var current: int = opening_parenthesis_index
#	var parenthesis_level: int = 1
#
#	while current < tokens.size():
#		if tokens[current].type == GDShellCommandParser.Token.Type.OPERATOR_OPENING_PARENTHESIS:
#			parenthesis_level += 1
#		elif tokens[current].type == GDShellCommandParser.Token.Type.OPERATOR_CLOSING_PARENTHESIS:
#			parenthesis_level -= 1
#			if parenthesis_level == 0:
#				return current
#	return -1



##############################################
# GDShellCommand-GDShell interface functions #
##############################################


#func _handle_execute(command: String) -> GDShellCommand.CommandResult:
#	return await _PARENT_GDSHELL.execute(command)
#
#func _find_command_path(command_name: String) -> String:
#	return ""
