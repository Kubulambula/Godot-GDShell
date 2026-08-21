@icon("res://addons/gdshell/icon.png")
class_name GDShellExpressionCompiler
extends RefCounted


class CompilerResult extends RefCounted:
	enum Status {
		OK,
		ERROR,
		UNTERMINATED,
	}
	
	var result: Dictionary
	var status: Status
	var input_expression: String
	var description: String
	var input_expression_error_start_index: int
	var input_expression_error_length: int
	
	func _init(_result: Dictionary, _status: Status, _input_expression: String, _description: String, _input_expression_error_start_index: int, _input_expression_error_length: int) -> void:
		result = _result
		status = _status
		input_expression = _input_expression
		description = _description
		input_expression_error_start_index = _input_expression_error_start_index
		input_expression_error_length = _input_expression_error_length


static func compile(input_expression: String) -> CompilerResult:
	# Tokenize the input
	var tokenizer_result: GDShellExpressionTokenizer.TokenizerResult = GDShellExpressionTokenizer.tokenize(input_expression)
	
	if tokenizer_result.status == GDShellExpressionTokenizer.TokenizerResult.Status.ERROR:
		return CompilerResult.new(
			{},
			CompilerResult.Status.ERROR,
			input_expression,
			tokenizer_result.description,
			tokenizer_result.result[-1].start_char_index,
			tokenizer_result.result[-1].consumed_chars
		)
	if tokenizer_result.status == GDShellExpressionTokenizer.TokenizerResult.Status.UNTERMINATED:
		return CompilerResult.new(
			{},
			CompilerResult.Status.UNTERMINATED,
			input_expression,
			"unterminated expression",
			tokenizer_result.result[-1].start_char_index,
			tokenizer_result.result[-1].consumed_chars
		)
	# empty input - dont even bother with parsing
	if tokenizer_result.result.is_empty():
		return CompilerResult.new(
			{},
			CompilerResult.Status.OK,
			input_expression,
			tokenizer_result.description,
			0,
			0
		)
	
	# Parse the tokenized input
	var parser_result: GDShellExpressionParser.ParserResult = GDShellExpressionParser.parse(tokenizer_result.result)
	return CompilerResult.new(
		parser_result.result,
		CompilerResult.Status.OK if parser_result.status == GDShellExpressionParser.ParserResult.Status.OK else CompilerResult.Status.ERROR,
		input_expression,
		parser_result.description,
		parser_result.input_expression_error_start_index,
		parser_result.input_expression_error_length
	)


static func is_compiled_expression_valid(compiled_expression: Dictionary, error_info: bool = false) -> bool:
	match compiled_expression.get("type"):
		"command":
			return is_compiled_expression_command_valid(compiled_expression, error_info)
		"operator":
			return is_compiled_expression_operator_valid(compiled_expression, error_info)
		_:
			# Bad or missing type
			return false


static func is_compiled_expression_command_valid(compiled_expression: Dictionary, error_info: bool = false) -> bool:
	if typeof(compiled_expression.get("type")) != TYPE_STRING:
		return false
	if typeof(compiled_expression.get("name")) != TYPE_STRING:
		return false
	if typeof(compiled_expression.get("args")) != TYPE_ARRAY:
		return false
	for item: Variant in compiled_expression.get("args", []):
		if typeof(item) != TYPE_STRING:
			return false
	
	if not error_info:
		return true
	return _check_compiled_expression_error_info(compiled_expression)


static func is_compiled_expression_operator_valid(compiled_expression: Dictionary, error_info: bool = false) -> bool:
	if typeof(compiled_expression.get("type")) != TYPE_STRING:
		return false
	if typeof(compiled_expression.get("operator")) != TYPE_STRING:
		return false
	
	match compiled_expression["operator"]:
		"!":
			if not _check_compiled_expression_operand(compiled_expression, "left", error_info):
				return false
		"&":
			if not _check_compiled_expression_operand(compiled_expression, "right", error_info):
				return false
		"|", "||", "&&", ";":
			if not _check_compiled_expression_operand(compiled_expression, "left", error_info):
				return false
			if not _check_compiled_expression_operand(compiled_expression, "right", error_info):
				return false
		_:
			# Invalid operator
			return false
	
	if not error_info:
		return true
	return _check_compiled_expression_error_info(compiled_expression)


static func _check_compiled_expression_error_info(compiled_expression: Dictionary) -> bool:
	if typeof(compiled_expression.get("index")) != TYPE_INT:
		return false
	if typeof(compiled_expression.get("length")) != TYPE_INT:
		return false
	if compiled_expression["index"] < 0 or compiled_expression["length"] < 0:
		return false
	return true


