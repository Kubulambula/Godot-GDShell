@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandParser
extends RefCounted


enum TokenType {
	ERROR,
	TOKEN_SEQUENCE,
	TEXT,
	UNTERMINATED_TEXT,
	SEPARATOR,
	PIPE,
	AND,
	OR,
	NOT,
	BACKGROUND,
	SEQUENCE,
}

enum ParserBlockType {
	COMMAND,
	BACKGROUND,
	NOT,
	PIPE,
	AND,
	OR,
}

enum ParserResultStatus {
	OK,
	UNTERMINATED,
	ERROR,
}

# status - ParserResultStatus:
# OK - result is an Array of Dictionaries (ParserBlockTypes)
# ERROR - result is the error token Dictionary
# UNTERMINATED - result is an empty Array - new input is necessary


static func parse(input: String, command_db: GDShellCommandDB) -> Dictionary:
	var tokens: Array[Dictionary] = tokenize(input, command_db)
	
	if tokens.is_empty():
		return {"status": ParserResultStatus.OK, "result": []}
	
	if tokens[-1]["type"] == TokenType.UNTERMINATED_TEXT:
		return {"status": ParserResultStatus.UNTERMINATED, "result": []}
	
	var command_sequence: Array[Dictionary] = []
	var command_construction_temp: Array[String] = []
	
	for i in tokens.size():
		match tokens[i]["type"]:
			TokenType.ERROR:
				return {"status": ParserResultStatus.ERROR, "result": tokens[i]}
			
			TokenType.TEXT:
				command_construction_temp.push_back(tokens[i]["content"])
			
			TokenType.PIPE:
				var operator_validation: Dictionary = _validate_operator(tokens, i, true, true)
				if operator_validation["status"] == ParserResultStatus.ERROR:
					return operator_validation
				var command: Dictionary = _construct_command(command_construction_temp, command_db)
				if command["status"] == ParserResultStatus.ERROR:
					return command
				
				command_construction_temp = []
				command_sequence.push_back(command["data"])
				command_sequence.push_back({"type": ParserBlockType.PIPE})
			
			TokenType.OR:
				var operator_validation: Dictionary = _validate_operator(tokens, i, true, true)
				if operator_validation["status"] == ParserResultStatus.ERROR:
					return operator_validation
				var command: Dictionary = _construct_command(command_construction_temp, command_db)
				if command["status"] == ParserResultStatus.ERROR:
					return command
				
				command_construction_temp = []
				command_sequence.push_back(command["data"])
				command_sequence.push_back({"type": ParserBlockType.OR})
			
			TokenType.AND:
				var operator_validation: Dictionary = _validate_operator(tokens, i, true, true)
				if operator_validation["status"] == ParserResultStatus.ERROR:
					return operator_validation
				var command: Dictionary = _construct_command(command_construction_temp, command_db)
				if command["status"] == ParserResultStatus.ERROR:
					return command
				
				command_construction_temp = []
				command_sequence.push_back(command["data"])
				command_sequence.push_back({"type": ParserBlockType.AND})
			
			TokenType.NOT:
				var operator_validation: Dictionary = _validate_operator(tokens, i, false, true)
				if operator_validation["status"] == ParserResultStatus.ERROR:
					return operator_validation
				var command: Dictionary = _construct_command(command_construction_temp, command_db)
				if command["status"] == ParserResultStatus.ERROR:
					return command
				
				command_construction_temp = []
				command_sequence.push_back(command["data"])
				command_sequence.push_back({"type": ParserBlockType.NOT})
			
			TokenType.BACKGROUND:
				var operator_validation: Dictionary = _validate_operator(tokens, i, true, false)
				if operator_validation["status"] == ParserResultStatus.ERROR:
					return operator_validation
				var command: Dictionary = _construct_command(command_construction_temp, command_db)
				if command["status"] == ParserResultStatus.ERROR:
					return command
				
				command_construction_temp = []
				command_sequence.push_back({"type": ParserBlockType.BACKGROUND})
				command_sequence.push_back(command["data"])
			
			TokenType.SEQUENCE:
				var command: Dictionary = _construct_command(command_construction_temp, command_db)
				if command["status"] == ParserResultStatus.ERROR:
					return command
				
				command_construction_temp = []
				command_sequence.push_back(command["data"])
			
			_:
				return {
					"status": ParserResultStatus.ERROR,
					"result":
					{
						"error":
						{
							"char": tokens[i]["start_char"],
							"error": "Unknown token",
						}
					}
				}

	# Empty the `command_construction_temp`
	var command: Dictionary = _construct_command(command_construction_temp, command_db)
	if command["status"] == ParserResultStatus.ERROR:
		return command
	command_sequence.push_back(command["data"])
	
	command_sequence = command_sequence.filter(func(x: Dictionary): return not x.is_empty())
	
	return {"status": ParserResultStatus.OK, "result": command_sequence}


