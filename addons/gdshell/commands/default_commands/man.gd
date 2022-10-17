extends GDShellCommand


func _init():
	COMMAND_MANUAL = ""
	COMMAND_AUTO_ALIASES = {
		"manual": "man",
		"help": "man",
	}

func _main(params: Dictionary) -> Dictionary:
	if not params["argv"].size() > 1:
		output("not enough args")
		return {"error": 1, "error_string": "Not enough arguments"}
	
	var command_db: GDShellCommandDB = _PARENT_PROCESS._PARENT_GDSHELL.command_db
	
	var command_name: String = params["argv"][1]
	while true:
		if not command_name in command_db._aliases:
			break
		command_name = command_db._aliases[command_name].split(" ", false)[0]
	
	if not command_name in command_db._commands:
		output("not found")
		return {"error": 2, "error_string": "Command not found"}
	
	# It's checked if the command in in command_db, co it's ok unless someone inserts data manually
	@warning_ignore(unsafe_cast) 
	var command: GDShellCommand = ResourceLoader.load(
			command_db.get_command_path(command_name), "GDScript").new() as GDShellCommand
	var manual: String = command.COMMAND_MANUAL if command else ""
	command.queue_free()
	
	if not "-s" in params["argv"] or "-silent" in params["argv"]:
		output(manual)
	
	return {"data": manual}
