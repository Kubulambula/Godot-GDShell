extends GDShellCommand


func _main(argv: Array, data) -> CommandResult:
	var out: String = ""
	
	if data != null:
		out = str(data)
	elif argv.size() > 1:
		output(" ".join(argv.slice(1)))
	
	if not out.is_empty():
		output(out)
	
	@warning_ignore("incompatible_ternary")
	return CommandResult.new(OK, "", null if out.is_empty() else out)


static func _get_command_name() -> StringName:
	return &"echo"


static func _get_manual() -> String:
	return (
"""
[b]NAME[/b]
	{COMMAND_NAME}

[b]AUTO ALIASES[/b]
	{COMMAND_AUTO_ALIASES}

SYNOPSIS
	echo [STRING]

[b]DESCRIPTION[/b]
	Prints the arguments to the console
	If multiple arguments are given, they will printed together separated by spaces

[b]EXAMPLES[/b]
	[i]echo Hello World[/i]
		-Prints Hello World!
	
	[i]echo "Hello 1" World![/i]
		 -Prints Hello 1 World!
""".format(
			{
				"COMMAND_NAME": _get_command_name(),
				"COMMAND_AUTO_ALIASES": _get_command_auto_aliases(),
			}
		)
	)
