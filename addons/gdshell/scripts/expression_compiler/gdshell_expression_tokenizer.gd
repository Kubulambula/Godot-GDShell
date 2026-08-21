@icon("res://addons/gdshell/icon.png")
class_name GDShellExpressionTokenizer
extends RefCounted


class Token extends RefCounted:
	enum Type {
		# Error token - content of the token is an error message
		ERROR,
		# Parser tokens
		EXPRESSION,
		EXPRESSION_END,
		EXPRESSION_HANDLE,
		# Helper tokenizer token
		SPACE,
		# Tokenizer tokens
		WORD,
		WORD_UNTERMINATED,
#		OPERATOR_EXPAND, # (variable? macro?)
		OPERATOR_NOT,
		OPERATOR_BACKGROUND,
		OPERATOR_AND,
		OPERATOR_PIPE,
		OPERATOR_OR,
		OPERATOR_SEQUENCE,
		OPERATOR_OPENING_PARENTHESIS,
		OPERATOR_CLOSING_PARENTHESIS,
	}

	var type: Type
	var content: String
	var start_char_index: int
	var consumed_chars: int

	func _init(_type: Type, _content: String, _start_char_index: int, _consumed_chars: int) -> void:
		self.type = _type
		self.content = _content
		self.start_char_index = _start_char_index
		self.consumed_chars = _consumed_chars

	func _to_string() -> String:
		return "{Token: %s, Content: \"%s\", Start char index: %s}" % [str(Type.find_key(type)), content, start_char_index]


class TokenizerResult extends RefCounted:
	enum Status {
		OK,
		ERROR,
		UNTERMINATED,
	}

	var result: Array[Token]
	var status: Status
	var description: String

	func _init(_result: Array[Token], _status: TokenizerResult.Status, _description: String) -> void:
		result = _result
		status = _status
		description = _description


static func tokenize(input_expression: String) -> TokenizerResult:
	var tokens: Array[Token] = []
	var current_token: Token = null
	var current_char_index: int = 0

	if input_expression.is_empty():
		return TokenizerResult.new([], TokenizerResult.Status.OK, "empty input expression")

	while current_char_index < input_expression.length():
		match input_expression[current_char_index]:
			" ":
				current_token = _tokenize_space(input_expression, current_char_index)
			";":
				current_token = _tokenize_semicolon(input_expression, current_char_index)
			"!":
				current_token = _tokenize_exclamation(input_expression, current_char_index)
			#"$": # TODO variable/macro operator
				#tokens.push_back(_tokenize_dollar_sign(input_expression, current_char))
			"&":
				current_token = _tokenize_and(input_expression, current_char_index)
			"|":
				current_token = _tokenize_vertical_slash(input_expression, current_char_index)
			"(", ")":
				current_token = _tokenize_parenthesis(input_expression, current_char_index)
			"\"", "\'":
				current_token = _tokenize_quote(input_expression, current_char_index)
			_:
				current_token = _tokenize_text(input_expression, current_char_index)

		current_char_index += current_token.consumed_chars
		tokens.push_back(current_token)

		if current_token.type == Token.Type.ERROR:
			return TokenizerResult.new(
				tokens,
				TokenizerResult.Status.ERROR,
				current_token.content
			)
		if current_token.type == Token.Type.WORD_UNTERMINATED:
			return TokenizerResult.new(
				tokens,
				TokenizerResult.Status.UNTERMINATED,
				"unterminated expression"
			)

	return TokenizerResult.new(
		_filter_out_space_tokens(_merge_word_tokens(tokens)),
		TokenizerResult.Status.OK,
		"OK"
	)


static func _tokenize_space(input_expression: String, start_char_index: int) -> Token:
	if input_expression[start_char_index] != " ":
		return Token.new(
			Token.Type.ERROR,
			"cannot tokenize \"%s\" as space" % input_expression[start_char_index],
			start_char_index,
			0
		)

	var space_chars_consumed: int = 0
	while start_char_index + space_chars_consumed < input_expression.length() and input_expression[start_char_index + space_chars_consumed] == " ":
		space_chars_consumed += 1
	return Token.new(Token.Type.SPACE, " ", start_char_index, space_chars_consumed)


static func _tokenize_semicolon(input_expression: String, start_char_index: int) -> Token:
	if input_expression[start_char_index] != ";":
		return Token.new(
			Token.Type.ERROR,
			"cannot tokenize \"%s\" as semicolon" % input_expression[start_char_index],
			start_char_index,
			0
		)

	return Token.new(Token.Type.OPERATOR_SEQUENCE, ";", start_char_index, 1)


