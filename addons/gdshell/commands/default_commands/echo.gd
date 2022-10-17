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
