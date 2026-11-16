extends CanvasLayer
## P006 input rules for a panel shown while the game is paused (shop, expedition results).
## While this layer is visible:
## - Space never confirms. Godot's built-in ui_accept includes Space, which P006 also binds to
##   `attack`, so a focused button would treat a sword swing as "confirm". Any key event that is
##   both `attack` and `ui_accept` is consumed before the panel's buttons see it.
## - The gamepad confirm button works. This project's ui_accept has no gamepad binding, so the
##   gamepad button bound to `interact` (A / bottom) presses the focused, enabled button here.
## Enter and mouse clicks keep Godot's normal button handling. Nothing outside P006 changes,
## so earlier prototypes keep their historical input. Prototype-local; not an input framework.


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.is_action("attack") and event.is_action("ui_accept"):
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		var focused: Control = get_viewport().gui_get_focus_owner()
		# Only this panel's own buttons, and only once focus has been granted after its delay.
		if focused is BaseButton and is_ancestor_of(focused) and not (focused as BaseButton).disabled:
			(focused as BaseButton).pressed.emit()
