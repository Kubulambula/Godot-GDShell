@icon("res://addons/gdshell/icon.png")
class_name GDShellExpressionParser
extends RefCounted


const _PRECEDENCE_TABLE: Array[Array] = [
	#  !     &     &&    |     ||    ;     WORD  (     )     $       
	[&"<", &"<", &">", &">", &">", &">", &"<", &"<", &"!", &">"], # !
	[&">", &"!", &">", &">", &">", &">", &"!", &"!", &">", &">"], # &
	[&"<", &"<", &">", &">", &">", &">", &"<", &"<", &">", &">"], # &&
	[&"<", &"<", &">", &">", &">", &">", &"<", &"<", &">", &">"], # |
	[&"<", &"<", &">", &">", &">", &">", &"<", &"<", &">", &">"], # ||
	[&"<", &"<", &">", &">", &">", &">", &"<", &"<", &">", &">"], # ;
	[&"!", &">", &">", &">", &">", &">", &"=", &"!", &">", &">"], # WORD
	[&"<", &"<", &"<", &"<", &"<", &"<", &"<", &"<", &"=", &"!"], # (
	[&"<", &">", &">", &">", &">", &">", &"!", &"!", &">", &">"], # )
	[&"<", &"<", &"<", &"<", &"<", &"<", &"<", &"<", &"!", &"."], # $
]

const _PRECEDENCE_TABLE_KEYS: Array[GDShellExpressionTokenizer.Token.Type] = [
	GDShellExpressionTokenizer.Token.Type.OPERATOR_NOT,
	GDShellExpressionTokenizer.Token.Type.OPERATOR_BACKGROUND,
	GDShellExpressionTokenizer.Token.Type.OPERATOR_AND,
	GDShellExpressionTokenizer.Token.Type.OPERATOR_PIPE,
	GDShellExpressionTokenizer.Token.Type.OPERATOR_OR,
	GDShellExpressionTokenizer.Token.Type.OPERATOR_SEQUENCE,
	GDShellExpressionTokenizer.Token.Type.WORD,
	GDShellExpressionTokenizer.Token.Type.OPERATOR_OPENING_PARENTHESIS,
	GDShellExpressionTokenizer.Token.Type.OPERATOR_CLOSING_PARENTHESIS,
	GDShellExpressionTokenizer.Token.Type.EXPRESSION_END,
]


class ParserResult extends RefCounted:
	enum Status {
		OK,
		ERROR,
	}
	
	var result: Dictionary
	var status: Status
	var description: String
	var input_expression_error_start_index: int
	var input_expression_error_length: int
	
	func _init(_result: Dictionary, _status: Status, _description: String, _input_expression_error_start_index: int, _input_expression_error_length: int) -> void:
		result = _result
		status = _status
		description = _description
		input_expression_error_start_index = _input_expression_error_start_index
		input_expression_error_length = _input_expression_error_length


