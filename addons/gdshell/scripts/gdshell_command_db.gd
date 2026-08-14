@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandDB
extends RefCounted


var _commands: Dictionary[String, Script] = {}
var _aliases: Dictionary[String, String] = {}


## Returns the command name on success or empty [String] on failure.
func add_command_from_script(script: Script) -> String:
	if script == null:
		push_error("[GDShell] Cannot add an empty Script as a command.")
		return ""
	
	if not is_script_gdshell_command(script):
		push_error("[GDShell] Cannot add Script as a command. Script must inherit from GDShellCommand. Command file: '%s'" % script.resource_path)
		return ""
	
	var name: String = get_name_from_gdshell_command_script(script)
	var auto_aliases: Dictionary[String, String] = get_auto_aliases_from_gdshell_command_script(script)
	if name.is_empty():
		push_error("[GDShell] Cannot add a GDShellCommand without a name. Override _get_command_name() method to set a the command name. Command file: '%s'" % script.resource_path)
		return ""
	
	_commands[name] = script
	_aliases.merge(auto_aliases, true)
	return name


## Returns the command name on success or empty [String] on failure.
func add_command_from_file(file: String) -> String:
	var script: Script = get_command_script_from_file(file)
	if script == null:
		push_error("[GDShell] Cannot add file '%s' as a command. Check if the file exists and the script inherits from GDShellCommand." % file)
		return ""
	return add_command_from_script(script)


func add_commands_from_directory(directory: String, recursive: bool = true) -> void:
	for command_file_path: String in GDShellCommandDB.get_gdshell_command_file_paths_in_directory(directory, recursive):
		@warning_ignore("return_value_discarded")
		add_command_from_file(command_file_path)


func remove_command(command_name: String) -> bool:
	return _commands.erase(command_name)


func has_command(command_name: String) -> bool:
	return command_name in _commands


func get_all_command_names() -> Array[String]:
	var names: Array[String] = []
	names.assign(_commands.keys())
	return names


## Returns command [Script] if the command is registered. Returns null if not.
func get_command_script(command_name: String) -> Script:
	return _commands.get(command_name, null)


## Returns command path if the command is registered. Returns empty String if not.
func get_command_path(command_name: String) -> String:
	var script: Script = get_command_script(command_name)
	return "" if script == null else script.resource_path


func get_all_commands_with_paths() -> Dictionary[String, String]:
	return _commands.duplicate()


func add_alias(alias: String, alias_value: String) -> void:
	_aliases[alias] = alias_value


func remove_alias(alias: String) -> bool:
	return _aliases.erase(alias)


func has_alias(alias: String) -> bool:
	return alias in _aliases


## Returns alias value if the alias is registered. Returns empty String if not.
func get_alias_value(alias: String) -> String:
	return _aliases.get(alias, "")


func get_all_aliases_with_values() -> Dictionary:
	return _aliases.duplicate()


static func _get_file_paths_in_directory(path: String, recursive: bool = true) -> Array[String]:
	var paths: Array[String] = []
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		push_error("[GDShell] Cannot get file paths in directory \"%s\" - %s." % [path, error_string(DirAccess.get_open_error())])
		return []
	
	var err: int = dir.list_dir_begin()
	if err:
		push_error("[GDShell] Cannot get file paths in directory \"%s\" - %s." % [path, error_string(err)])
		return []
	
	path = dir.get_next()
	while not path.is_empty():
		if dir.current_is_dir():
			if recursive:
				paths.append_array(_get_file_paths_in_directory(dir.get_current_dir().path_join(path), true))
		else:
			paths.append(dir.get_current_dir().path_join(path))
		path = dir.get_next()
	dir.list_dir_end()
	
	return paths


static func get_gdshell_command_file_paths_in_directory(path: String, recursive: bool = true) -> Array[String]:
	return _get_file_paths_in_directory(path, recursive).filter(is_file_gdshell_command)


static func is_script_gdshell_command(script: Script) -> bool:
	return _is_script_child_class_of(script, &"GDShellCommand")


static func is_file_gdshell_command(file: String) -> bool:
	return is_script_gdshell_command(get_command_script_from_file(file))


## Crawls through the whole [param script]s parent classes to see if it inheriths from [param parent_class_name].[br]
## Functions similarly as [code]script.new() is ParentClass[/code], but does not need or create an instance of the script to check the class.[br]
## [param parent_class_name] is checked against the class name associated with the script via [method Script.get_global_name].[br]
## When [param script] is [code]null[/code], always returns [code]false[/code].
##
##
## [codeblock]
## var gdscript_command = load("res://path/to/your/command.gd") # instance of Script class
##
## print(gdscript_command.new() is GDScriptCommand) # Checks if the objects script inherits GDScriptCommand
## print(_is_script_gdshell_command(gdscript_command, "GDScriptCommand")) # Same as above without instancing
##[/codeblock]
static func _is_script_child_class_of(script: Script, parent_class_name: StringName) -> bool:
	while script != null:
		if script.get_global_name() == parent_class_name:
			return true
		script = script.get_base_script()
	return false


static func get_name_from_gdshell_command_script(script: Script) -> String:
	if not is_script_gdshell_command(script):
		return ""
	@warning_ignore("unsafe_method_access")
	return script._get_command_name(script)


static func get_auto_aliases_from_gdshell_command_script(script: Script) -> Dictionary[String, String]:
	if not is_script_gdshell_command(script):
		return {}
	@warning_ignore("unsafe_method_access")
	return script._get_command_auto_aliases(script)


func get_manual_from_gdshell_command_script(script: Script) -> String:
	if not is_script_gdshell_command(script):
		return ""
	@warning_ignore("unsafe_method_access")
	return script._get_manual(script)


static func get_command_script_from_file(file: String) -> Script:
	if not ResourceLoader.exists(file, "GDScript"):
		return null
	var resource: Resource = ResourceLoader.load(file, "GDScript")
	return resource as Script if resource is Script else null


static func get_gdshell_command_instance_from_script(script: Script) -> GDShellCommand:
	if not is_script_gdshell_command(script):
		return null
	@warning_ignore("unsafe_cast")
	return (script as GDScript).new() as GDShellCommand


func get_gdshell_command_instance(command_name: String) -> GDShellCommand:
	if not _commands.has(command_name):
		return null
	return get_gdshell_command_instance_from_script(_commands[command_name])
