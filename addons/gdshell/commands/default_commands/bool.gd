extends GDShellCommand


const TRUE: Dictionary = {
	"error": 0,
	"data": "true",
}
const FALSE: Dictionary = {
	"error": 1,
	"error_string": "This is not an error, but false.",
	"data": "false",
}


func _init():
	COMMAND_AUTO_ALIASES = {
		"true": "bool -t",
		"false": "bool -f",
		"random": "bool -r",
	}


func _main(argv: Array, data) -> Dictionary:
	if not argv.size() > 1:
		return TRUE
	
	match argv[1]:
		"-t", "--true":
			return TRUE
		"-f", "--false":
			return FALSE
		"-r", "--random":
			randomize()
			return TRUE if randi() % 2 else FALSE
		_:
			return {
				"error": ERR_INVALID_PARAMETER,
				"error_string": "Parameter '%s' not recognized" % argv[1],
				"data": null,
			}


func _get_manual() -> String:
	return (
"""
[b]NAME[/b]
	{COMMAND_NAME}

[b]AUTO ALIASES[/b]
	{COMMAND_AUTO_ALIASES}

[b]SYNOPSIS[/b]
	bool [OPTION]

[b]DESCRIPTION[/b]
	Returns an empty result with 0 or 1 as an error. Can be used as constant in command chains.
	
	[b]-t, --true[/b]
		Returns 0 as an error (success)
	
	[b]-f, --false[/b]
		Returns 1 as an error (failed)
	
	[b]-r, --random[/b]
		Randomly returns 0 or 1 as an error

[b]EXAMPLES[/b]
	[i]bool -t && echo "true" || echo "false"[/i]
		-Prints "true"
		 Same as: true && echo "true" || echo "false"
	
	[i]bool -f && echo "true" || echo "false"[/i]
		-Prints "false"
		 Same as: false && echo "true" || echo "false"
	
	[i]bool -r && echo "true" || echo "false"[/i]
		-Prints "true" or "false" randomly
		 Same as: random && echo "true" || echo "false"
""".format(
			{
				"COMMAND_NAME": COMMAND_NAME,
				"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
			}
		)
	)
