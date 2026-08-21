@icon("res://addons/gdshell/icon.png")
@abstract
class_name GDShellCommand
extends Node


@warning_ignore("unused_signal")
signal command_end


@abstract
func execute(parameters: Parameters) -> Result


@abstract
func get_manual() -> String


class Parameters extends RefCounted:
	var args: Array[String]
	var piped_data: Variant
	var parent_session: GDShellSession
	var is_in_background: bool
	
	
	func _init(args_: Array[String], piped_data_: Variant, parent_session_: GDShellSession, is_in_background_: bool) -> void:
		args = args_
		piped_data = piped_data_
		parent_session = parent_session_
		is_in_background = is_in_background_
	
	
	func _to_string() -> String:
		return "GDShellCommand.Result:"


class Result extends RefCounted:
	var data: Variant
	var err: Error
	var err_description: String
	
	
	func _init(result_data: Variant = null, error: Error = OK, error_description: String = "No description") -> void:
		data = result_data
		err = error
		err_description = error_description
	
	
	func _to_string() -> String:
		return "GDShellCommand.Result: data: %s, err: %s, err_description: \"%s\"" % [str(data), error_string(err), err_description]



#
#
#func input(_out: String = "") -> String:
	#return ""
	##return await _PARENT_SESSION._handle_input(self, out)
#
#
#func output(_out: Variant, _append_new_line: bool = true) -> void:
	#print(_out)
	#pass
	##_PARENT_SESSION._handle_output(str(out), append_new_line)
#
### Override this method to make the command name different from the default script name.
###
### [param script] is the [Script] of the [GDShellCommand] script that this method is in.[br]
### Because static method cannot access the instance methods, like [method Object.get_script] this is necessary,
### because this method has to be static so that retrieving the command name does not require instancing.
#static func _get_command_name(script: Script) -> String:
	#return script.resource_path.get_basename().get_file() if script != null else ""
#
#
### Override this method to set the command auto aliases.
###
### [param script] is the [Script] of the [GDShellCommand] script that this method is in.[br]
### Because static functions cannot access the instance methods, like [method Object.get_script] this is necessary,
### because this method has to be static so that retrieving the command aliases does not require instancing.
#static func _get_command_auto_aliases(_script: Script) -> Dictionary[String, String]:
	#return {}
#
#
### [param script] is the [Script] of the [GDShellCommand] script that this method is in.[br]
### Because static functions cannot access the instance methods, like [method Object.get_script] this is necessary,
### because this method uses [method _get_command_name] and [method _get_command_auto_aliases].[br]
### This method is intended to be accessed trough [GDShellCommandDB] via [method GDShellCommandDB.get_command_manual].
#static func _get_manual(script: Script) -> String:
	#return (
#"""
#[b]NAME[/b]
	#{COMMAND_NAME}
#
#[b]AUTO ALIASES[/b]
	#{COMMAND_AUTO_ALIASES}
#
#[b]NO MANUAL[/b]
	#-Override the [b]_get_manual()[/b] function for a custom manual page.
#""".format(
			#{
				#"COMMAND_NAME": _get_command_name(script),
				#"COMMAND_AUTO_ALIASES": _get_command_auto_aliases(script),
			#}
		#)
	#)
#
#
#static func _reverse_flag_option_dictionary(dictionary: Dictionary[String, Variant]) -> Dictionary[String, String]:
	#var reversed_dictionary: Dictionary[String, String] = {}
	#
	#var add_to_dictionary: Callable = func(key: String, value: String, dict: Dictionary[String, String]) -> bool:
		#if key in dict:
			#push_error("[GDShell] Flag or option '%s' used more than once." % key)
			#return false
		#dict[key] = value
		#return true
	#
	#for key: String in dictionary:
		#if typeof(dictionary[key]) == TYPE_ARRAY:
			#@warning_ignore("untyped_declaration")
			#for value in dictionary[key]:
				#if typeof(value) != TYPE_STRING:
					#push_error("[GDShell] Flag or option value of '%s' for key '%s' is not of 'String' type." % [str(value), key])
					#return {}
				#if not add_to_dictionary.call(value, key, reversed_dictionary):
					#return {}
		#elif typeof(dictionary[key]) == TYPE_STRING:
			#if not add_to_dictionary.call(dictionary[key], key, reversed_dictionary):
				#return {}
		#else:
			#push_error("[GDShell] Flag or option value of '%s' for key '%s' is not of 'String' type." % [str(dictionary[key]), key])
			#return {}
	#
	#return reversed_dictionary
