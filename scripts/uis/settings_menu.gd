class_name SettingsMenu extends Control
@onready var restart_button: Button = $ButtonsContainer/RestartButton
@onready var characters_button: Button = $ButtonsContainer/CharactersButton
@onready var main_menu: Button = $ButtonsContainer/MainMenu
@onready var main : Main = $/root/Main

func _ready():
	restart_button.pressed.connect(func():
		main.restart()
		set_visible(false)
	)
	characters_button.pressed.connect(func():
		SceneManager.load_character_select()
	)
	main_menu.pressed.connect(func():
		SceneManager.load_title()
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("OpenMenu"):
		set_visible(not visible)
