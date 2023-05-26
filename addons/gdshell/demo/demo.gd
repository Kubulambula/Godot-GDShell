extends CanvasItem


const ICON_TO_VIEWPORT_RATIO: float = 1.0 / 3.0

var icon: Sprite2D


func _ready() -> void:
#	$GDShellIcon/Label.text = "Press %s to toggle GDShell" % 
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
	
	# center the icon
	icon.position = get_viewport_rect().size / 2
