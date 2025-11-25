class_name TitleControl extends Control

@export var texture_map: Texture2DArray
@onready var play_button: Button = $CanvasLayer/TitleControl/ButtonsContainer/PlayButton
@onready var settings_button: Button = $CanvasLayer/TitleControl/ButtonsContainer/SettingsButton
@onready var quit_button: Button = $CanvasLayer/TitleControl/ButtonsContainer/QuitButton
@onready var buttons_container: VBoxContainer = $CanvasLayer/TitleControl/ButtonsContainer
@onready var character_select: Control = $CanvasLayer/TitleControl/CharacterSelect
@onready var characters_container: GridContainer = $CanvasLayer/TitleControl/CharacterSelect/CharactersContainer
@onready var character_description: Label = $CanvasLayer/TitleControl/CharacterSelect/CharacterDescription
@onready var return_button: Button = $CanvasLayer/TitleControl/CharacterSelect/ReturnButton

@export var character_resources: Array[CharacterResource]
const CHARACTER_SELECT_CONTROL = preload("res://scenes/character_select_control.tscn")

func _ready() -> void:
	Game.characters = character_resources
	Game.load()
	
	character_select.set_visible(false)
	play_button.pressed.connect(func():
		select_character()
	)
	return_button.pressed.connect(func(): return_to_title())
	SceneManager.scene_transition_control.close()
	update_characters()
	character_description.text = ""
	
	
func update_characters():
	for child in characters_container.get_children():
		child.queue_free()
	for cr in character_resources:
		var nchar := CHARACTER_SELECT_CONTROL.instantiate() as CharacterSelectControl
		characters_container.add_child(nchar)
		nchar.load_resource(cr)
		nchar.set_state(Game.unlocked_characters.has(cr))
		nchar.mouse_entered.connect(func():
			var text = cr.description
			if not Game.unlocked_characters.has(cr): text = str("Unlock : ", cr.unlock_description)
			character_description.text = text
		)
		nchar.mouse_exited.connect(func():
			character_description.text = ""
		)

func select_character():
	character_select.set_visible(true)
	buttons_container.set_visible(false)
	
func return_to_title():
	character_select.set_visible(false)
	buttons_container.set_visible(true)
