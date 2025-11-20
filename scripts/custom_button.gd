extends Button

@onready var button_click: AudioStreamPlayer = $ButtonClick
@onready var button_hover: AudioStreamPlayer = $ButtonHover

func _on_pressed() -> void:
	button_click.play()

func _on_mouse_entered() -> void:
	button_hover.play()