static func parse(tokens: Array[GDShellExpressionTokenizer.Token]) -> ParserResult:
	tokens.push_back(GDShellExpressionTokenizer.Token.new(GDShellExpressionTokenizer.Token.Type.EXPRESSION_END, "$", 0, 0)) # For easier precedence
	var current_token_index: int = 0 # Index into tokens array
	var token_stack: Array[GDShellExpressionTokenizer.Token] = [GDShellExpressionTokenizer.Token.new(GDShellExpressionTokenizer.Token.Type.EXPRESSION_END, "$", 0, 0)] # Helper stack for precedence
	var expression_node_stack: Array[Dictionary] = [] # Expresion tree building stack
	
	while current_token_index < tokens.size():
		var topmost_terminal_index: int = _parse_precedence_get_topmost_terminal_index(token_stack)
		match _parse_get_precedence_action(token_stack[topmost_terminal_index], tokens[current_token_index]):
			&"<": # Shift
				if token_stack.insert(topmost_terminal_index + 1, GDShellExpressionTokenizer.Token.new(GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE, "<", 0, 0)) != OK: # isert handle for expression reduction
					return ParserResult.new(
						{},
						ParserResult.Status.ERROR,
						"cannot insert EXPRESSION_HANDLE",
						tokens[current_token_index].start_char_index,
						tokens[current_token_index].consumed_chars
					)
				token_stack.push_back(tokens[current_token_index])
				current_token_index += 1
			
			&">": # Reduce
				if _parse_precedence_reduce_to_expression(token_stack, expression_node_stack) == false:
					return ParserResult.new(
						{},
						ParserResult.Status.ERROR,
						"cannot reduce stack to EXPRESSION. Token stack: '%s'" % str(token_stack),
						tokens[current_token_index].start_char_index,
						tokens[current_token_index].consumed_chars
					)
			
			&"=": # Push
				token_stack.push_back(tokens[current_token_index])
				current_token_index += 1
			
			&"!": # Error
				return ParserResult.new(
					{},
					ParserResult.Status.ERROR,
					"error in precedence table at [%s,%s] with symbols [%s,%s]" % [
						_parse_get_precedence_index(token_stack[topmost_terminal_index]),
						_parse_get_precedence_index(tokens[current_token_index]),
						GDShellExpressionTokenizer.Token.Type.find_key(_parse_get_precedence_index(token_stack[topmost_terminal_index])),
						GDShellExpressionTokenizer.Token.Type.find_key(_parse_get_precedence_index(tokens[current_token_index]))
					],
					tokens[current_token_index].start_char_index,
					tokens[current_token_index].consumed_chars
				)
			
			&".": # OK
				return ParserResult.new(
					{} if expression_node_stack.is_empty() else expression_node_stack[0],
					ParserResult.Status.OK,
					"OK",
					0,
					0
				)
	
	return ParserResult.new(
		{},
		ParserResult.Status.ERROR,
		"parsing ended prematurely due to token buffer out of bounds.",
		tokens[current_token_index].start_char_index,
		tokens[current_token_index].consumed_chars
	)


static func _parse_get_reduceable_tokens(token_stack: Array[GDShellExpressionTokenizer.Token]) -> Array[GDShellExpressionTokenizer.Token]:
	for i: int in range(token_stack.size() - 1, -1, -1):
		if token_stack[i].type == GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE:
			return token_stack.slice(i)
	return []


static func _parse_precedence_is_token_array_type_patern_match(tokens: Array[GDShellExpressionTokenizer.Token], pattern: Array[GDShellExpressionTokenizer.Token.Type]) -> bool:
	if tokens.size() != pattern.size():
		return false
	for i: int in tokens.size():
		if tokens[i].type != pattern[i]:
			return false
	return true


static func _parse_precedence_reduce_to_expression(token_stack: Array[GDShellExpressionTokenizer.Token], expression_node_stack: Array[Dictionary]) -> bool:
	var reduceable_tokens: Array[GDShellExpressionTokenizer.Token] = _parse_get_reduceable_tokens(token_stack)
	match reduceable_tokens.map(func(token: GDShellExpressionTokenizer.Token) -> GDShellExpressionTokenizer.Token.Type: return token.type):
		# E -> WORD+
		[GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE, GDShellExpressionTokenizer.Token.Type.WORD, ..]:
			_parse_reduce_words(token_stack, expression_node_stack)
		# E -> (E)
		[GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE, GDShellExpressionTokenizer.Token.Type.OPERATOR_OPENING_PARENTHESIS, GDShellExpressionTokenizer.Token.Type.EXPRESSION, GDShellExpressionTokenizer.Token.Type.OPERATOR_CLOSING_PARENTHESIS]:
			_parse_reduce_parenthesis(token_stack)
		# E -> !E
		[GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE, GDShellExpressionTokenizer.Token.Type.OPERATOR_NOT, GDShellExpressionTokenizer.Token.Type.EXPRESSION]:
			_parse_reduce_not(token_stack, expression_node_stack)
		# E -> E&
		[GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE, GDShellExpressionTokenizer.Token.Type.EXPRESSION, GDShellExpressionTokenizer.Token.Type.OPERATOR_BACKGROUND]:
			_parse_reduce_background(token_stack, expression_node_stack)
		# E -> E && E
		[GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE, GDShellExpressionTokenizer.Token.Type.EXPRESSION, GDShellExpressionTokenizer.Token.Type.OPERATOR_AND, GDShellExpressionTokenizer.Token.Type.EXPRESSION]:
			_parse_reduce_and(token_stack, expression_node_stack)
		# E -> E | E
		[GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE, GDShellExpressionTokenizer.Token.Type.EXPRESSION, GDShellExpressionTokenizer.Token.Type.OPERATOR_PIPE, GDShellExpressionTokenizer.Token.Type.EXPRESSION]:
			_parse_reduce_pipe(token_stack, expression_node_stack)
		# E -> E || E
		[GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE, GDShellExpressionTokenizer.Token.Type.EXPRESSION, GDShellExpressionTokenizer.Token.Type.OPERATOR_OR, GDShellExpressionTokenizer.Token.Type.EXPRESSION]:
			_parse_reduce_or(token_stack, expression_node_stack)
		# E -> E ; E
		[GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE, GDShellExpressionTokenizer.Token.Type.EXPRESSION, GDShellExpressionTokenizer.Token.Type.OPERATOR_SEQUENCE, GDShellExpressionTokenizer.Token.Type.EXPRESSION]:
			_parse_reduce_sequence(token_stack, expression_node_stack)
		 # ! -> ()
		[GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE, GDShellExpressionTokenizer.Token.Type.OPERATOR_OPENING_PARENTHESIS, GDShellExpressionTokenizer.Token.Type.OPERATOR_CLOSING_PARENTHESIS]:
			return false
		# ! -> ..
		var _unmatched_reduceable_tokens_pattern: # Unknown unreduceable stack
			return false
	return true