static func _check_compiled_expression_operand(compiled_expression: Dictionary, operand_key: String, error_info: bool) -> bool:
	if typeof(compiled_expression.get(operand_key)) != TYPE_DICTIONARY:
		return false
	@warning_ignore("unsafe_call_argument")
	return is_compiled_expression_valid(compiled_expression[operand_key], error_info)



#static func is_compiled_expression_valid(expression: Dictionary, error_info: bool = false, command_db: GDShellCommandDB = null) -> bool:
	#if expression.get("type") == "command":
		#return _is_compiled_expression_command_valid(expression, error_info, command_db)
	#
	#
	#
	#return false
#
#
#
#static func _is_compiled_expression_command_valid(command_expression: Dictionary, error_info: bool = false, command_db: GDShellCommandDB = null) -> bool:
	## mandatory fields
	#if not command_expression.has_all(["type", "name", "args"]):
		#return false
	#
	## type
	#if command_expression["type"] != "command":
		#return false
	#
	## name
	#if typeof(command_expression["name"]) != TYPE_STRING:
		#return false
	#@warning_ignore("unsafe_method_access")
	#if command_expression["name"].is_empty():
		#return false
	#
	## args
	#if typeof(command_expression["args"]) != TYPE_ARRAY:
		#return false
	#@warning_ignore("unsafe_method_access")
	#if command_expression["args"].any(
		#func(arg: Variant) -> bool:
			#return typeof(arg) != TYPE_STRING
	#):
		#return false
	#
	## error info
	#if error_info:
		#if not _is_compiled_expression_error_info_valid():
			#return false
	#
	## command validit
	#
	#return false
#
#
#static func _is_compiled_expression_error_info_valid() -> bool:
	#return false


#
#static func is_command_expression_valid(command_expression: Dictionary, error_info: bool = false, command_db: GDShellCommandDB = null) -> bool:
	#if not command_expression.has_all(["type", "name", "args"]):
		#return false
	## type
	#if command_expression["type"] != "command":
		#return false
	## name
	#if typeof(command_expression["name"]) != TYPE_STRING:
		#return false
	#if command_db != null:
		#push_error("CommandDB validation not yet implemented.")
	## args
	#if typeof(command_expression["args"]) != TYPE_ARRAY:
		#return false
	#@warning_ignore("unsafe_method_access")
	#if command_expression["args"].any(
		#func(arg: Variant) -> bool:
			#return typeof(arg) != TYPE_STRING
			#):
		#return false
	## for reporting where the error occurred
	#if error_info:
		#if not command_expression.has_all(["index", "lenght"]):
			#return false
		## index
		#if typeof(command_expression["index"]) != TYPE_INT:
			#return false
		#if command_expression["index"] < 0:
			#return false
		## length
		#if typeof(command_expression["length"]) != TYPE_INT:
			#return false
		#if command_expression["length"] < 1:
			#return false
	#
	#return true
#
#
#static func is_operator_expression_valid(operator_expression: Dictionary, error_info: bool = false) -> bool:
	#if not operator_expression.has_all(["type", "operator"]):
		#return false
	## type
	#if operator_expression["type"] != "operator":
		#return false
	## for reporting where the error occurred
	#if error_info:
		#if not operator_expression.has_all(["index", "lenght"]):
			#return false
		## index
		#if typeof(operator_expression["index"]) != TYPE_INT:
			#return false
		#if operator_expression["index"] < 0:
			#return false
		## length
		#if typeof(operator_expression["length"]) != TYPE_INT:
			#return false
		#if operator_expression["length"] < 1:
			#return false
	## operator
	#if typeof(operator_expression["operator"]) != TYPE_STRING:
		#return false
	#match operator_expression["operator"]:
		#"!":
			#if not operator_expression.has("right"):
				#return false
			#if typeof(operator_expression["right"]) != TYPE_DICTIONARY:
				#return false
		#"&":
			#if not operator_expression.has("left"):
				#return false
			#if typeof(operator_expression["left"]) != TYPE_DICTIONARY:
				#return false
		#"|", "||", "&&", ";":
			#if not operator_expression.has_all(["left", "right"]):
				#return false
			#if typeof(operator_expression["left"]) != TYPE_DICTIONARY:
				#return false
			#if typeof(operator_expression["right"]) != TYPE_DICTIONARY:
				#return false
	#
	#return true
#
#
#static func is_expression_valid(expression: Dictionary, error_info: bool = false, command_db: GDShellCommandDB = null) -> bool:
	#if expression.get("type") == "command":
		#return is_command_expression_valid(expression, error_info, command_db)
	#
	#if expression.get("type") == "operator":
		#if is_operator_expression_valid(expression, error_info) == false:
			#return false
		#if expression.has("left"):
			#if is_expression_valid(expression["left"], error_info, command_db) == false:
				#return false
		#if expression.has("right"):
			#if is_expression_valid(expression["right"], error_info, command_db) == false:
				#return false
	#
	#return true