static func _construct_command(from: Array[String], command_db: GDShellCommandDB) -> Dictionary:
	if from.size() == 0:
		# Empty commands will be filtered out
		return {
			"status": ParserResultStatus.OK,
			"data": {},
		}
	
	var command_path: String = command_db.get_command_path(from[0])
	if command_path.is_empty():
		return {
			"status": ParserResultStatus.ERROR,
			"result": {"error": {"char": 0, "error": "Unknown command: %s" % from[0]}},
		}
	
	return {
		"status": ParserResultStatus.OK,
		"data":
		{
			"type": ParserBlockType.COMMAND,
			"data":
			{
				"command": command_path,
				"params":
				{
					"argv": from.duplicate(true),
					"data": null,
				}
			}
		}
	}


# `from` - token array ; `at` - index of the operator
# `lect`, `right` - determines if the oprator mush have left or RIGHT operands
static func _validate_operator(from: Array[Dictionary], at: int, left: bool, right: bool) -> Dictionary:
	if left:
		if not at > 0:
			return {
				"status": ParserResultStatus.ERROR,
				"result":
				{
					"error":
					{
						"char": from[at]["start_char"],
						"error": "Missing operand",
					}
				}
			}
		if from[at - 1]["type"] != TokenType.TEXT:
			if from[at - 1]["type"] == TokenType.BACKGROUND and from[at]["type"] == TokenType.BACKGROUND:
				return {
					"status": ParserResultStatus.ERROR,
					"result": 
					{
						"error":
						{
							"char": from[at]["start_char"],
							"error": "Missing operand",
						}
					}
				}
	
	if right:
		if not at < from.size() - 1:
			return {
				"status": ParserResultStatus.ERROR,
				"result":
				{
					"error":
					{
						"char": from[at]["start_char"] + from[at]["consumed"],
						"error": "Missing operand",
					}
				}
			}
		if from[at + 1]["type"] != TokenType.TEXT:
			if (
				from[at + 1]["type"] != TokenType.NOT
				or (from[at + 1]["type"] == TokenType.NOT and from[at]["type"] == TokenType.NOT)
			):
				return {
					"status": ParserResultStatus.ERROR,
					"result":
					{
						"error":
						{
							"char": from[at]["start_char"] + from[at]["consumed"],
							"error": "Missing operand",
						}
					}
				}
	return {"status": ParserResultStatus.OK}


static func tokenize(input: String, command_db: GDShellCommandDB) -> Array[Dictionary]:
	var tokens: Array[Dictionary] = []
	var current: int = 0
	
	while current < input.length():
		match input[current]:
			" ":
				tokens.push_back(_tokenize_separator(input, current))
			"|":
				tokens.push_back(_tokenize_pipe_or(input, current))
			"&":
				tokens.push_back(_tokenize_background_and(input, current))
			";":
				tokens.push_back(_tokenize_sequence(input, current))
			'"', "'":
				tokens.push_back(_tokenize_quoted_text(input, current))
			"!":
				tokens.push_back(_tokenize_not(input, current))
			_:
				tokens.push_back(_tokenize_text(input, current))
		
		if tokens[-1]["type"] == TokenType.ERROR:
			return [tokens[-1]]
		
		current += tokens[-1]["consumed"]
	
	tokens = _remove_separator_tokens(tokens)
	return _unalias_tokens(tokens, command_db)


