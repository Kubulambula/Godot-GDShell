@icon("res://addons/gdshell/icon.png")
@abstract
class_name GDShellScriptCommand
extends GDShellCommand


@abstract
func _main(parameters: Parameters) -> Result


func execute(parameters: Parameters) -> Result:
	return _main(parameters)
