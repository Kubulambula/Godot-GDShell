extends GDShellCommand


const LOGO: String = (
"""
						   &&&&&&&                            
					  &&&&&       &&&&&                       
				 &&&&&                 &&&&&                  
			 &&&&                           &&&&              
		 &&&&                                   &&&&          
	  &&&                                           &&&&      
	&&                                                  &&&   
  &&                                                       && 
 &&                                                     &&&&&&
&&                                                  &&&&&&&&&&
&&                                              &&&&&&&&&&&&&&
&&                                          &&&&&&&&&&&&&&&&&&
&&                                      &&&&&&&&&[color=#478cbf]$$$$[/color]&&&&[color=#478cbf]$$[/color]&&&
&&                                  &&&&&&&&[color=#478cbf]$$[/color]&&[color=#478cbf]$$$$$$$$$$$$[/color]&&
&&                               &&&&&&&&&[color=#478cbf]$$$$$$$$$$$$$$$$$[/color]&&&
&&                              &&&&&&&&&&[color=#478cbf]$$$$$$$$$$$$$$$$[/color]&&&&
&&                             &&&&&&[color=#478cbf]$$[/color]&[color=#478cbf]$$$$$$$$$$$$$$$$$$[/color]&&&&
&&                             &&&&&[color=#478cbf]$$$$$$$$$$$$$$$$$$$$$$[/color]&&&&
&&                             &&&&[color=#478cbf]$$$$$$$$$$$$$$$$$$$$$$$[/color]&&&&
&&                             &&&&&&[color=#478cbf]$$$$$$$$$$$$$$$$$$$$$[/color]&&&&
 &&                            &&&&&&[color=#478cbf]$$$$$$$$$$$$$$$$$$$[/color]&&&&&&
  &&&                          &&&&&&[color=#478cbf]$$$$$$$$$$$$$$$$$[/color]&&&&&&& 
	 &&&                       &&&&&&[color=#478cbf]$$$$$$$$$$$$$$[/color]&&&&&&&&   
		&&&&                   &&&&&&&[color=#478cbf]$$$$$$$$$$[/color]&&&&&&&       
			&&&&               &&&&&&&&&&&&&&&&&&&&           
				&&&&&           &&&&&&&&&&&&&&&&              
					 &&&&&       &&&&&&&&&&&                  
						  &&&&&&&&&&&&&                       
"""
)


func _init():
	COMMAND_AUTO_ALIASES = {
		"neofetch": "gdfetch --i-am-a-linux-nerd-and-tried-to-use-neofetch",
	}


func _main(argv: Array, data) -> Dictionary:
	var info: Dictionary = get_info()
	
	if "--i-am-a-linux-nerd-and-tried-to-use-neofetch" in argv:
		info["Is the user linux nerd and tried to use neofetch"] = "Yes"
	
	if not ("-s" in argv or "--silent" in argv):
		output(construct_output(LOGO, info), false)
	
	return {"data": info}


func construct_output(graphics: String, info: Dictionary, skip_lines: int = 3) -> String:
	var out: String = ""
	var unused_info_keys: Array = info.keys()
	
	for line in graphics.split("\n", false):
		out += line
		
		if skip_lines > 0:
			skip_lines -= 1
		elif not unused_info_keys.is_empty():
			out += "  [color=#478cbf]%s[/color]: %s" % [unused_info_keys[0], info[unused_info_keys[0]]]
			unused_info_keys.remove_at(0)
		
		out += "\n"
	
	return out


static func get_info() -> Dictionary:
	return {
		"Project Name": ProjectSettings.get_setting("application/config/name"),
		"GDShell Version": GDShellMain.get_gdshell_version(),
		"Godot Version": Engine.get_version_info()["string"],
		"Build": ("Debug" if OS.is_debug_build() else "Release") if OS.has_feature("standalone") else "Editor",
		"OS": OS.get_distribution_name() + " " + OS.get_version(),
		"Screen Resolution": "%sx%s" % [DisplayServer.screen_get_size().x, DisplayServer.screen_get_size().y],
		"Window Resolution": "%sx%s" % [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y],
		"CPU": OS.get_processor_name(),
		"GPU": RenderingServer.get_video_adapter_name(),
	}


func _get_manual() -> String:
	return (
"""
[b]NAME[/b]
	{COMMAND_NAME}

[b]AUTO ALIASES[/b]
	{COMMAND_AUTO_ALIASES}

[b]SYNOPSIS[/b]
	gdfetch [OPTION]

[b]DESCRIPTION[/b]
	Get and print information about the current project
	
	[b]-s, --silent[/b]
		Do not print to the console
	
	[b]--i-am-a-linux-nerd-and-tried-to-use-neofetch[/b]
		Adds a \"Is the user linux nerd and tried to use neofetch\" value.
		This is an easter egg and is shown when user uses \"neofetch\" instead of \"gdfetch\".

[b]EXAMPLES[/b]
	[i]gdfetch[/i]
		-Prints and returns the information about the current project.
	
	[i]gdfetch -s[/i]
		-Returns the information about the current project, but does not print it to the console.
		 Can be used as a input for other commands when called silently.
""".format(
			{
				"COMMAND_NAME": COMMAND_NAME,
				"COMMAND_AUTO_ALIASES": COMMAND_AUTO_ALIASES,
			}
		)
	)