#
#
#static func _find_intersecting_array_element(array1: Array[String], array2: Array[String]) -> String:
	#for element: String in array1:
		#if element in array2:
			#return element
	#return ""
#
#
#static func argv_parse(argv: Array[String], flags: Dictionary[String, Variant] = {}, options: Dictionary[String, Variant] = {}, convert_option_values_to_variant: bool = true) -> Dictionary:
	#if "_positional" in flags or "_positional" in options:
		#push_error("[GDShell] Cannot use reserved key '_positional', for a flag or option.")
		#return {}
	#
	#var intersecting_element: String = _find_intersecting_array_element(flags.keys(), options.keys())
	#if intersecting_element != "":
		#push_error("[GDShell] A flag and an option share the same name '%s'." % intersecting_element)
		#return {}
	#
	#var reversed_flags: Dictionary[String, String] = _reverse_flag_option_dictionary(flags)
	#var reversed_options: Dictionary[String, String] = _reverse_flag_option_dictionary(options)
	#intersecting_element = _find_intersecting_array_element(reversed_flags.keys(), reversed_options.keys())
	#if intersecting_element != "":
		#push_error("[GDShell] A flag and an option share the same value '%s'." % intersecting_element)
		#return {}
	#
	#var flags_options_and_positional: Dictionary[String, Variant] = {
		#"_positional": []
	#}
	#
	#var add_option: Callable = func(option: String, option_value: String) -> void:
		#if convert_option_values_to_variant:
			#var converted_option_value: Variant = str_to_var(option_value)
			#if converted_option_value == null and option_value != "null":
				#converted_option_value = option_value
			#flags_options_and_positional[reversed_options[option]] = converted_option_value
		#else:
			#flags_options_and_positional[reversed_options[option]] = option_value
	#
	#var current_argv_index: int = argv.size() - 1
	#while current_argv_index >= 0:
		#if argv[current_argv_index] in reversed_flags: # Flag
			#flags_options_and_positional[reversed_flags[argv[current_argv_index]]] = true
			#current_argv_index -= 1
			#continue
		#if argv[current_argv_index] in reversed_options: # Option with no value
			#flags_options_and_positional[reversed_options[argv[current_argv_index]]] = null
			#current_argv_index -= 1
			#continue
		#if argv[current_argv_index - 1] in reversed_options and current_argv_index > 0: # Option with value
			#add_option.call(argv[current_argv_index - 1], argv[current_argv_index])
			#current_argv_index -= 2
			#continue
		#var arg_slices: PackedStringArray = argv[current_argv_index].split("=", true, 1)
		#if arg_slices.size() == 2 and arg_slices[0] in reversed_options: # Option with value, delimited by "="
			#add_option.call(arg_slices[0], arg_slices[1])
			#current_argv_index -= 1
			#continue
		## Positional argument
		#@warning_ignore("unsafe_method_access")
		#flags_options_and_positional["_positional"].push_back(argv[current_argv_index])
		#current_argv_index -= 1
		#continue
	#
	## Reverse positionals, because they are added last to first
	#@warning_ignore("unsafe_method_access")
	#flags_options_and_positional["_positional"].reverse()
	## For missing flags, add false value
	#for flag: String in flags:
		#if flag not in flags_options_and_positional:
			#flags_options_and_positional[flag] = false
	#
	#return flags_options_and_positional
#
#
### @deprecated
#static func argv_parse_options(argv: Array[String], strip_name_dashes: bool = false, next_arg_as_value: bool = false) -> Dictionary:
	#var options: Dictionary = {}
	#for i: int in argv.size():
		#if argv[i][0] == "-":
			#var option_name: String = argv[i].get_slice("=", 0).lstrip("-") if strip_name_dashes else argv[i].get_slice("=", 0)
			#var option_value: String = argv[i].get_slice("=", 1) if "=" in argv[i] else ""
			#if (
					#option_value.length() == 0 and next_arg_as_value and not "=" in argv[i]
					#and i+1 < argv.size() and argv[i+1][0] != "-"
			#):
				#option_value = argv[i+1]
			#
			#options[option_name] = option_value
	#
	#return options
