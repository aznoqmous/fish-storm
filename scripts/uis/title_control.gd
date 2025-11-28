class_name TitleControl extends Control

@export var texture_map: Texture2DArray
@onready var title: Control = $CanvasLayer/TitleControl/Panel/Title
@onready var play_button: Button = $CanvasLayer/TitleControl/ButtonsContainer/PlayButton
@onready var settings_button: Button = $CanvasLayer/TitleControl/ButtonsContainer/SettingsButton
@onready var quit_button: Button = $CanvasLayer/TitleControl/ButtonsContainer/QuitButton
@onready var leaderboard_button: Button = $CanvasLayer/TitleControl/ButtonsContainer/LeaderboardButton
@onready var buttons_container: VBoxContainer = $CanvasLayer/TitleControl/ButtonsContainer

@onready var character_select: Control = $CanvasLayer/TitleControl/CharacterSelect
@onready var characters_container: GridContainer = $CanvasLayer/TitleControl/CharacterSelect/CharactersContainer
@onready var character_description: Label = $CanvasLayer/TitleControl/CharacterSelect/CharacterDescription
@onready var return_button: Button = $CanvasLayer/TitleControl/CharacterSelect/ReturnButton

@onready var leader_board_container_control_container: Control = $CanvasLayer/TitleControl/LeaderBoardContainerControlContainer
@onready var leader_board_container_control: LeaderBoardContainerControl = $CanvasLayer/TitleControl/LeaderBoardContainerControlContainer/LeaderBoardContainerControl
@onready var leader_board_return_button: Button = $CanvasLayer/TitleControl/LeaderBoardContainerControlContainer/LeaderBoardReturnButton

@onready var settings_container: Control = $CanvasLayer/TitleControl/SettingsContainer
@onready var settings_return_button: Button = $CanvasLayer/TitleControl/SettingsContainer/SettingsReturnButton


@export var character_resources: Array[CharacterResource]
const CHARACTER_SELECT_CONTROL = preload("res://scenes/uis/character_select_control.tscn")

func _ready() -> void:
	Game.characters = character_resources
	Game.load()
	
	character_select.set_visible(false)
	play_button.pressed.connect(select_character)
	leaderboard_button.pressed.connect(show_leaderboard)
	return_button.pressed.connect(func(): return_to_title())
	quit_button.pressed.connect(func(): get_tree().quit())
	leader_board_return_button.pressed.connect(func(): return_to_title())
	settings_button.pressed.connect(func(): show_settings())
	settings_return_button.pressed.connect(func(): return_to_title())
	SceneManager.scene_transition_control.close()
	update_characters()
	character_description.text = ""
	
	#leader_board_container_control.send_data(Game.characters[0], "azdazd", 123546, 5)
	#leader_board_container_control.update()
	
func update_characters():
	for child in characters_container.get_children():
		child.queue_free()
	var i = 0.0
	for cr in character_resources:
		var nchar := CHARACTER_SELECT_CONTROL.instantiate() as CharacterSelectControl
		characters_container.add_child(nchar)
		nchar.load_resource(cr)
		nchar.set_state(Game.unlocked_characters.has(cr))
		nchar.star_texture.set_visible(Game.has_completed_run(cr))
		nchar.mouse_entered.connect(func():
			var text = cr.description
			if not Game.unlocked_characters.has(cr): text = str("Unlock : ", cr.unlock_description)
			character_description.text = text
		)
		nchar.mouse_exited.connect(func():
			character_description.text = ""
		)
		nchar.rseed = i / character_resources.size()
		i += 1.0
		
func select_character():
	character_select.set_visible(true)
	buttons_container.set_visible(false)
	title.set_visible(true)
	
func return_to_title():
	character_select.set_visible(false)
	leader_board_container_control_container.set_visible(false)
	settings_container.set_visible(false)
	buttons_container.set_visible(true)
	title.set_visible(true)
	
func show_settings():
	buttons_container.set_visible(false)
	settings_container.set_visible(true)
	
func show_leaderboard():
	leader_board_container_control_container.set_visible(true)
	leader_board_container_control.update()
	buttons_container.set_visible(false)
	title.set_visible(false)
	
