@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandDB
extends RefCounted


var _commands: Dictionary = {}
var _aliases: Dictionary = {}


func has_command(command: String) -> bool:
	return command in _commands


## Returns the command name on success or empty String on failure
func add_command(path: String) -> String:
	var name_and_auto_aliases: Dictionary = GDShellCommandDB.get_file_command_name_and_auto_aliases(path)
	if name_and_auto_aliases.is_empty():
		return ""
	_commands[name_and_auto_aliases["name"]] = path
	_aliases.merge(name_and_auto_aliases["aliases"], true)
	return name_and_auto_aliases["name"]


func add_commands_in_directory(path: String, recursive: bool = true) -> void:
	for command in GDShellCommandDB.get_command_file_paths_in_directory(path, recursive):
		@warning_ignore("return_value_discarded")
		add_command(command)


func remove_command(command_name: String) -> void:
	@warning_ignore("return_value_discarded")
	_commands.erase(command_name)


## Returns command path if the command is registered. Returns empty String if not.
func get_command_path(command_name: String) -> String:
	return _commands.get(command_name, "")


func get_all_command_names() -> Array[String]:
	# This is required as GD4 doesn't allow upcast from Array to Array[String]
	# see: https://www.reddit.com/r/godot/comments/10rqh9g/problem_with_typed_arrays_since_40_beta_17/
	var names: Array[String] = []
	names.assign(_commands.keys())
	return names


func get_all_commands() -> Dictionary:
	return _commands.duplicate()


func has_alias(alias: String) -> bool:
	return alias in _aliases


func add_alias(alias: String, command: String) -> void:
	_aliases[alias] = command


func get_alias_value(alias: String) -> String:
	return _aliases.get(alias, "")


func remove_alias(alias: String) -> void:
	@warning_ignore("return_value_discarded")
	_aliases.erase(alias)


func get_all_aliases() -> Dictionary:
	return _aliases.duplicate()


static func _get_file_paths_in_directory(path: String, recursive: bool = true) -> Array[String]:
	var paths: Array[String] = []
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		push_error("[GDShell] Cannot get file paths in directory \"%s\" - %s." % [path, DirAccess.get_open_error()])
		return []
	
	var err: int = dir.list_dir_begin()
	if err:
		push_error("[GDShell] Cannot get file paths in directory \"%s\" - %s." % [path, error_string(err)])
		return []
	path = dir.get_next()
	while path:
		if dir.current_is_dir():
			if recursive:
				paths.append_array(_get_file_paths_in_directory(dir.get_current_dir().path_join(path), true))
		else:
			paths.append(dir.get_current_dir().path_join(path))
		path = dir.get_next()
	dir.list_dir_end()
	
	return paths


static func get_command_file_paths_in_directory(path: String, recursive: bool = true) -> Array[String]:
	return _get_file_paths_in_directory(path, recursive).filter(GDShellCommandDB.is_file_gdshell_command)


static func is_file_gdshell_command(path: String) -> bool:
	var res: Resource = ResourceLoader.load(path, "GDScript")
	if not res is GDScript:
		return false
	return _is_script_gdshell_command(res as GDScript)


static func _is_script_gdshell_command(script: Script) -> bool:
	# HACK:
	# This is super error prone. If the name of GDShellCommand script ever changes, this breaks.
	# I haven't found or figured out a better workaround so this is just to make it work.
	return script.get_script_property_list().any(
		func(property: Dictionary) -> bool:
			return str(property["name"]) == "gdshell_command.gd"
	)


func get_command_name_and_auto_aliases(command: String) -> Dictionary:
	return (
		GDShellCommandDB.get_file_command_name_and_auto_aliases(_commands[command]) if command in _commands
		else {"name": "", "aliases": []}
	)


static func get_file_command_name_and_auto_aliases(path: String) -> Dictionary:
	var out: Dictionary = {"name": "", "aliases": []}
	var command: GDShellCommand = get_file_gdshell_command_instance(path)
	if command == null:
		return out
	out["name"] = command.COMMAND_NAME
	out["aliases"] = command.COMMAND_AUTO_ALIASES
	return out


# This is a if monster, but it just checks if the command really exists
func get_gdshell_command_instance(command_name: String) -> GDShellCommand:
	var command_script_path: String = get_command_path(command_name)
	if command_script_path.is_empty():
		return null
	return GDShellCommandDB.get_file_gdshell_command_instance(command_script_path)


static func get_file_gdshell_command_instance(path: String) -> GDShellCommand:
	if not is_file_gdshell_command(path):
		return null
	
	var command_script: Resource = ResourceLoader.load(path, "GDScript", ResourceLoader.CACHE_MODE_REUSE)
	if command_script == null:
		return null
	
	return (command_script as GDScript).new() as GDShellCommand
