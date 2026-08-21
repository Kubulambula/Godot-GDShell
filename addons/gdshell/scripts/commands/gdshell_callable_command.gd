@icon("res://addons/gdshell/icon.png")
class_name GDShellCallableCommand
extends GDShellCommand


var _callable: Callable
var _call_deferred: bool = false
var _manual: String = ""


func _init(callable: Callable) -> void:
	_callable = callable
	
	@warning_ignore("return_value_discarded")
	_can_execute() # Check for validity at initialization time, just for the error to show early


func _can_execute() -> bool:
	if _callable.is_valid():
		return true
	
	var reason: String
	if _callable.is_null():
		reason = "[GDShell] Callable has no target to call the method on"
	elif _callable.get_object() == null:
		reason = "[GDShell] Callable's target object has been freed"
	else:
		reason = "[GDShell] Callable's target has no method \"%s\"" % _callable.get_method()
	
	push_error(reason)
	return false


func execute(parameters: GDShellCommand.Parameters) -> GDShellCommand.Result:
	if not _can_execute():
		return null
	
	var target: Callable = _callable
	if _callable.get_argument_count() > 0:
		target = _callable.bind(parameters)
	
	if _call_deferred:
		target.call_deferred()
		return null
	
	return await target.call()


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
