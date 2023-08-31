@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandParser
extends RefCounted


class ParserResult:
	enum Status {
		OK,
		UNTERMINATED,
		ERROR,
	}
	
	var status: Status ## Status of the parsed input.
	var input: String ## The input that was provided by the user.
	var tokens: Array[Token] ## Tokenized input.
	var command_db: GDShellCommandDB ## GDShellCommandDB, that was used for parsing and should be used for execution.
	var err_token_index: int ## Index of the Token that caused an error. If the index is -1, no error occured.
	var err_string: String = "" ## Description of the error. If empty, no error occured.
	
	func _init(_status: Status, _input: String, _tokens: Array[Token], _command_db: GDShellCommandDB, _err_token_index: int = -1, _err_string: String = ""):
		status = _status
		input = _input
		tokens = _tokens
		command_db = _command_db
		err_token_index = _err_token_index
		err_string = _err_string


class Token:
	enum Type {
		SPACE,
		WORD,
		WORD_UNTERMINATED,
		OPERATOR_PIPE,
		OPERATOR_AND,
		OPERATOR_OR,
		OPERATOR_NOT,
		OPERATOR_BACKGROUND,
		OPERATOR_SEQUENCE,
#		OPERATOR_EXPAND,
		OPERATOR_OPENING_PARENTHESIS,
		OPERATOR_CLOSING_PARENTHESIS,
	}
	
	var type: Type
	var content: String
	var start_char_index: int
	var consumed: int
	
	func _init(_type: Type, _content: String, _start_char_index: int, _consumed: int):
		type = _type
		content = _content
		start_char_index = _start_char_index
		consumed = _consumed


static func parse(input: String, command_db: GDShellCommandDB) -> ParserResult:
	var tokens: Array[Token] = _tokenize(input)
	
	if tokens.is_empty():
		return ParserResult.new(
			ParserResult.Status.OK,
			input,
			tokens,
			command_db
		)
	
	if tokens[-1].type == Token.Type.WORD_UNTERMINATED:
		return ParserResult.new(
			ParserResult.Status.UNTERMINATED,
			input,
			tokens,
			command_db,
			tokens.size() - 1,
			"The input is not terminated with corrent quote so another appended input is required. See GDShell Docs for help.",
		)
	
	var validated: Dictionary = _validate_operators(tokens)
	if validated["err_token_index"] != -1:
		return ParserResult.new(
			ParserResult.Status.ERROR,
			input,
			tokens,
			command_db,
			validated["err_token_index"],
			validated["err_string"]
		)
	
	tokens = _expand(tokens, command_db)
	
	return ParserResult.new(
		ParserResult.Status.OK,
		input,
		tokens,
		command_db
	)


static func _expand(tokens: Array[Token], command_db: GDShellCommandDB) -> Array[Token]:
	var expanded_tokens: Array[Token] = []
	var last_token_type: Token.Type = Token.Type.OPERATOR_AND
	
	for i in tokens.size():
		if last_token_type != Token.Type.WORD:
			expanded_tokens.append_array(_expand_token(tokens[i], command_db))
		else:
			expanded_tokens.append(tokens[i])
		last_token_type = tokens[i].type
	
	return expanded_tokens


static func _expand_token(token: Token, command_db: GDShellCommandDB) -> Array[Token]:
	if token.content in command_db._aliases.keys():
		return _tokenize(command_db._aliases[token.content])
	return [token]


static func _is_operator(token: Token) -> bool:
	return token.type in [
		Token.Type.OPERATOR_AND,
		Token.Type.OPERATOR_BACKGROUND,
		Token.Type.OPERATOR_OR,
		Token.Type.OPERATOR_PIPE,
		Token.Type.OPERATOR_NOT,
		Token.Type.OPERATOR_SEQUENCE,
	]