# E -> WORD*
static func _parse_reduce_words(token_stack: Array[GDShellExpressionTokenizer.Token], expression_node_stack: Array[Dictionary]) -> void:
	var word_tokens: Array[GDShellExpressionTokenizer.Token] = []
	while token_stack.back() != null:
		var current_token: GDShellExpressionTokenizer.Token = token_stack.pop_back()
		if current_token.type == GDShellExpressionTokenizer.Token.Type.EXPRESSION_HANDLE:
			break
		word_tokens.push_front(current_token)
	
	token_stack.push_back(GDShellExpressionTokenizer.Token.new(GDShellExpressionTokenizer.Token.Type.EXPRESSION, "", 0, 0))
	expression_node_stack.push_back({
		"type": "command",
		"index": word_tokens[0].start_char_index,
		"length": word_tokens[0].consumed_chars,
		"name": word_tokens.pop_front().content,
		"args": word_tokens.map(
			func(word_token: GDShellExpressionTokenizer.Token) -> String:
				return word_token.content
				),
	})


# E -> (E)
static func _parse_reduce_parenthesis(token_stack: Array[GDShellExpressionTokenizer.Token]) -> void:
	token_stack.pop_back() # )
	token_stack.pop_back() # EXPRESSION
	token_stack.pop_back() # (
	token_stack.pop_back() # EXPRESSION_HANDLE
	token_stack.push_back(GDShellExpressionTokenizer.Token.new(GDShellExpressionTokenizer.Token.Type.EXPRESSION, "", 0, 0))


static func _parse_reduce_not(token_stack: Array[GDShellExpressionTokenizer.Token], expression_node_stack: Array[Dictionary]) -> void:
	var right: Dictionary = expression_node_stack.pop_back()
	expression_node_stack.push_back({
		"type": "operator",
		"index": token_stack[-2].start_char_index,
		"length": 1,
		"operator": "!",
		"right": right,
	})
	token_stack.pop_back() # EXPRESSION
	token_stack.pop_back() # OPERATOR_NOT
	token_stack.pop_back() # EXPRESSION_HANDLE
	token_stack.push_back(GDShellExpressionTokenizer.Token.new(GDShellExpressionTokenizer.Token.Type.EXPRESSION, "", 0, 0))


static func _parse_reduce_background(token_stack: Array[GDShellExpressionTokenizer.Token], expression_node_stack: Array[Dictionary]) -> void:
	var left: Dictionary = expression_node_stack.pop_back()
	expression_node_stack.push_back({
		"type": "operator",
		"index": token_stack[-1].start_char_index,
		"length": 1,
		"operator": "&",
		"left": left,
	})
	token_stack.pop_back() # OPERATOR_BACKGROUND
	token_stack.pop_back() # EXPRESSION
	token_stack.pop_back() # EXPRESSION_HANDLE
	token_stack.push_back(GDShellExpressionTokenizer.Token.new(GDShellExpressionTokenizer.Token.Type.EXPRESSION, "", 0, 0))


