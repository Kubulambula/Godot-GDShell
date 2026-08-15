@icon("res://addons/gdshell/icon.png")
class_name GDShellSingleton
extends Node


var session: GDShellSession


func _ready() -> void:
	ahoj()
	ahoj()
	ahoj()
	bar()
	bar()
	bar()
	#session = GDShellSession.new()

func bar(arg = []):
	print(arg)
	arg.append(randi())

func ahoj(arg = foo()):
	print(arg)

func foo() -> Object:
	print("called")
	return Object.new()
