@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandParser
extends RefCounted


class ParserResult:
	enum Status {
		OK,
		UNTERMINATED,
		ERROR,
	}
	
	var status: Status
	var input: String
	var result: Array[Token]
	var err_token_index: int
	var err_string: String = ""
	
	func _init(_status: Status, _input: String, _result: Array[Token], _err_token_index: int = -1, _err_string: String = ""):
		status = _status
		input = _input
		result = _result
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
		OPERATOR_EXPAND,
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
	var tokens: Array[Token] = tokenize(input)
	if tokens.is_empty():
		return ParserResult.new(
				ParserResult.Status.OK,
				input,
				tokens,
		)
	elif tokens[-1].type == Token.Type.WORD_UNTERMINATED:
		return ParserResult.new(
				ParserResult.Status.UNTERMINATED,
				input,
				tokens,
				tokens[-1].start_char_index, # This points at the start of the token - opening quote
				"The input is not terminated with corrent quote so another appended input is required.
				See GDShell Docs for help",
		)
	
	# Filters out Token.Type.SPACE tokens because their absence simplifies next processes
	tokens = tokens.filter(func(t: Token): return t.type != Token.Type.SPACE)
	
#	tokens = _expand_aliases(tokens, command_db)
	
	# Validate all the operators
	var err_operator_index: int = validate_operators(tokens)
	if err_operator_index != -1:
		printerr("Bad operator on index: ", err_operator_index)
		return ParserResult.new(
				ParserResult.Status.ERROR,
				input,
				tokens,
				tokens[err_operator_index].start_char_index,
				"bad operator usage",
		)
	printerr("operators OK")
	
	return ParserResult.new(ParserResult.Status.OK, input, tokens)


static func _expand_aliases(tokens: Array[Token], command_db: GDShellCommandDB, forbidden_aliases: Array[String] = []) -> Array[Token]:
	for i in tokens.size():
		if tokens[i].type != Token.Type.WORD:
			# try to expand the next one
			pass
	
	return []


static func validate_operators(tokens: Array[Token]) -> int:
	var parenthesis_level: int = 0
	var open_parenthesis_index: int = -1
	
	for i in tokens.size():
		if tokens[i].type == Token.Type.WORD:
			continue
		if not _is_operator_valid(tokens, i):
			return i
			
		# validate parenthesis pairs
		if tokens[i].type == Token.Type.OPERATOR_OPENING_PARENTHESIS:
			if parenthesis_level == 0:
				open_parenthesis_index = i # tracks the parenthesis that would be closed last
			parenthesis_level += 1
			
		elif tokens[i].type == Token.Type.OPERATOR_CLOSING_PARENTHESIS:
			parenthesis_level -= 1
			if parenthesis_level < 0:
				return i # more closing parenthesis than opening ones
		
	return -1 if parenthesis_level == 0 else open_parenthesis_index


static func _is_operator_valid(tokens: Array[Token], operator_token_index: int) -> bool:
	
	# TODO : make sure no word is outside parenthesis
	
	
	
	if operator_token_index < 0 or operator_token_index >= tokens.size():
		push_error("[GDShell] 'operator_token_index' (index: %s) is out of range of 'tokens' (size: %s) - Handled as an invalid operator" % [operator_token_index, tokens.size()])
		return false
	
	match tokens[operator_token_index].type:
		# binary operators (operand operator operand)
		Token.Type.OPERATOR_PIPE, Token.Type.OPERATOR_AND, Token.Type.OPERATOR_OR:
			if operator_token_index-1 < 0 or operator_token_index+1 >= tokens.size():
				return false
			# check the left operand
			if (not (tokens[operator_token_index-1].type == Token.Type.WORD 
					or tokens[operator_token_index-1].type == Token.Type.OPERATOR_BACKGROUND
					or tokens[operator_token_index-1].type == Token.Type.OPERATOR_CLOSING_PARENTHESIS)
				):
				return false
			# check the right operand
			if (not (tokens[operator_token_index+1].type == Token.Type.WORD 
					or tokens[operator_token_index+1].type == Token.Type.OPERATOR_NOT
					or tokens[operator_token_index+1].type == Token.Type.OPERATOR_OPENING_PARENTHESIS)):
				return false
		
		# left operators (operator operand)
		Token.Type.OPERATOR_NOT, Token.Type.OPERATOR_EXPAND:
			if operator_token_index+1 >= tokens.size():
				return false
			# check the right operand
			if tokens[operator_token_index+1].type != Token.Type.WORD:
				return false
		
		# right operators (operand operator)
		Token.Type.OPERATOR_BACKGROUND, Token.Type.OPERATOR_SEQUENCE:
			if operator_token_index-1 < 0:
				return false
			# check the left operand
			if tokens[operator_token_index-1].type != Token.Type.WORD:
				return false
		
		# standalone operators
		Token.Type.OPERATOR_OPENING_PARENTHESIS, Token.Type.OPERATOR_CLOSING_PARENTHESIS:
			return true
		
		_:
			push_error("[GDHell] Non-operator token: 'Token.Type.%s'" % str(Token.Type.find_key(tokens[operator_token_index].type)))
			return false
	
	return true


static func tokenize(input: String) -> Array[Token]:
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
			"$":
				tokens.push_back(_tokenize_dollar_sign(input, current_char))
			"(", ")":
				tokens.push_back(_tokenize_parenthesis(input, current_char))
			"\"", "\'":
				tokens.push_back(_tokenize_quote(input, current_char))
			_:
				tokens.push_back(_tokenize_text(input, current_char))
		
		current_char += tokens[-1].consumed
	
	return merge_word_tokens(tokens)


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


static func _tokenize_dollar_sign(_input: String, current_char: int) -> Token:
	return Token.new(Token.Type.OPERATOR_EXPAND, "$", current_char, 1)


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
		if input[i] in [" ", ";", "&", "|", "!", "$", "(", ")", "\"", "\'"]:
			break
		content += input[i]
	
	return Token.new(
		Token.Type.WORD,
		content.c_unescape(),
		current_char,
		content.length()
	)


## Merges WORD tokens if they are not separated by any other token
static func merge_word_tokens(tokens: Array[Token]) -> Array[Token]:
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
