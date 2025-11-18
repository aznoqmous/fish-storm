class_name TitleControl extends Control

@onready var play_button: Button = $ButtonsContainer/PlayButton
@onready var settings_button: Button = $ButtonsContainer/SettingsButton
@onready var quit_button: Button = $ButtonsContainer/QuitButton
@onready var buttons_container: VBoxContainer = $ButtonsContainer
@onready var characters_container: GridContainer = $CharactersContainer

@export var character_resources: Array[CharacterResource]
@export var unlocked_characters: Array[CharacterResource]
const CHARACTER_SELECT_CONTROL = preload("res://scenes/character_select_control.tscn")

func _ready() -> void:
	characters_container.set_visible(false)
	play_button.pressed.connect(func():
		characters_container.set_visible(true)
		buttons_container.set_visible(false)
		pass
	)
	SceneManager.scene_transition_control.close()
	update_characters()
	
func update_characters():
	for child in characters_container.get_children():
		child.queue_free()
	for cr in character_resources:
		var nchar := CHARACTER_SELECT_CONTROL.instantiate() as CharacterSelectControl
		characters_container.add_child(nchar)
		nchar.load_resource(cr)
		nchar.set_state(unlocked_characters.has(cr))
		#nchar.set_state(true)
