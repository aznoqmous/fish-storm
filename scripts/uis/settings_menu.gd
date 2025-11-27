class_name SettingsMenu extends Control
@onready var resume_game_button: Button = $ButtonsContainer/ResumeGameButton
@onready var restart_button: Button = $ButtonsContainer/RestartButton
@onready var characters_button: Button = $ButtonsContainer/CharactersButton
@onready var settings_button: Button = $ButtonsContainer/SettingsButton
@onready var main_menu: Button = $ButtonsContainer/MainMenu
@onready var main : Main = $/root/Main
@onready var settings_container: Control = $"SettingsContainer"
@onready var settings_return_button: Button = $"SettingsContainer/VBoxContainer/SettingsReturnButton"
@onready var buttons_container: VBoxContainer = $ButtonsContainer

func _ready():
	
	resume_game_button.pressed.connect(func():
		set_visible(false)
	)
	restart_button.pressed.connect(func():
		main.restart()
		set_visible(false)
	)
	characters_button.pressed.connect(func():
		SceneManager.load_character_select()
	)
	settings_button.pressed.connect(func():
		settings_container.set_visible(true)
		buttons_container.set_visible(false)
	)
	settings_return_button.pressed.connect(func():
		settings_container.set_visible(false)
		buttons_container.set_visible(true)
	)
	main_menu.pressed.connect(func():
		SceneManager.load_title()
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("OpenMenu"):
		set_visible(not visible)