static func _parse_reduce_and(token_stack: Array[GDShellExpressionTokenizer.Token], expression_node_stack: Array[Dictionary]) -> void:
	var right: Dictionary = expression_node_stack.pop_back()
	var left: Dictionary = expression_node_stack.pop_back()
	expression_node_stack.push_back({
		"type": "operator",
		"index": token_stack[-2].start_char_index,
		"length": 2,
		"operator": "&&",
		"left": left,
		"right": right,
	})
	token_stack.pop_back() # EXPRESSION
	token_stack.pop_back() # OPERATOR_AND
	token_stack.pop_back() # EXPRESSION
	token_stack.pop_back() # EXPRESSION_HANDLE
	token_stack.push_back(GDShellExpressionTokenizer.Token.new(GDShellExpressionTokenizer.Token.Type.EXPRESSION, "", 0, 0))


static func _parse_reduce_pipe(token_stack: Array[GDShellExpressionTokenizer.Token], expression_node_stack: Array[Dictionary]) -> void:
	var right: Dictionary = expression_node_stack.pop_back()
	var left: Dictionary = expression_node_stack.pop_back()
	expression_node_stack.push_back({
		"type": "operator",
		"index": token_stack[-2].start_char_index,
		"length": 1,
		"operator": "|",
		"left": left,
		"right": right,
	})
	token_stack.pop_back() # EXPRESSION
	token_stack.pop_back() # OPERATOR_PIPE
	token_stack.pop_back() # EXPRESSION
	token_stack.pop_back() # EXPRESSION_HANDLE
	token_stack.push_back(GDShellExpressionTokenizer.Token.new(GDShellExpressionTokenizer.Token.Type.EXPRESSION, "", 0, 0))


static func _parse_reduce_or(token_stack: Array[GDShellExpressionTokenizer.Token], expression_node_stack: Array[Dictionary]) -> void:
	var right: Dictionary = expression_node_stack.pop_back()
	var left: Dictionary = expression_node_stack.pop_back()
	expression_node_stack.push_back({
		"type": "operator",
		"index": token_stack[-2].start_char_index,
		"length": 2,
		"operator": "||",
		"left": left,
		"right": right,
	})
	token_stack.pop_back() # EXPRESSION
	token_stack.pop_back() # OPERATOR_OR
	token_stack.pop_back() # EXPRESSION
	token_stack.pop_back() # EXPRESSION_HANDLE
	token_stack.push_back(GDShellExpressionTokenizer.Token.new(GDShellExpressionTokenizer.Token.Type.EXPRESSION, "", 0, 0))


static func _parse_reduce_sequence(token_stack: Array[GDShellExpressionTokenizer.Token], expression_node_stack: Array[Dictionary]) -> void:
	var right: Dictionary = expression_node_stack.pop_back()
	var left: Dictionary = expression_node_stack.pop_back()
	expression_node_stack.push_back({
		"type": "operator",
		"index": token_stack[-2].start_char_index,
		"length": 1,
		"operator": ";",
		"left": left,
		"right": right,
	})
	token_stack.pop_back() # EXPRESSION
	token_stack.pop_back() # OPERATOR_SEQUENCE
	token_stack.pop_back() # EXPRESSION
	token_stack.pop_back() # EXPRESSION_HANDLE
	token_stack.push_back(GDShellExpressionTokenizer.Token.new(GDShellExpressionTokenizer.Token.Type.EXPRESSION, "", 0, 0))


static func _parse_precedence_get_topmost_terminal_index(token_stack: Array[GDShellExpressionTokenizer.Token]) -> int:
	for i: int in range(token_stack.size() - 1, -1, -1):
		if token_stack[i].type == GDShellExpressionTokenizer.Token.Type.EXPRESSION:
			continue
		return i
	return 0


static func _parse_get_precedence_index(token: GDShellExpressionTokenizer.Token) -> int:
	return _PRECEDENCE_TABLE_KEYS.find(token.type)


static func _parse_get_precedence_action(stack_token: GDShellExpressionTokenizer.Token, current_token: GDShellExpressionTokenizer.Token) -> String:
	return _PRECEDENCE_TABLE[_parse_get_precedence_index(stack_token)][_parse_get_precedence_index(current_token)]
