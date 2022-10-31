extends GDShellCommand


func _main(params: Dictionary) -> Dictionary:
	var out: String = ""
	
	if params["data"] != null:
		out = str(params["data"])
	elif params["argv"].size() > 1:
		output(" ".join(params["argv"].slice(1)))
	
	if not out.is_empty():
		output(out)
	
	@warning_ignore(incompatible_ternary)
	return {"data": null if out.is_empty() else out}


func _get_manual() -> String:
	return """
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
""".format({
	"COMMAND_NAME": COMMAND_NAME,
	"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
})
