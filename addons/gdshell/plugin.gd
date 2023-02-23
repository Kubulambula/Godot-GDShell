@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("GDShell", "res://addons/gdshell/scripts/gdshell_main.gd")
	
	if not ProjectSettings.has_setting("input/%s" % GDShellMain.GDSHELL_TOGGLE_UI_ACTION):
		var quote_left: InputEventKey = InputEventKey.new()
		quote_left.keycode = KEY_QUOTELEFT
		
		ProjectSettings.set_setting(
				"input/%s" % GDShellMain.GDSHELL_TOGGLE_UI_ACTION,
				{
					"deadzone": 0.5,
					"events":
					[
						quote_left,
					]
				}
			)
		
		ProjectSettings.save()


func _exit_tree():
	remove_autoload_singleton("GDShell")
