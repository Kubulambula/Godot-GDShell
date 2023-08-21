@icon("res://addons/gdshell/icon.png")
class_name GDShellCommandDB
extends RefCounted


var _commands: Dictionary = {}
var _aliases: Dictionary = {}


## Returns the command name on success or empty String on failure
func add_command(path: String) -> String:
	var name_and_auto_aliases: Dictionary = GDShellCommandDB.get_command_name_and_auto_aliases(path)
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


func get_command_path(command_name: String) -> String:
	return _commands.get(command_name, "")


func get_all_command_names() -> Array[String]:
	# This is required as GD4 doesn't allow upcast from Array to Array[String]
	# see: https://www.reddit.com/r/godot/comments/10rqh9g/problem_with_typed_arrays_since_40_beta_17/
	var names: Array[String] = []
	names.assign(_commands.keys())
	return names


func add_alias(alias: String, command: String) -> void:
	_aliases[alias] = command


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
	return _get_file_paths_in_directory(path, recursive).filter(
		func(file_path):
			return is_file_gdshell_command(file_path)
	)


static func is_file_gdshell_command(path: String) -> bool:
	var res: Resource = ResourceLoader.load(path, "GDScript")
	if not res is GDScript:
		return false
	
	var script: Object = (res as GDScript).new()
	if not script is GDShellCommand:
		return false
	
	return true


static func get_command_name_and_auto_aliases(path: String) -> Dictionary:
	var out: Dictionary = {"name": "", "aliases": []}
	var res: Resource = ResourceLoader.load(path, "GDScript")
	if not res is GDScript:
		return out
	
	var script: Object = (res as GDScript).new()
	if not script is GDShellCommand:
		return out
	
	out["name"] = (script as GDShellCommand).COMMAND_NAME
	out["aliases"] = (script as GDShellCommand).COMMAND_AUTO_ALIASES
	return out
