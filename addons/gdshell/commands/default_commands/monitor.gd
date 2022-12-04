extends GDShellCommand


const MONITOR_FILE_PATH: String = "res://addons/monitor_overlay/monitor_overlay.gd"
const MONITOR_NODE_NAME: String = "GDShellMonitorOverlay"


func _init():
	COMMAND_AUTO_ALIASES = {
		"unmonitor": "monitor -u",
	}


func _main(argv: Array, _data) -> Dictionary:
	var monitor: Node = _get_monitor_overlay()
	
	var monitor_visible_mode: bool = true
	for i in range(1, argv.size()):
		if argv[i] == "-m" or argv[i] == "--monitor":
			monitor_visible_mode = true
		elif argv[i] == "-u" or argv[i] == "--unmonitor":
			monitor_visible_mode = false
		else:
			match argv[i]:
				"fps":
					monitor.set("fps", monitor_visible_mode)
				"process":
					monitor.set("process", monitor_visible_mode)
				"physics_process":
					monitor.set("physics_process", monitor_visible_mode)
				"static_memory":
					monitor.set("static_memory", monitor_visible_mode)
				"max_static_memory":
					monitor.set("max_static_memory", monitor_visible_mode)
				"max_message_buffer":
					monitor.set("max_message_buffer", monitor_visible_mode)
				"objects":
					monitor.set("objects", monitor_visible_mode)
				"resources":
					monitor.set("resources", monitor_visible_mode)
				"nodes":
					monitor.set("nodes", monitor_visible_mode)
				"orphan_nodes":
					monitor.set("orphan_nodes", monitor_visible_mode)
				"objects_drawn":
					monitor.set("objects_drawn", monitor_visible_mode)
				"primitives_drawn":
					monitor.set("primitives_drawn", monitor_visible_mode)
				"total_draw_calls":
					monitor.set("total_draw_calls", monitor_visible_mode)
				"video_memory":
					monitor.set("video_memory", monitor_visible_mode)
				"texture_memory":
					monitor.set("texture_memory", monitor_visible_mode)
				"buffer_memory":
					monitor.set("buffer_memory", monitor_visible_mode)
				"active_objects_2d":
					monitor.set("active_objects_2d", monitor_visible_mode)
				"collision_pairs_2d":
					monitor.set("collision_pairs_2d", monitor_visible_mode)
				"islands_2d":
					monitor.set("islands_2d", monitor_visible_mode)
				"active_objects_3d":
					monitor.set("active_objects_3d", monitor_visible_mode)
				"collision_pairs_3d":
					monitor.set("collision_pairs_3d", monitor_visible_mode)
				"islands_3d":
					monitor.set("islands_3d", monitor_visible_mode)
				"audio_output_latency":
					monitor.set("paudio_output_latencys", monitor_visible_mode)
				_:
					output("[color=yellow]Unknown monitor '%s'[/color]" % argv[i])
	
	return DEFAULT_COMMAND_RESULT


func _get_monitor_overlay() -> Node:
	if not _PARENT_PROCESS._PARENT_GDSHELL.has_node(NodePath(MONITOR_NODE_NAME)):
		if not ResourceLoader.exists(MONITOR_FILE_PATH):
			output("[color=red]Cannot access Monitor Overlay. Make sure you have 'Monitor Overlay' plugin installed and try again")
			return null
		@warning_ignore(unsafe_method_access, unsafe_cast)
		var monitor: Node = ResourceLoader.load(MONITOR_FILE_PATH, "GDScript").new() as Node
		monitor.name = StringName(MONITOR_NODE_NAME)
		monitor.unique_name_in_owner = true
		_PARENT_PROCESS._PARENT_GDSHELL.add_child(monitor)
	
	return _PARENT_PROCESS._PARENT_GDSHELL.get_node(NodePath(MONITOR_NODE_NAME))


func _get_manual() -> String:
	return """
[b]NAME[/b]
	{COMMAND_NAME}

[b]AUTO ALIASES[/b]
	{COMMAND_AUTO_ALIASES}

[b]SYNOPSIS[/b]
	monitor [OPTION] [MONITORS]

[b]DESCRIPTION[/b]
	Uses Monitor Overlay plugin by @HungryProton to show various information about performance
	
	[b]-m, --monitor[/b]
		Enables all monitors after this parameter
		This it the default behaviour if no parameter is specified
	
	[b]-u, --unmonitor[/b]
		Disables all monitors after this parameter

[b]EXAMPLES[/b]
	[i]monitor fps[/i]
		-Enables fps monitor
		 Same as monitor -m fps
	
	[i]unmonitor fps[/i]
		-Disables fps monitor
		 Same as monitor -u fps
	
	[i]monitor fps process -u physics_process[/i]
		-Enables fps and process monitors and disabled physics_process monitor
""".format({
	"COMMAND_NAME": COMMAND_NAME,
	"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
})
