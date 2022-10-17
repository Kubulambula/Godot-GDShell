extends GDShellCommand


func _init():
	COMMAND_AUTO_ALIASES = {
		"unalias": "alias -r"
	}


func _main(params: Dictionary) -> Dictionary:
	var success: bool
	
	if not params["argv"].size() > 2:
		output("Not enough arguments")
		return {"error": 1, "error_string": "Not enough arguments"}
	
	if "-r" in params["argv"][1] or "--remove" in params["argv"][1]:
		success = _PARENT_PROCESS._PARENT_GDSHELL.command_db.remove_alias(params["argv"][2])
		if success:
			output("Alias '%s' removed" % params["argv"][2])
		return DEFAULT_COMMAND_PARAMS
	
	success = _PARENT_PROCESS._PARENT_GDSHELL.command_db.add_alias(params["argv"][1], params["argv"][2])
	if not success:
		output("Could not add alias '%s'" % params["argv"][1])
		return {"error": 1, "error_string": "Could not add alias"}
	
	output("Alias '%s' added" % params["argv"][1])
	return DEFAULT_COMMAND_RESULT
