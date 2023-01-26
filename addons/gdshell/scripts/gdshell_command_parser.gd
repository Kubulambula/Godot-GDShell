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
	var result: Variant
	var err_index: int
	var err_string: String = ""
	
	func _init(_status: Status, _input: String, _result: Array[Token], _err_index: int=-1, _err_string: String=""):
		status = _status
		input = _input
		result = _result
		err_index = _err_index
		err_string = _err_string


class Token:
	enum Type {
		ERROR,
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
				[],
		)
	elif tokens[-1].type == Token.Type.ERROR:
		return ParserResult.new(
				ParserResult.Status.ERROR,
				input,
				tokens,
				tokens[-1].start_char_index,
				tokens[-1].content,
		)
	elif tokens[-1].type == Token.Type.WORD_UNTERMINATED:
		return ParserResult.new(
				ParserResult.Status.UNTERMINATED,
				input,
				tokens,
				tokens[-1].start_char_index, # This points at the start of the token - opening quote
				tokens[-1].content,
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


static func _expand_aliases(tokens: Array[Token], command_db: GDShellCommandDB, forbidden_aliases: Array[String]=[]) -> Array[Token]:
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
					or tokens[operator_token_index-1].type == Token.Type.OPERATOR_BACKGROUND)):
				return false
			# check the right operand
			if (not (tokens[operator_token_index+1].type == Token.Type.WORD 
					or tokens[operator_token_index+1].type == Token.Type.OPERATOR_NOT)):
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
	var current: int = 0
	
	while current < input.length():
		match input[current]:
			" ":
				tokens.push_back(_tokenize_space(input, current))
			";":
				tokens.push_back(_tokenize_semicolon(input, current))
			"&":
				tokens.push_back(_tokenize_and(input, current))
			"|":
				tokens.push_back(_tokenize_pipe(input, current))
			"!":
				tokens.push_back(_tokenize_exclamation(input, current))
			"$":
				tokens.push_back(_tokenize_dollar_sign(input, current))
			"(", ")":
				tokens.push_back(_tokenize_parenthesis(input, current))
			"\"", "\'":
				tokens.push_back(_tokenize_quoted_text(input, current))
			_:
				tokens.push_back(_tokenize_text(input, current))
		
		if tokens[-1].type == Token.Type.ERROR:
			return tokens
		
		current += tokens[-1].consumed
	
	return _merge_word_tokens(tokens)


static func _tokenize_space(_input: String, current: int) -> Token:
	return Token.new(Token.Type.SPACE, " ", current, 1)


static func _tokenize_semicolon(_input: String, current: int) -> Token:
	return Token.new(Token.Type.OPERATOR_SEQUENCE, ";", current, 1)


static func _tokenize_and(input: String, current: int) -> Token:
	if current < input.length()-1 and input[current+1] == "&":
		return Token.new(Token.Type.OPERATOR_AND, "&&", current, 2)
	return Token.new(Token.Type.OPERATOR_BACKGROUND, "&", current, 1)


static func _tokenize_pipe(input: String, current: int) -> Token:
	if current < input.length()-1 and input[current+1] == "|":
		return Token.new(Token.Type.OPERATOR_OR, "||", current, 2)
	return Token.new(Token.Type.OPERATOR_PIPE, "|", current, 1)


static func _tokenize_exclamation(_input: String, current: int) -> Token:
	return Token.new(Token.Type.OPERATOR_NOT, "!", current, 1)


static func _tokenize_dollar_sign(_input: String, current: int) -> Token:
	return Token.new(Token.Type.OPERATOR_EXPAND, "$", current, 1)


static func _tokenize_parenthesis(input: String, current: int) -> Token:
	if input[current] == "(":
		return Token.new(Token.Type.OPERATOR_OPENING_PARENTHESIS, "(", current, 1)
	else:
		return Token.new(Token.Type.OPERATOR_CLOSING_PARENTHESIS, ")", current, 1)


static func _tokenize_quoted_text(input: String, current: int) -> Token:
	var start_char = current
	var content: String = ""
	var quote_type: String = input[current]
	current += 1 # skip the opening quote
	
	while true:
		if current >= input.length():
			return Token.new(
					Token.Type.WORD_UNTERMINATED,
					"unterminated token",
					start_char,
					content.length() + 1 # accounts for the starting quote
				)
		
		if input[current] == quote_type:
			if input[max(0, current-1)] != "\\":
				return Token.new(
						Token.Type.WORD,
						content.c_unescape(),
						start_char,
						content.length() + 2 # accounts for the starting and ending quotes
					)
		
		content += input[current]
		current += 1
	
	return null


static func _tokenize_text(input: String, current: int) -> Token:
	var start_char = current
	var content: String = ""
	
	while true:
		if current == input.length() or input[current] in [" ", ";", "&", "\"", "\'", ")"]:
			return Token.new(
					Token.Type.WORD,
					content.c_unescape(),
					start_char,
					content.length()
			)
		
		if input[current] in ["|", "!", "$", "("]:
			return Token.new(
					Token.Type.ERROR,
					"unexpected token",
					start_char,
					content.length() + 1
			)
		
		content += input[current]
		current += 1
	
	return null


# Merges WORD tokens if they are not separated by any other token
static func _merge_word_tokens(tokens: Array[Token]) -> Array[Token]:
	var merged_tokens: Array[Token] = []
	var last_token_type: Token.Type = Token.Type.ERROR
	var word_temp: Token = Token.new(Token.Type.WORD, "", 0, -1)
	var current: int = 0
	while current < tokens.size():
		if tokens[current].type == Token.Type.WORD:
			if last_token_type == Token.Type.WORD: # Merge words
				# Append to word_temp
				word_temp.content += tokens[current].content
				word_temp.consumed += tokens[current].consumed
				current += 1
			elif last_token_type != Token.Type.WORD: # Prepare for possible future merge
				# Setup a new word_temp
				word_temp.start_char_index = tokens[current].start_char_index
				word_temp.content = tokens[current].content
				word_temp.consumed = tokens[current].consumed
				current += 1
				last_token_type = Token.Type.WORD
		else:
			if word_temp.consumed != -1: # If the word_temp is not empty
				# Append and then clear word_temp
				merged_tokens.append(word_temp)
				word_temp = Token.new(Token.Type.WORD, "", 0, -1)
			# Append the current non-word token
			merged_tokens.append(tokens[current])
			last_token_type = tokens[current].type
			current += 1
	# Append the word_temp if it is not empty
	if word_temp.consumed != -1:
		merged_tokens.append(word_temp)
	
	return merged_tokens
