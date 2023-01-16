extends GDShellCommand


const MONITOR_FILE_PATH: String = "res://addons/monitor_overlay/monitor_overlay.gd"
const MONITOR_NODE_NAME: String = "GDShellMonitorOverlayIntegration"


func _main(argv: Array, _data) -> Dictionary:
	var monitor: Node = _get_monitor_overlay()
	if monitor == null:
		output("[color=red]Cannot access Monitor Overlay. Make sure you have 'Monitor Overlay' plugin installed and try again")
		return {
			"error": 1,
			"error_string": "MonitorOverlay not installed",
			"data": null,
		}
	
	var safe_to_edit_properties = _get_safe_to_edit_property_names(monitor)
	var options: Dictionary = argv_parse_options(argv, true, false)
	
	if argv.size() == 1:
		output("Not enought arguments. Run 'man monitor' to see all available options")
		return DEFAULT_COMMAND_RESULT
	
	if "options" in options:
		output("Available monitor options:\n[name : type]")
		for option in monitor.get_script().get_script_property_list()\
				.filter(func(x): return x["type"] != TYPE_NIL and x["name"][0] != "_")\
				.map(func(x): return [x["name"], x["type"]]):
			output("%s : %s" % option)
		
		return DEFAULT_COMMAND_RESULT
	
	for option in options:
		if option in safe_to_edit_properties:
			monitor.set(option, str_to_var(options[option]))
	
	return DEFAULT_COMMAND_RESULT


func _get_monitor_overlay() -> Node:
	if not _PARENT_PROCESS._PARENT_GDSHELL.has_node(NodePath(MONITOR_NODE_NAME)):
		if not ResourceLoader.exists(MONITOR_FILE_PATH):
			return null
		
		@warning_ignore(unsafe_method_access, unsafe_cast)
		var monitor: Node = ResourceLoader.load(MONITOR_FILE_PATH, "GDScript").new() as Node
		# Sets the name of the MonitorOverlay Node to make it clear that it belongs to and is managed by GDShell
		monitor.name = StringName(MONITOR_NODE_NAME)
		monitor.unique_name_in_owner = true
		# disable the fps monitor as it is enabled  by default
		monitor.set("fps", false)
		_PARENT_PROCESS._PARENT_GDSHELL.add_child(monitor)
	
	return _PARENT_PROCESS._PARENT_GDSHELL.get_node(NodePath(MONITOR_NODE_NAME))


# returns names of properties of monitor_overlay.gd script that areused for monitor ui control
func _get_safe_to_edit_property_names(monitor: Object) -> Array:
	return monitor.get_script().get_script_property_list()\
			.filter(func(x): return x["type"] != TYPE_NIL and x["name"][0] != "_")\
			.map(func(x): return x["name"])


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
	
	[b]-option=value[/b]
		Sets the option variable of MonitorOverlay node to the value.
		To see all the available options, run: [i]monitor -options[/i]

[b]EXAMPLES[/b]
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
