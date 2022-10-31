extends GDShellCommand


func _init():
	COMMAND_AUTO_ALIASES = {
		"manual": "man",
		"help": "man",
	}


func _main(params: Dictionary) -> Dictionary:
	if not params["argv"].size() > 1:
		output("What manual page do you want?\nFor example, try '%s %s'" % [COMMAND_NAME, COMMAND_NAME])
		return DEFAULT_COMMAND_RESULT
	
	var command_db: GDShellCommandDB = _PARENT_PROCESS._PARENT_GDSHELL.command_db
	
	var command_name: String = params["argv"][1]
	while true:
		if not command_name in command_db._aliases:
			break
		command_name = command_db._aliases[command_name].split(" ", false)[0]
	
	if not command_name in command_db._commands:
		output("Command not found")
		return {"error": 2, "error_string": "Command not found"}
	
	# It's checked if the command in in command_db, co it's ok unless someone inserts data manually
	@warning_ignore(unsafe_cast) 
	var command: GDShellCommand = ResourceLoader.load(
			command_db.get_command_path(command_name), "GDScript").new() as GDShellCommand
	var manual: String = command._get_manual() if command else ""
	command.queue_free()
	
	if not "-s" in params["argv"] or "-silent" in params["argv"]:
		var line: int = get_ui_handler_rich_text_label().get_line_count()
		output(manual)
		get_ui_handler_rich_text_label().scroll_to_line(line)
	
	return {"data": manual}


func _get_manual() -> String:
	return """
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
""".format({
	"COMMAND_NAME": COMMAND_NAME,
	"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
})
