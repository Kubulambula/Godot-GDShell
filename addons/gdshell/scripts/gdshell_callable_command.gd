@icon("res://addons/gdshell/icon.png")
class_name GDShellCallableCommand
extends Node


var _callable: Callable
var _call_deferred: bool = false
var _manual: String = ""


func _init(callable: Callable) -> void:
	_callable = callable


func execute(parameters: GDShellCommand.Parameters) -> GDShellCommand.Result:
	if _call_deferred:
		_callable.call_deferred(parameters)
		return GDShellCommand.Result.new()
	else:
		return _callable.call(parameters)


static func from(callable: Callable) -> GDShellCallableCommand:
	return GDShellCallableCommand.new(callable)


func with_name(command_name: StringName)-> GDShellCallableCommand:
	# TODO
	return self


func with_alias(alias: Dictionary[StringName, String]) -> GDShellCallableCommand:
	# TODO
	return self


func with_manual(manual: String) -> GDShellCallableCommand:
	_manual = manual
	return self


func as_deffered(call_deffered: bool = true) -> GDShellCallableCommand:
	_call_deferred = call_deffered
	return self


func get_manual() -> String:
	return _manual
