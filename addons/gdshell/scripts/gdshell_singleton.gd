@icon("res://addons/gdshell/icon.png")
class_name GDShellSingleton
extends Node

#const foo = ["a", "b", "c"]


var session: GDShellSession

func _ready() -> void:
	session = GDShellSession.new(null, null)
	#foo[0] = "1"
