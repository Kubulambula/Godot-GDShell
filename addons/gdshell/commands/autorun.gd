extends GDShellCommand

#
#static func _get_command_name(script: Script) -> StringName:
	#return &"reeeeeee"
var x

func _main(_argv: Array, _data: CommandResult) -> CommandResult:
	output("Autorun here...")
	#printerr("working")
	#output(_data)
	#var x = await input("gimme text: ") # TODO input() blocks all following input
	#output("hi %s" % x)
	#execute("echo hi")
#	execute("gdfetch")
	#x = _argv[0]
	#await get_tree().create_timer(.5).timeout
	printerr("done")
	return CommandResult.new(FAILED, "foobar", Vector2.ZERO)


func _process(delta: float) -> void:
	print("running ")
