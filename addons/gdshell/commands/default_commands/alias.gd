extends GDShellCommand


func _init():
	COMMAND_AUTO_ALIASES = {
		"unalias": "alias -r",
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


func _get_manual() -> String:
	return """
[b]NAME[/b]
	{COMMAND_NAME}

[b]AUTO ALIASES[/b]
	{COMMAND_AUTO_ALIASES}

[b]SYNOPSIS[/b]
	alias [NEW ALIAS] [NEW ALIAS VALUE]
	alias -r [ALIAS NAME TO REMOVE]
	unalias [ALIAS NAME TO REMOVE]

[b]DESCRIPTION[/b]
	Create / remove an alias.
	Aliases allow a string to be substituted for another when it is used as the first word of a command.
	
	[b]-r, --remove[/b]
		remove alias

[b]EXAMPLES[/b]
	[i]alias print echo[/i]
		-Create alias [i]print[/i] for [i]echo[/i].
		 Print "Hello World!" will be substituted to echo "Hello World!"
	
	[i]alias -r print[/i]
		-Removes [i]print[/i] alias 
		 Print "Hello World!" will no longer will be substituted to echo "Hello World!"
	
	[i]unalias print[/i]
		-Same as [i]alias -r print[/i]
""".format({
	"COMMAND_NAME": COMMAND_NAME,
	"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
})
