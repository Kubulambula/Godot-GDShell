@icon("res://addons/gdshell/icon.png")
class_name GDShellSingleton
extends Node


var session: GDShellSession


func _ready() -> void:
	var t = Test.new()
	var callable = func() -> void: print("kokot")
	print(callable.get_object() == self.get_script())
	t.free()
	callable.call()


class Test extends Object:
	
	func foo() -> void:
		print("ahoj")
