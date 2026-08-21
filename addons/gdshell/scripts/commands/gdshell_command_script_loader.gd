@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandScriptLoader
extends RefCounted


## Crawls through the whole [param script]s parent classes to see if it inheriths from [param base_script].[br]
## Functions similarly as [code]script.new() is ParentClass[/code], but does not need or create an instance of the script to check the class.[br]
## [param script] is checked against the [param base_script] by the class name associated with the scripts via [method Script.get_global_name].[br]
##
## [codeblock]
## var command = load("res://path/to/your/custom_command.gd") # instance of Script a class (Resource)
## var command = CustomCommand # Same as above, if registered via "class_name CustomCommand"
##
## print(gdscript_command.new() is GDScriptCommand) # Checks if the Script inherits GDScriptCommand via its instance
## print(_is_script_gdshell_command(gdscript_command, GDScriptCommand)) # Same as above without instancing
##[/codeblock]
static func _is_script_child_class_of(script: Script, base_script: Script) -> bool:
	if base_script == null:
		return false
	
	while script != null:
		if script.get_global_name() == base_script.get_global_name():
			return true
		script = script.get_base_script()
	
	return false


static func is_script_gdshell_command(script: Script) -> bool:
	return _is_script_child_class_of(script, GDShellCommand)


static func get_command_instance_from_script(script: Script) -> GDShellCommand:
	if not is_script_gdshell_command(script):
		return null
	@warning_ignore("unsafe_cast") # This might break with C# support
	return (script as GDScript).new() as GDShellCommand
