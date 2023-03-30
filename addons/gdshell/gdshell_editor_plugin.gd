@tool
class_name GDShellEditorPlugin
extends EditorPlugin


const COMMAND_SCANNED_DIRECTORIES: String = "gdshell/settings/commands/command_scanned_directories"
const COMMAND_SCANNED_DIRECTORIES_DEFAULT: Array[String] = ["res://addons/gdshell/commands/"]

const RESTORE_HISTORY_ON_STARTUP: String = "gdshell/settings/history/restore_history_on_startup"
const RESTORE_HISTORY_ON_STARTUP_DEFAULT: bool = true

const UI_TOGGLE_ACTION: String = "gdshell/settings/ui/ui_toggle_action"
const UI_TOGGLE_ACTION_DEFAULT: String = "gdshell_toggle_ui"

const UI_SCENE_PATH: String = "gdshell/settings/ui/ui_scene_path"
const UI_SCENE_PATH_DEFAULT: String = "res://addons/gdshell/ui/default_ui/default_ui.tscn"

const UI_CANVAS_LAYER: String = "gdshell/settings/ui/ui_canvas_layer"
const UI_CANVAS_LAYER_DEFAULT: int = 100


func _enter_tree() -> void:
	create_gdshell_settings()
	add_autoload_singleton("GDShell", "res://addons/gdshell/scripts/gdshell_main.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("GDShell")


func create_gdshell_settings() -> void:
	# UI section
	create_default_ui_toggle_action()
	set_setting_with_initial_value(
		UI_TOGGLE_ACTION,
		UI_TOGGLE_ACTION_DEFAULT,
	)
	
	set_setting_with_initial_value(
		UI_SCENE_PATH,
		UI_SCENE_PATH_DEFAULT,
		{
			"name": UI_SCENE_PATH,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tscn, *.scn"
		}
	)
	
	set_setting_with_initial_value(
		UI_CANVAS_LAYER,
		UI_CANVAS_LAYER_DEFAULT,
		{
			"name": UI_CANVAS_LAYER,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "-128,128"
		}
	)
	
	# History section
	set_setting_with_initial_value(
		RESTORE_HISTORY_ON_STARTUP,
		RESTORE_HISTORY_ON_STARTUP_DEFAULT,
	)
	
	# Commands section
	set_setting_with_initial_value(
		COMMAND_SCANNED_DIRECTORIES,
		COMMAND_SCANNED_DIRECTORIES_DEFAULT,
		{
			"name": COMMAND_SCANNED_DIRECTORIES,
			"type": TYPE_ARRAY,
			"hint": PROPERTY_HINT_TYPE_STRING,
			"hint_string": ("%s:" % TYPE_STRING),
		}
	)
	
	var err: int = ProjectSettings.save()
	if err:
		push_error("[GDShell] Can't save project settings: %s" % error_string(err))


func set_setting_with_initial_value(setting: String, value: Variant, property_info: Dictionary = {}) -> void:
	if not ProjectSettings.has_setting(setting):
		ProjectSettings.set_setting(setting, value)
	if not property_info.is_empty():
		ProjectSettings.add_property_info(property_info)
	ProjectSettings.set_initial_value(setting, value)
	


func create_default_ui_toggle_action() -> void:
	if not ProjectSettings.has_setting("input/%s" % UI_TOGGLE_ACTION_DEFAULT):
		var quote_left: InputEventKey = InputEventKey.new()
		quote_left.keycode = KEY_QUOTELEFT
		ProjectSettings.set_setting(
			"input/%s" % UI_TOGGLE_ACTION_DEFAULT,
			{
				"deadzone": 0.5,
				"events":
				[
					quote_left,
				]
			}
		)
