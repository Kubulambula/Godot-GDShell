@icon("res://addons/gdshell/icon.png")
class_name GDShellCallableCommand
extends Node


var callable: Callable


func _init(callable: Callable = func() -> Object: return null) -> void:
	self.callable = callable


#func exe