static func _tokenize_exclamation(input_expression: String, start_char_index: int) -> Token:
	if input_expression[start_char_index] != "!":
		return Token.new(
			Token.Type.ERROR,
			"cannot tokenize \"%s\" as exclamation" % input_expression[start_char_index],
			start_char_index,
			0
		)

	return Token.new(Token.Type.OPERATOR_NOT, "!", start_char_index, 1)


static func _tokenize_and(input_expression: String, start_char_index: int) -> Token:
	if input_expression[start_char_index] != "&":
		return Token.new(
			Token.Type.ERROR,
			"cannot tokenize \"%s\" as and" % input_expression[start_char_index],
			start_char_index,
			0
		)

	if start_char_index < input_expression.length() - 1 and input_expression[start_char_index + 1] == "&":
		return Token.new(Token.Type.OPERATOR_AND, "&&", start_char_index, 2)
	return Token.new(Token.Type.OPERATOR_BACKGROUND, "&", start_char_index, 1)


static func _tokenize_vertical_slash(input_expression: String, start_char_index: int) -> Token:
	if input_expression[start_char_index] != "|":
		return Token.new(
			Token.Type.ERROR,
			"cannot tokenize \"%s\" as vertical slash" % input_expression[start_char_index],
			start_char_index,
			0
		)

	if start_char_index < input_expression.length() - 1 and input_expression[start_char_index + 1] == "|":
		return Token.new(Token.Type.OPERATOR_OR, "||", start_char_index, 2)
	return Token.new(Token.Type.OPERATOR_PIPE, "|", start_char_index, 1)


static func _tokenize_parenthesis(input_expression: String, start_char_index: int) -> Token:
	if input_expression[start_char_index] == "(":
		return Token.new(Token.Type.OPERATOR_OPENING_PARENTHESIS, "(", start_char_index, 1)
	elif input_expression[start_char_index] == ")":
		return Token.new(Token.Type.OPERATOR_CLOSING_PARENTHESIS, ")", start_char_index, 1)
	else:
		return Token.new(
			Token.Type.ERROR,
			"cannot tokenize \"%s\" as parenthesis" % input_expression[start_char_index],
			start_char_index,
			0
		)


static func _tokenize_quote(input_expression: String, start_char_index: int) -> Token:
	if input_expression[start_char_index] != "\"" and input_expression[start_char_index] != "'":
		return Token.new(
			Token.Type.ERROR,
			"cannot tokenize \"%s\" as quote" % input_expression[start_char_index],
			start_char_index,
			0
		)

	var content: String = ""
	for i: int in range(start_char_index + 1, input_expression.length()): # Skip the opening quote and start on the char right after
		if input_expression[i] == input_expression[start_char_index] and input_expression[i - 1] != "\\": # check for string end
			return Token.new(
				Token.Type.WORD,
				content.c_unescape(),
				start_char_index,
				content.length() + 2 # accounts for the starting and ending quotes
			)
		content += input_expression[i]

	# End of input_expression was reached without finding a closing quote
	return Token.new(
		Token.Type.WORD_UNTERMINATED,
		content.c_unescape(),
		start_char_index,
		content.length() + 1 # accounts just for the starting quote
	)


static func _tokenize_text(input_expression: String, start_char_index: int) -> Token:
	var content: String = ""

	for i: int in range(start_char_index, input_expression.length()):
		# check if the character should end the WORD token.
		if input_expression[i] in [" ", ";", "&", "|", "!", "(", ")", "\'", "\"", "\\", "\a", "\b", "\f", "\n", "\r", "\t", "\v"]:
			break
		content += input_expression[i]

	if content.is_empty():
		return Token.new(
			Token.Type.ERROR,
			"cannot start tokenizing word",
			start_char_index,
			0
		)

	return Token.new(
		Token.Type.WORD,
		content,
		start_char_index,
		content.length()
	)


## Merges WORD tokens if they are not separated by any other token
static func _merge_word_tokens(tokens: Array[Token]) -> Array[Token]:
	if tokens.is_empty():
		return tokens
	# We now know that tokens is not empty so we append the first token for later simplification
	var merged_tokens: Array[Token] = [tokens[0]]

	# Start from the second token as we already appended the first
	for i: int in range(1, tokens.size()):
		if tokens[i].type == Token.Type.WORD and merged_tokens[-1].type == Token.Type.WORD:
			merged_tokens[-1].content += tokens[i].content
			merged_tokens[-1].consumed_chars += tokens[i].consumed_chars
		else:
			merged_tokens.append(tokens[i])

	return merged_tokens


## Filters out SPACE tokens as after _merge_word_tokens() they are useless and it simplifies next operations.
static func _filter_out_space_tokens(tokens: Array[Token]) -> Array[Token]:
	return tokens.filter(
		func is_token_not_space(token: Token) -> bool:
			return token.type != Token.Type.SPACE
	)
