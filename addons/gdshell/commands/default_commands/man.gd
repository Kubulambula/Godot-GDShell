extends GDShellCommand


const LIST_FLAGS: Array[String] = ["l", "L", "list", "LIST"]
const SILENT_FLAGS: Array[String] = ["s", "S", "silent", "SILENT"]


func _init():
	COMMAND_AUTO_ALIASES = {
		"manual": "man",
		"help": "man",
	}


func _main(argv: Array, _data) -> Dictionary:
	if not argv.size() > 1:
		output("What manual page do you want? For example, try '[b]man man[/b]'\nTo see the list of all commands run '[b]man --list[/b]'")
		return DEFAULT_COMMAND_RESULT
	
	var options: Dictionary = GDShellCommand.argv_parse_options(argv, true, false)
	
	if LIST_FLAGS.any(func(option): return option in options): # If any LIST_FLAG is in options
		output("[b][color=AQUAMARINE]Available GDShell commands:[/color][/b]")
		for command_name in _PARENT_PROCESS._PARENT_GDSHELL.command_db.get_all_command_names():
			output("[color=BISQUE]%s[/color]" % command_name)
	
	if not argv.size() > options.keys().size() + 1:
		return DEFAULT_COMMAND_RESULT
	
	var manual: String = ""
	for i in range(1, argv.size()): # first non-option arg
		if not (argv[i] as String).begins_with("-"):
			manual = get_command_manual(argv[i])
			break
	
	if manual.is_empty():
		return {"error": 1, "error_string": "No manual", "data": null}
	
	if not SILENT_FLAGS.any(func(option): return option in options): # If NOT any LIST_FLAG is in options
		var line: int = get_ui_handler_rich_text_label().get_line_count()
		output(manual)
		get_ui_handler_rich_text_label().call_deferred(&"scroll_to_line", line)
	return {"data": manual}


func get_command_manual(command_name: String) -> String:
	var command_db: GDShellCommandDB = _PARENT_PROCESS._PARENT_GDSHELL.command_db
	# unalias the name
	while true:
		if not command_name in command_db._aliases:
			break
		command_name = command_db._aliases[command_name].split(" ", false)[0]
	
	if not command_name in command_db._commands:
		output("Command '%s' not found" % command_name)
		return ""
	
	# It's checked if the command is in command_db, co it's ok unless someone inserts data manually
	@warning_ignore("unsafe_cast") 
	var command: GDShellCommand = (
		ResourceLoader.load(command_db.get_command_path(command_name), "GDScript").new() as GDShellCommand
	)
	
	var manual: String = command._get_manual() if command else ""
	command.queue_free()
	
	return manual


func _get_manual() -> String:
	return (
"""
[b]NAME[/b]
	{COMMAND_NAME}

[b]AUTO ALIASES[/b]
	{COMMAND_AUTO_ALIASES}

[b]SYNOPSIS[/b]
	man [COMMAND]

[b]DESCRIPTION[/b]
	Prints the manual of the given COMMAND.
	
[b]EXAMPLES[/b]
	[i]man echo[/i]
		-Prints the manual for the [i]echo[/i] command
	
	[i]man man[/i]
		-Prints the manual for the [i]man[/i] command
""".format(
			{
				"COMMAND_NAME": COMMAND_NAME,
				"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
			}
		)
	)
