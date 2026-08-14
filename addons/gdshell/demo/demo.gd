extends CanvasItem


const ICON_TO_VIEWPORT_RATIO: float = 0.309018

@onready var icon: Sprite2D = %GDShellIcon
@onready var label: Label = %Label


func _ready() -> void:
	icon = $GDShellIcon
	@warning_ignore("return_value_discarded")
	get_viewport().size_changed.connect(update_icon)
	update_icon()
	
	return # TODO: remove this return and rework it so that it detects the toggle action from whereever it was moved
	var gdshell_ui_toggle_action_input_events: Array[InputEvent] = InputMap.action_get_events(GDShell.ui_handler._UI_TOGGLE_ACTION)
	if gdshell_ui_toggle_action_input_events.is_empty():
		label.text = "No InputEvent is set for GDShell Ui Toggle Action.\nSet an action in settings at 'gdshell/settings/ui/ui_toggle_action'."
	else:
		label.text = "Press '%s' to toggle GDShell" % (gdshell_ui_toggle_action_input_events[0] as InputEventKey).as_text_keycode()


# responsive icon
func update_icon() -> void:
	# scale the icon so that it takes up ICON_TO_VIEWPORT_RATIO of the viewport
	var min_viewport_side: float = min(get_viewport_rect().size.x, get_viewport_rect().size.y)
	var max_texture_side: float = max(icon.texture.get_size().x, icon.texture.get_size().y)
	var scale_factor: float = (min_viewport_side / max_texture_side) * ICON_TO_VIEWPORT_RATIO
	icon.scale = Vector2(scale_factor, scale_factor)
	
	# position the icon in a fancy way
	icon.position = Vector2(
		get_viewport_rect().size.x / 2, 
		get_viewport_rect().size.y - (get_viewport_rect().size.y / 1.618033)
	)
