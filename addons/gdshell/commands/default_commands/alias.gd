extends GDShellCommand


func _init():
	COMMAND_AUTO_ALIASES = {
		"unalias": "alias -r",
	}


func _main(argv: Array, data) -> CommandResult:
	var success: bool
	
	if not argv.size() > 2:
		output("Not enough arguments")
		return CommandResult.new(1, "Not enough arguments")
	
	if "-r" in argv[1] or "--remove" in argv[1]:
		_PARENT_COMMAND_RUNNER._PARENT_GDSHELL.command_db.remove_alias(argv[2])
		return CommandResult.new()
	
	_PARENT_COMMAND_RUNNER._PARENT_GDSHELL.command_db.add_alias(argv[1], argv[2])
	
#	output("Alias '%s' added" % argv[1])
	return CommandResult.new()


func _get_manual() -> String:
	return (
"""
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
""".format(
			{
				"COMMAND_NAME": COMMAND_NAME,
				"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
			}
		)
	)
