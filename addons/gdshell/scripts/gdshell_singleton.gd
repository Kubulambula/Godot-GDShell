@icon("res://addons/gdshell/icon.png")
class_name GDShellSingleton
extends Node


var session: GDShellSession


func _ready() -> void:
	session = GDShellSession.new(null)
