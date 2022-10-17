extends GDShellCommand


const TRUE: Dictionary = {"error": 0, "data": "true"}
const FALSE: Dictionary = {"error": 1, "error_string": "This is not an error, but false.", "data": "false"}


func _init():
	COMMAND_AUTO_ALIASES = {
		"true": "bool -t",
		"false": "bool -f",
		"maybe": "bool -r"
	}


func _main(params: Dictionary) -> Dictionary:
	if not params["argv"].size() > 1:
		return TRUE
		
	match params["argv"][1]:
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
				"error_string": "Parameter '%s' not recognized" % params["argv"][1],
				"data": null,
			}