static func _validate_operators(tokens: Array[Token]) -> Dictionary:
	var parenthesis_validation: Dictionary = _validate_parentheses(tokens)
	if parenthesis_validation["err_token_index"] != -1:
		return parenthesis_validation
	
	for i in tokens.size():
		if tokens[i].type == Token.Type.WORD:
			continue
		
		if _token_requires_left_operand(tokens[i]):
			if i == 0 or not _token_can_be_considered_operand(tokens[i], tokens[i-1]):
				return {
					"err_token_index": i,
					"err_string": "\"%s\" does not have a required left operand." % tokens[i].content if tokens[i].type != Token.Type.OPERATOR_CLOSING_PARENTHESIS
					else "Parentheses pair does not have at least one required command.",
				}
		if _token_requires_right_operand(tokens[i]):
			if i == tokens.size()-1 or not _token_can_be_considered_operand(tokens[i], tokens[i+1]):
				return {
					"err_token_index": i,
					"err_string": "\"%s\" does not have a required right operand." % tokens[i].content if tokens[i].type != Token.Type.OPERATOR_OPENING_PARENTHESIS
					else "Parentheses pair does not have at least one required command.",
				}
	
	return {
		"err_token_index": -1,
		"err_string": "",
	}


static func _validate_parentheses(tokens: Array[Token]) -> Dictionary:
	var parenthesis_level: int = 0
	var firt_opening_parenthesis_index: int
	
	for i in tokens.size():
		if tokens[i].type == Token.Type.OPERATOR_OPENING_PARENTHESIS:
			parenthesis_level += 1
			if parenthesis_level == 1:
				firt_opening_parenthesis_index = i
		elif tokens[i].type == Token.Type.OPERATOR_CLOSING_PARENTHESIS:
			parenthesis_level -= 1
			if parenthesis_level < 0: # Found closing parenthesis with no opening one
				return {
					"err_token_index": i,
					"err_string": "Closing \")\" on index [%d] does not have an opening counterpart." % i,
				}
	
	if parenthesis_level > 0: # Did not find a closing parenthesis for all opening parentheses
		return {
			"err_token_index": firt_opening_parenthesis_index,
			"err_string": "Opening \"(\" on index [%d] does not have a closing counterpart." % firt_opening_parenthesis_index,
		}
	
	return {
		"err_token_index": -1,
		"err_string": ""
	}


static func _token_requires_left_operand(token: Token) -> bool:
	return token.type in [
		Token.Type.OPERATOR_PIPE,
		Token.Type.OPERATOR_AND,
		Token.Type.OPERATOR_OR,
		Token.Type.OPERATOR_BACKGROUND,
		Token.Type.OPERATOR_SEQUENCE,
		Token.Type.OPERATOR_CLOSING_PARENTHESIS,
	]


static func _token_requires_right_operand(token: Token) -> bool:
	return token.type in [
		Token.Type.OPERATOR_PIPE,
		Token.Type.OPERATOR_AND,
		Token.Type.OPERATOR_OR,
		Token.Type.OPERATOR_NOT,
		Token.Type.OPERATOR_OPENING_PARENTHESIS,
	]


static func _token_can_be_considered_operand(operator: Token, operand: Token) -> bool:
	match operator.type:
		Token.Type.OPERATOR_PIPE, Token.Type.OPERATOR_AND, Token.Type.OPERATOR_OR, Token.Type.OPERATOR_SEQUENCE:
			return operand.type in [
				Token.Type.WORD,
				Token.Type.OPERATOR_NOT,
				Token.Type.OPERATOR_BACKGROUND,
				Token.Type.OPERATOR_OPENING_PARENTHESIS,
				Token.Type.OPERATOR_CLOSING_PARENTHESIS,
			]
		Token.Type.OPERATOR_NOT:
			return operand.type in [
				Token.Type.WORD,
				Token.Type.OPERATOR_OPENING_PARENTHESIS,
			]
		Token.Type.OPERATOR_BACKGROUND:
			return operand.type in [
				Token.Type.WORD,
			]
		Token.Type.OPERATOR_OPENING_PARENTHESIS:
			return operand.type in [
				Token.Type.WORD,
				Token.Type.OPERATOR_NOT,
				Token.Type.OPERATOR_OPENING_PARENTHESIS,
			]
		Token.Type.OPERATOR_CLOSING_PARENTHESIS:
			return operand.type in [
				Token.Type.WORD,
				Token.Type.OPERATOR_BACKGROUND,
				Token.Type.OPERATOR_CLOSING_PARENTHESIS,
			]
	
	return false

static func _tokenize(input: String) -> Array[Token]:
	var tokens: Array[Token] = []
	var current_char: int = 0
	
	while current_char < input.length():
		match input[current_char]:
			" ":
				tokens.push_back(_tokenize_space(input, current_char))
			";":
				tokens.push_back(_tokenize_semicolon(input, current_char))
			"&":
				tokens.push_back(_tokenize_and(input, current_char))
			"|":
				tokens.push_back(_tokenize_pipe(input, current_char))
			"!":
				tokens.push_back(_tokenize_exclamation(input, current_char))
