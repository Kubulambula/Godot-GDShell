@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandRunner
extends Node


class RunnerResult extends RefCounted:
	enum Status {
		OK,
		COMPILE_ERROR,
		VALIDATION_ERROR,
		RUNTIME_ERROR,
	}
	
	var status: Status
	var error_description: String
	var command_result: GDShellCommand.CommandResult
	var error_index: int
	var error_length: int
	
	
	func _init(_status: Status, _error_description: String, _command_result: GDShellCommand.CommandResult, _error_index: int, _error_length: int) -> void:
		status = _status
		error_description = _error_description
		command_result = _command_result
		error_index = _error_index
		error_length = _error_length


static func execute(compiled_expression: Dictionary, session: GDShellSession, pipe: GDShellCommand.CommandResult = null, in_background: bool = false) -> RunnerResult:
	return await _execute(compiled_expression, session, pipe, in_background)


static func _execute(compiled_expression: Dictionary, session: GDShellSession, pipe: GDShellCommand.CommandResult, in_background: bool) -> RunnerResult:
	match str(compiled_expression.get("type", "")):
		"command":
			return await _execute_command(compiled_expression, session, pipe, in_background)
		"operator":
			return await _execute_operator(compiled_expression, session, pipe, in_background)
		var unknown_type:
			return GDShellCommandRunner.RunnerResult.new(
				GDShellCommandRunner.RunnerResult.Status.RUNTIME_ERROR,
				"Ivalid or unknown expression type '%s'." % unknown_type,
				null,
				-1,
				-1,
			)


static func _execute_command(command_expression: Dictionary, session: GDShellSession, pipe: GDShellCommand.CommandResult, in_background: bool) -> RunnerResult:
	var command_name: String = str(command_expression.get("name", ""))
	var command_instance: GDShellCommand = session.command_db.get_gdshell_command_instance(command_name)
	if command_instance == null:
		@warning_ignore("unsafe_call_argument")
		return GDShellCommandRunner.RunnerResult.new(
			GDShellCommandRunner.RunnerResult.Status.RUNTIME_ERROR,
			"Could not instantiate command '%s'." % command_name,
			null,
			str(command_expression.get("index", -1)).to_int(),
			str(command_expression.get("length", -1)).to_int(),
		)
	
	# Node.name - for remote scene tree debugging
	command_instance.name = "GDShellCommand: %s %s" % [command_name, "(in background)" if in_background else ""]
	
	# Check command args presence and type
	var are_args_valid: Callable = func() -> bool:
		if not command_expression.has("args"):
			return false
		if typeof(command_expression["args"]) != TYPE_ARRAY:
			return false
		@warning_ignore("unsafe_method_access")
		return command_expression["args"].all(
			func(arg: Variant) -> bool:
				return typeof(arg) == TYPE_STRING
		)
	if not are_args_valid.call(command_expression):
		return GDShellCommandRunner.RunnerResult.new(
			GDShellCommandRunner.RunnerResult.Status.RUNTIME_ERROR,
			"Invalid command args '%s'." % str(command_expression["args"]),
			null,
			str(command_expression.get("index", -1)).to_int(),
			str(command_expression.get("length", -1)).to_int(),
		)
	@warning_ignore("unsafe_call_argument")
	var args: Array[String] = Array(command_expression["args"], TYPE_STRING, "", null)
	
	var command_result: GDShellCommand.CommandResult
	if in_background:
		# *** Call the _main() with black magic ***
		# We need to wait until _main() finishes. await is necessary because we do not know if _main() is coroutine
		# The wrapper lambda function is necessary so that this function continues and returns right away
		# so that any following non-background commands can be run before the backgroun command finishes.
		(func () -> void:
			session.add_child(command_instance, true)
			@warning_ignore("redundant_await", "unsafe_call_argument")
			await command_instance._main(args, pipe)
			command_instance.queue_free()
		).call()
		# Return generic OK CommandResult - background commands discard the result
		command_result = GDShellCommand.CommandResult.new()
	else:
		session.add_child(command_instance, true)
		@warning_ignore("redundant_await", "unsafe_call_argument")
		command_result = await command_instance._main(args, pipe)
		command_instance.queue_free()
	
	return GDShellCommandRunner.RunnerResult.new(
		GDShellCommandRunner.RunnerResult.Status.OK,
		"",
		command_result,
		-1,
		-1
	)


