extends GDShellCommand


const MONITOR_FILE_PATH: String = "res://addons/monitor_overlay/monitor_overlay.gd"
const MONITOR_NODE_NAME: String = "GDShellMonitorOverlayIntegration"

const OPTIONS_FLAGS: Array[String] = ["o", "O", "options", "OPTIONS"]

# Workaround until https://github.com/godotengine/godot/pull/69624 gets merged
const TYPE_NAMES: Array[String] = [
	"Nil",
	"bool",
	"int",
	"float",
	"String",
	"Vector2",
	"Vector2i",
	"Rect2",
	"Rect2i",
	"Vector3",
	"Vector3i",
	"Transform2D",
	"Vector4",
	"Vector4i",
	"Plane",
	"Quaternion",
	"AABB",
	"Basis",
	"Transform3D",
	"Projection",
	"Color",
	"StringName",
	"NodePath",
	"RID",
	"Object",
	"Callable",
	"Signal",
	"Dictionary",
	"Array",
	"PackedByteArray",
	"PackedInt32Array",
	"PackedInt64Array",
	"PackedFloat32Array",
	"PackedFloat64Array",
	"PackedStringArray",
	"PackedVector2Array",
	"PackedVector3Array",
	"PackedColorArray",
]


func _main(argv: Array, _data) -> Dictionary:
	var monitor: Node = _get_monitor_overlay()
	if monitor == null:
		output("Cannot access Monitor Overlay. Make sure you have 'Monitor Overlay' plugin installed and try again")
		return {
			"error": 1,
			"error_string": "Cannot access Monitor Overlay. Make sure you have 'Monitor Overlay' plugin installed and try again",
			"data": null,
		}
	
	if argv.size() == 1:
		output("Not enought arguments. Run 'man monitor' to see all available options")
		return {
			"error": 2,
			"error_string": "Not enought arguments. Run 'man monitor' to see all available options",
			"data": null,
		}
	
	var safe_to_edit_properties: Array[Dictionary] = _get_monitor_overlay_safe_to_edit_properties(monitor)
	var options: Dictionary = GDShellCommand.argv_parse_options(argv, true, false)
	
	if OPTIONS_FLAGS.any(func(option): return option in options): # If any OPTION_FLAG is in options
		_print_available_options(safe_to_edit_properties)
		# Delete all option flags so that _edit_monitor_properties_with_options() does not have to deal with them
		for option in OPTIONS_FLAGS:
			@warning_ignore("return_value_discarded")
			options.erase(option)
	
	_edit_monitor_properties_with_options(monitor, safe_to_edit_properties, options)
	
	return DEFAULT_COMMAND_RESULT


func _get_monitor_overlay() -> Node:
	if not _PARENT_PROCESS._PARENT_GDSHELL.has_node(NodePath(MONITOR_NODE_NAME)):
		if not ResourceLoader.exists(MONITOR_FILE_PATH):
			return null # MonitorOverlay is not installed
		
		@warning_ignore("unsafe_cast", "unsafe_method_access")
		var monitor: Node = ResourceLoader.load(MONITOR_FILE_PATH, "GDScript").new() as Node
		# Sets the name of the MonitorOverlay Node to make it clear that it belongs to and is managed by GDShell
		monitor.name = StringName(MONITOR_NODE_NAME)
		monitor.unique_name_in_owner = true
		# disable the fps monitor as it is enabled  by default
		monitor.set("fps", false)
		_PARENT_PROCESS._PARENT_GDSHELL.add_child(monitor)
	
	return _PARENT_PROCESS._PARENT_GDSHELL.get_node(NodePath(MONITOR_NODE_NAME))


# returns a list of properties that are used for MonitorOverlay UI control
func _get_monitor_overlay_safe_to_edit_properties(monitor: Object) -> Array[Dictionary]:
	@warning_ignore("unsafe_method_access")
	return monitor.get_script().get_script_property_list().filter(
			func(property): 
				return property["type"] != TYPE_NIL and property["name"][0] != "_"
	)


func _print_available_options(safe_to_edit_properties: Array[Dictionary]) -> void:
	get_ui_handler_rich_text_label().scroll_to_line.call_deferred(get_ui_handler_rich_text_label().get_line_count() - 1)
	
	output("Available monitor options ([color=BISQUE]name[/color] : [color=AQUAMARINE]type[/color])")
	for property in safe_to_edit_properties:
		output("[color=BISQUE]%s[/color] : [color=AQUAMARINE]%s[/color]" % [
			property["name"],
			TYPE_NAMES[property["type"]]
		])


func _edit_monitor_properties_with_options(monitor: Node, safe_to_edit_properties: Array[Dictionary], options: Dictionary) -> void:
	var safe_to_edit_property_names: Array = safe_to_edit_properties.map(func(property): return property["name"])
	
	for option in options:
		if option in safe_to_edit_property_names:
			monitor.set(option, str_to_var(options[option]))
		else:
			output("Parameter '[color=LIGHT_CORAL]%s[/color]' is not a valid option. Run '[color=AQUAMARINE]monitor --options[/color]' to see all available options" % option)


func _get_manual() -> String:
	return """
[b]NAME[/b]
	{COMMAND_NAME}

[b]AUTO ALIASES[/b]
	{COMMAND_AUTO_ALIASES}

[b]SYNOPSIS[/b]
	monitor [OPTIONS]

[b]DESCRIPTION[/b]
	Uses Monitor Overlay plugin by @HungryProton to show various information about performance
	
	[b]-o, --options[/b]
		Displays all available MonitorOverlay options and their types.
	
	[b]-option=value[/b]
		Sets the option variable of MonitorOverlay node to the value.
		All option values are parsed by str_to_var()
		
		To see all the available options, run: [i]monitor --options[/i]

[b]EXAMPLES[/b]
	[i]monitor --options[/i]
		-Shows all available monitor options and their types
	
	[i]monitor -fps=true[/i]
		-Enables fps monitor
	
	[i]unmonitor -fps=false[/i]
		-Disables fps monitor
	
	[i]monitor -fps=true --process=true --physics_process=false --sampling_rate=10[/i]
		-Enables fps and process monitors, disables physics_process monitor and sets sampling rate to 10
""".format({
	"COMMAND_NAME": COMMAND_NAME,
	"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
})
