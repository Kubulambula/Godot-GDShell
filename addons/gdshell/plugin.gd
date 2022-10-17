@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("GDShell", "res://addons/gdshell/scripts/gdshell_main.gd")


func _exit_tree():
	remove_autoload_singleton("GDShell")
