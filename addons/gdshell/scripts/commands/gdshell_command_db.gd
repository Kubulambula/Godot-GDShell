@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandDB
extends RefCounted




func register_command(name_: String, command: GDShellCommand) -> void:
	if command is GDShellCallableCommand:
		register_callable_command(name_, command as GDShellCallableCommand)
	elif command is GDShellScriptCommand:
		register_script_command(name_, command as GDShellScriptCommand)


func register_callable_command(name_: String, command: GDShellCallableCommand) -> void:
	pass


func register_script_command(name_: String, command: GDShellScriptCommand) -> void:
	@warning_ignore("unsafe_cast")
	register_script_command_script(name_, command.get_script() as Script)


func register_script_command_script(name_: String, command_script: Script) -> void:
	pass