static func _execute_operator(operator_expression: Dictionary, session: GDShellSession, pipe: GDShellCommand.CommandResult, in_background: bool) -> RunnerResult:
	match operator_expression.get("operator"):
		"!":
			return await _execute_operator_not(operator_expression, session, pipe, in_background)
		"&":
			return await _execute_operator_background(operator_expression, session, pipe, in_background)
		"|":
			return await _execute_operator_pipe(operator_expression, session, pipe, in_background)
		"||":
			return await _execute_operator_or(operator_expression, session, pipe, in_background)
		"&&":
			return await _execute_operator_and(operator_expression, session, pipe, in_background)
		";":
			return await _execute_operator_sequence(operator_expression, session, pipe, in_background)
		var unknown_operator:
			@warning_ignore("unsafe_call_argument")
			return GDShellCommandRunner.RunnerResult.new(
				GDShellCommandRunner.RunnerResult.Status.RUNTIME_ERROR,
				"Unknown operator encountered '%s'." % str(unknown_operator),
				null,
				str(operator_expression.get("index", -1)).to_int(),
				str(operator_expression.get("length", -1)).to_int(),
			)


static func _execute_operator_not(operator_expression: Dictionary, session: GDShellSession, pipe: GDShellCommand.CommandResult, in_background: bool) -> RunnerResult:
	@warning_ignore("unsafe_call_argument")
	var right_operand_result: RunnerResult = await _execute(operator_expression["right"], session, pipe, in_background)
	if right_operand_result.status == OK:
		right_operand_result.command_result.err = FAILED if right_operand_result.command_result.err == OK else OK
	return right_operand_result


static func _execute_operator_background(operator_expression: Dictionary, session: GDShellSession, pipe: GDShellCommand.CommandResult, _in_background: bool) -> RunnerResult:
	@warning_ignore("unsafe_call_argument")
	return await _execute(operator_expression["left"], session, pipe, true)


static func _execute_operator_pipe(operator_expression: Dictionary, session: GDShellSession, pipe: GDShellCommand.CommandResult, in_background: bool) -> RunnerResult:
	@warning_ignore("unsafe_call_argument")
	var left_operand_result: RunnerResult = await _execute(operator_expression["left"], session, pipe, in_background)
	if left_operand_result.status != OK:
		return left_operand_result
	@warning_ignore("unsafe_call_argument")
	return await _execute(operator_expression["right"], session, left_operand_result.command_result, in_background)


static func _execute_operator_or(operator_expression: Dictionary, session: GDShellSession, pipe: GDShellCommand.CommandResult, in_background: bool) -> RunnerResult:
	@warning_ignore("unsafe_call_argument")
	var left_operand_result: RunnerResult = await _execute(operator_expression["left"], session, pipe, in_background)
	if left_operand_result.status != OK:
		return left_operand_result
	@warning_ignore("unsafe_call_argument")
	return await _execute(operator_expression["right"], session, null, in_background) if left_operand_result.command_result.err != OK else left_operand_result


static func _execute_operator_and(operator_expression: Dictionary, session: GDShellSession, pipe: GDShellCommand.CommandResult, in_background: bool) -> RunnerResult:
	@warning_ignore("unsafe_call_argument")
	var left_operand_result: RunnerResult = await _execute(operator_expression["left"], session, pipe, in_background)
	if left_operand_result.status != OK:
		return left_operand_result
	@warning_ignore("unsafe_call_argument")
	return await _execute(operator_expression["right"], session, null, in_background) if left_operand_result.command_result.err == OK else left_operand_result


static func _execute_operator_sequence(operator_expression: Dictionary, session: GDShellSession, pipe: GDShellCommand.CommandResult, in_background: bool) -> RunnerResult:
	@warning_ignore("unsafe_call_argument")
	var left_operand_result: RunnerResult = await _execute(operator_expression["left"], session, pipe, in_background)
	if left_operand_result.status != OK:
		return left_operand_result
	@warning_ignore("unsafe_call_argument")
	return await _execute(operator_expression["right"], session, null, in_background)
