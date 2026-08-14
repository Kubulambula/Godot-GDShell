@icon("res://addons/gdshell/icon.png")
class_name GDShellUIHandler
extends Control

#
#signal input_submitted(input: String)
#
#
#var _UI_TOGGLE_ACTION: String = str(ProjectSettings.get_setting(
	#GDShellEditorPlugin.UI_TOGGLE_ACTION,
	#GDShellEditorPlugin.UI_TOGGLE_ACTION_DEFAULT
#))
#
#
#var history: Array = []
#var history_index: int = -1
#
#
#func _input_requested(output: String) -> void:
	#pass
#
#
#func _output_requested(output: String, append_new_lide: bool = true) -> void:
	#pass
#
#
#func submit_input(input: String) -> void:
	#history.push_front(input)
	#history_reset_index()
	#input_submitted.emit(input)
#
#
#func autocomplete(input: String) -> String:
	##var all_commands = _PARENT_GDSHELL.command_db.get_all_command_names()
	##var matches = all_commands.filter(
		##func(m: String):
			##return m.begins_with(input)
	##)
	##if matches.size() > 0:
		##return matches[0]
	##return input
	#return ""
#
#
#func history_get_next() -> String:
	#if (history.size() == 0):
		#return ""
	#history_index = clamp(history_index + 1, 0, history.size() - 1)
	#return history[history_index]
#
#
#func history_get_previous() -> String:
	#if (history.size() == 0):
		#return ""
	#history_index = clamp(history_index - 1, 0, history.size() - 1)
	#return history[history_index]
#
#
#func history_reset_index() -> void:
	#history_index = -1
#
#
#func toggle_visible() -> void:
	#visible = not visible
#
#
#func _get_output_rich_text_label() -> RichTextLabel:
	#push_error("'_get_output_rich_text_label()' is not implemented for the custom GDShellUIHandler.")
	#return null
#
#
#func _get_input_prompt() -> String:
	#return ""
