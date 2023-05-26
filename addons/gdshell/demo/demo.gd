extends CanvasItem


const ICON_TO_VIEWPORT_RATIO: float = 0.309018

var icon: Sprite2D


func _ready() -> void:
	print(InputMap.action_get_events(GDShell.UI_TOGGLE_ACTION))
	$GDShellIcon/Label.text = "Press '%s' to toggle GDShell" % InputMap.action_get_events(GDShell.UI_TOGGLE_ACTION)[0].as_text_keycode()
	icon = $GDShellIcon
	get_viewport().size_changed.connect(update_icon)
	update_icon()


# responsive icon
func update_icon() -> void:
	# scale the icon so that it takes up ICON_TO_VIEWPORT_RATIO of the viewport
	var min_viewport_side: int = min(get_viewport_rect().size.x, get_viewport_rect().size.y)
	var max_texture_side: int = max(icon.texture.get_size().x, icon.texture.get_size().y)
	var scale_factor: float = (min_viewport_side / max_texture_side) * ICON_TO_VIEWPORT_RATIO
	icon.scale = Vector2(scale_factor, scale_factor)
	
	# position the icon in a fancy way
	icon.position = Vector2(
		get_viewport_rect().size.x / 2, 
		get_viewport_rect().size.y - (get_viewport_rect().size.y / 1.618033)
	)
