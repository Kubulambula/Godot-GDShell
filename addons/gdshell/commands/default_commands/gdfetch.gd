extends GDShellCommand


const LOGO: String = """\
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


func _init():
	COMMAND_AUTO_ALIASES = {
		"neofetch": "gdfetch --i-am-a-linux-nerd-and-tried-to-use-neofetch"
	}


func _main(params: Dictionary) -> Dictionary:
	var info: Dictionary = get_info()
	
	if "--i-am-a-linux-nerd-and-tried-to-use-neofetch" in params["argv"]:
		info["Is the user linux nerd and tried to use neofetch"] = "Yes"
	
	if not ("-s" in params["argv"] or "--silent" in params["argv"]):
		output(construct_output(LOGO, info), false)
	
	return {"data": info}


func construct_output(graphics: String, info: Dictionary, skip_lines: int=3) -> String:
	var out: String = ""
	var unused_info_keys: Array[String] = info.keys()
	
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
