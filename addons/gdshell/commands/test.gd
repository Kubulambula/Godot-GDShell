extends GDShellCommand


func _main(_argv: Array, _data: CommandResult) -> CommandResult:
	output("test")
	return CommandResult.new(0, "foobar", Vector2.ZERO)
