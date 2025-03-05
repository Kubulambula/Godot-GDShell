@icon("res://addons/gdshell/icon.png")
#class_name GDShellCommandRunner
extends Node

var _background_commands: Array[GDShellCommand] = []




class RunnerResult extends RefCounted:
	enum Status {
		OK,
		COMPILE_ERROR,
		VALIDATION_ERROR,
		RUNTIME_ERROR,
	}
	
	var status: Status
	var error_description: String
	var result: GDShellCommand.CommandResult
	var error_index: int
	var error_length: int
	
	
	func _init(_status: Status, _error_description: String, _result: GDShellCommand.CommandResult, _error_index: int, _error_length: int) -> void:
		status = _status
		error_description = _error_description
		result = _result
		error_index = _error_index
		error_length = _error_length


func execute(expression: String, command_db: GDShellCommandDB) -> RunnerResult:
	var compiler_result: GDShellExpressionCompiler.CompilerResult = GDShellExpressionCompiler.compile(expression)
	if compiler_result.status != GDShellExpressionCompiler.CompilerResult.Status.OK:
		return RunnerResult.new(RunnerResult.Status.COMPILE_ERROR, compiler_result.error_description, null, -1, -1)
	
	return execute_compiled(compiler_result.result, command_db)


func execute_compiled(compiled_expression: Dictionary, command_db: GDShellCommandDB) -> RunnerResult:
	if not GDShellExpressionCompiler.is_expression_valid(compiled_expression, false, command_db):
		return RunnerResult.new(RunnerResult.Status.VALIDATION_ERROR, "invalid compiled expression", null, -1, -1)
	return _execute(compiled_expression, command_db)


func _execute(expression: Dictionary, command_db: GDShellCommandDB) -> RunnerResult:
	return null


func _execute_operator(operator_expression: Dictionary, command_db: GDShellCommandDB) -> RunnerResult:
	match operator_expression["operator"]:
		"!":
			var right_operand_result: RunnerResult = _execute(operator_expression["right"], command_db)
			if right_operand_result.status == OK:
				right_operand_result.result.err = FAILED if right_operand_result.result.err == OK else OK
			return right_operand_result
		"&":
			pass
		"|":
			pass
		"||":
			pass
		"&&":
			pass
		";":
			@warning_ignore("redundant_await")
			await _execute(operator_expression["left"], command_db)
			return await _execute(operator_expression["right"], command_db)
	
	return null


func _execute_command(command_expression: Dictionary, piped_data: Variant, command_db: GDShellCommandDB, in_background: bool = false) -> RunnerResult:
	# Create command
	var command: GDShellCommand = command_db.get_gdshell_command_instance(command_expression["name"])
	if command == null:
		return RunnerResult.new(RunnerResult.Status.RUNTIME_ERROR, "cannot create a command instance", null, -1, -1)
	# Setup command
	command.name = "GDShellCommand: " + command._get_command_name()
	add_child(command, true)
	if in_background:
		command.name += " (in background)"
		_background_commands.append(command)
	# Run command
	var command_result: GDShellCommand.CommandResult
	if in_background:
		command._main(command_expression["args"], piped_data)
		command_result = GDShellCommand.CommandResult.new()
	else:
		@warning_ignore("redundant_await") # We don't know if the user override will have await
		command_result = await command._main(command_expression["args"], piped_data)
	# TODO - does this work with both background and normal commands? Won't background commands be freed prematurely?
	# Cleanup command
	_background_commands.erase(command)
	command.queue_free()
	
	return RunnerResult.new(RunnerResult.Status.OK, "OK", command_result, -1, -1)
