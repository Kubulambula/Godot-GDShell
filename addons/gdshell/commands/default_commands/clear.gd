extends GDShellCommand


func _main(_argv: Array, _data) -> CommandResult:
	# Truly unbelieveable programming skills
	get_ui_handler_rich_text_label().clear()
	return CommandResult.new()


func _get_command_auto_aliases():
	return {
		"cls": "clear",
	}


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
				"COMMAND_NAME": _get_command_name(),
				"COMMAND_AUTO_ALIASES": _get_command_auto_aliases(),
			}
		)
	)
