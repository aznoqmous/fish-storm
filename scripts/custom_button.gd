extends Button

@onready var button_click: FmodEventEmitter2D = $ButtonClick
@onready var button_hover: FmodEventEmitter2D = $ButtonHover


func _on_pressed() -> void:
	button_click.play()

func _on_mouse_entered() -> void:
	button_hover.play()
