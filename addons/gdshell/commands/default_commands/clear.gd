extends GDShellCommand


func _init():
	COMMAND_AUTO_ALIASES = {
		"cls": "clear",
	}


func _main(_argv: Array, _data) -> Dictionary:
	# Truly unbelieveable programming skills
	get_ui_handler_rich_text_label().clear()
	return DEFAULT_COMMAND_RESULT


func _get_manual() -> String:
	return (
"""
[b]NAME[/b]
	{COMMAND_NAME}

[b]AUTO ALIASES[/b]
	{COMMAND_AUTO_ALIASES}

[b]DESCRIPTION[/b]
	Clears the console window

[b]EXAMPLES[/b]
	[i]clear[/i]
		-Clears the console
	
	[i]cls[/i]
		-Same as [i]clear[/i]
""".format(
			{
				"COMMAND_NAME": COMMAND_NAME,
				"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
			}
		)
	)