#			"$":
#				tokens.push_back(_tokenize_dollar_sign(input, current_char))
			"(", ")":
				tokens.push_back(_tokenize_parenthesis(input, current_char))
			"\"", "\'":
				tokens.push_back(_tokenize_quote(input, current_char))
			_:
				tokens.push_back(_tokenize_text(input, current_char))
		
		current_char += tokens[-1].consumed
	
	return _filter_out_space_tokens(_merge_word_tokens(tokens))


static func _tokenize_space(_input: String, current_char: int) -> Token:
	return Token.new(Token.Type.SPACE, " ", current_char, 1)


static func _tokenize_semicolon(_input: String, current_char: int) -> Token:
	return Token.new(Token.Type.OPERATOR_SEQUENCE, ";", current_char, 1)


static func _tokenize_and(input: String, current_char: int) -> Token:
	if current_char < input.length()-1 and input[current_char+1] == "&":
		return Token.new(Token.Type.OPERATOR_AND, "&&", current_char, 2)
	return Token.new(Token.Type.OPERATOR_BACKGROUND, "&", current_char, 1)


static func _tokenize_pipe(input: String, current_char: int) -> Token:
	if current_char < input.length()-1 and input[current_char+1] == "|":
		return Token.new(Token.Type.OPERATOR_OR, "||", current_char, 2)
	return Token.new(Token.Type.OPERATOR_PIPE, "|", current_char, 1)


static func _tokenize_exclamation(_input: String, current_char: int) -> Token:
	return Token.new(Token.Type.OPERATOR_NOT, "!", current_char, 1)


#static func _tokenize_dollar_sign(_input: String, current_char: int) -> Token:
#	return Token.new(Token.Type.OPERATOR_EXPAND, "$", current_char, 1)


static func _tokenize_parenthesis(input: String, current_char: int) -> Token:
	if input[current_char] == "(":
		return Token.new(Token.Type.OPERATOR_OPENING_PARENTHESIS, "(", current_char, 1)
	else:
		return Token.new(Token.Type.OPERATOR_CLOSING_PARENTHESIS, ")", current_char, 1)


static func _tokenize_quote(input: String, current_char: int) -> Token:
	var content: String = ""
	var quote_type: String = input[current_char]
	
	# Skip the opening quote and start on the char right after
	for i in range(current_char + 1, input.length()):
		if input[i] == quote_type and input[max(0, i - 1)] != "\\":
			return Token.new(
				Token.Type.WORD,
				content.c_unescape(),
				current_char,
				content.length() + 2 # accounts for the starting and ending quotes
			)
		content += input[i]
	# End of input was reached without finding a closing quote
	return Token.new(
		Token.Type.WORD_UNTERMINATED,
		content.c_unescape(),
		current_char,
		content.length() + 1 # accounts for the starting quote
	)


static func _tokenize_text(input: String, current_char: int) -> Token:
	var content: String = ""
	
	for i in range(current_char, input.length()):
		# check if the character should end the WORD token.
		if input[i] in [" ", ";", "&", "|", "!", "(", ")", "\"", "\'"]:
			break
		content += input[i]
	
	return Token.new(
		Token.Type.WORD,
		content.c_unescape(),
		current_char,
		content.length()
	)


## Merges WORD tokens if they are not separated by any other token
static func _merge_word_tokens(tokens: Array[Token]) -> Array[Token]:
	if tokens.is_empty():
		return tokens
	# We now know that tokens is not empty so we append the first token for later simplification
	var merged_tokens: Array[Token] = [tokens[0]]
	
	# Start from the second token as we already appended the first
	for i in range(1, tokens.size()):
		if tokens[i].type == Token.Type.WORD and merged_tokens[-1].type == Token.Type.WORD:
			merged_tokens[-1].content += tokens[i].content
			merged_tokens[-1].consumed += tokens[i].consumed
		else:
			merged_tokens.append(tokens[i])
	
	return merged_tokens


## Filters out SPACE tokens. After _merge_word_tokens() they are useless and it simplifies next operations.
static func _filter_out_space_tokens(tokens: Array[Token]) -> Array[Token]:
	return tokens.filter(
		func is_token_not_space(token: Token) -> bool:
			return token.type != Token.Type.SPACE
	)
