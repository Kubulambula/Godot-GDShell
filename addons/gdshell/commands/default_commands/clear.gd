extends GDShellCommand


func _init():
	COMMAND_AUTO_ALIASES = {
		"cls": "clear"
	}


func _main(_params: Dictionary) -> Dictionary:
	# Truly unbelieveable progrmming skills
	get_ui_handler_rich_text_label().clear()
	return DEFAULT_COMMAND_RESULT