static func _token(type: TokenType, start_char: int, consumed: int, content: String = "", error: Dictionary = {}) -> Dictionary:
	return {
		"type": type,
		"start_char": start_char,
		"consumed": consumed,
		"content": content,
		"error": error,
	}


static func _tokenize_quoted_text(input: String, current: int) -> Dictionary:
	var start_char = current
	var content: String = ""
	var quote_type: String = input[current]
	current += 1
	
	while true:
		if current >= input.length():
			return _token(TokenType.UNTERMINATED_TEXT, start_char, content.length() + 1, content.c_unescape())  # accounts for the starting quote
		
		if input[current] == quote_type:
			if input[max(0, current - 1)] != "\\":
				return _token(TokenType.TEXT, start_char, content.length() + 2, content.c_unescape())  # accounts for the starting and ending quotes
		
		content += input[current]
		current += 1
	
	return {}


static func _tokenize_text(input: String, current: int) -> Dictionary:
	var start_char = current
	var content: String = ""
	
	while true:
		if current == input.length() or input[current] in [" ", "&"]:
			return _token(
				TokenType.TEXT,
				start_char,
				content.length(),
				content.c_unescape()
			)
		
		if input[current] in [";", "|", '"', "'", "!"]:
			return _token(
				TokenType.ERROR,
				start_char,
				content.length() + 1,
				content,
				{"char": current, "error": "Unexpected token"}
			)
	
		content += input[current]
		current += 1
	
	return {}


static func _tokenize_separator(_input: String, current: int) -> Dictionary:
	return _token(TokenType.SEPARATOR, current, 1, " ")


static func _tokenize_pipe_or(input: String, current: int) -> Dictionary:
	if current < input.length() - 1 and input[current + 1] == "|":
		return _token(TokenType.OR, current, 2, "||")
	return _token(TokenType.PIPE, current, 1, "|")


static func _tokenize_background_and(input: String, current: int) -> Dictionary:
	if current < input.length() - 1 and input[current + 1] == "&":
		return _token(TokenType.AND, current, 2, "&&")
	return _token(TokenType.BACKGROUND, current, 1, "&")


static func _tokenize_not(_input: String, current: int) -> Dictionary:
	return _token(TokenType.NOT, current, 1, "!")


static func _tokenize_sequence(_input: String, current: int) -> Dictionary:
	return _token(TokenType.SEQUENCE, current, 1, ";")


static func _unalias_tokens(tokens: Array[Dictionary], command_db: GDShellCommandDB) -> Array[Dictionary]:
	if tokens.size() == 0:
		return tokens
	if tokens[-1]["type"] == TokenType.UNTERMINATED_TEXT:
		return tokens
	
	tokens = _remove_separator_tokens(tokens)
	
	# Replace aliasable token by a token sequence representing the alias
	for i in tokens.size():
		if tokens[i]["type"] != TokenType.TEXT:
			continue
		if i > 0 and (tokens[i - 1]["type"] == TokenType.TEXT or tokens[i - 1]["type"] == TokenType.TOKEN_SEQUENCE):
			continue
		# Alias is found for the aliasable token
		if tokens[i]["content"] in command_db._aliases.keys():
			tokens[i] = {
				"type": TokenType.TOKEN_SEQUENCE,
				"content": tokenize(command_db._aliases[tokens[i]["content"]], command_db)
			}
	
	# Insert token sequences as tokens into the `tokens` array
	while tokens.any(func(x): return x["type"] == TokenType.TOKEN_SEQUENCE):
		for i in tokens.size():
			if tokens[i]["type"] == TokenType.TOKEN_SEQUENCE:
				var token_sequence: Dictionary = tokens.pop_at(i)
				@warning_ignore("unsafe_method_access")
				for ii in token_sequence["content"].size():
					tokens.insert(i + ii, token_sequence["content"][ii])
				break  # Break because the indexing has changed because of the inserting
	
	return tokens


static func _remove_separator_tokens(tokens: Array[Dictionary]) -> Array[Dictionary]:
	return tokens.filter(func(x): return x["type"] != TokenType.SEPARATOR)
