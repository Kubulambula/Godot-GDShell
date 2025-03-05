extends GDShellCommand


func _main(_argv: Array, _data) -> CommandResult:
	output("Autorun here...")
	#var x = await input("gimme text: ") # TODO input() blocks all following input
	#output("hi %s" % x)
	#execute("echo hi")
#	execute("gdfetch")
	return CommandResult.new()
