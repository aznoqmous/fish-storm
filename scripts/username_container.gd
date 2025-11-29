class_name UsernameContainer extends Control

@onready var username_edit: LineEdit = $UsernameEdit
@onready var pen: TextureRect = $Pen
@onready var min_length_alert: Label = $Control/MinLengthAlert
@onready var username_explanation: Label = $Control/UsernameExplanation

var min_length := 4
var max_length := 12

var hovered := false

func _ready():
	min_length_alert.text = str("At least ", min_length, " characters !")
	username_edit.editable = false

	mouse_entered.connect(func(): hovered = true)
	mouse_exited.connect(func(): hovered = false)
	
	username_edit.text_changed.connect(func():
		min_length_alert.set_visible(username_edit.text.length() < min_length)
	)
	
	Game.username_changed.connect(func():
		username_edit.text = Game.username
		username_explanation.set_visible(Game.username.length() == 0 and not min_length_alert.visible)
	)
	username_edit.text = Game.username
	username_explanation.set_visible(Game.username.length() == 0 and not min_length_alert.visible)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if not hovered:
			username_edit.editable = false
			if username_edit.text.length() >= min_length:
				Game.username = username_edit.text.substr(0, max_length)
				Game.save()
			else:
				Game.username = ""
				Game.save()
			min_length_alert.set_visible(false)
			username_explanation.set_visible(Game.username.length() == 0 and not min_length_alert.visible)
		else:
			username_edit.editable = true
			username_explanation.set_visible(false)
