class_name FinalScoreControl extends Control

@onready var main:Main = $/root/Main
@onready var character_texture: TextureRect = $ScoreContainer/CharacterControl/CharacterTexture
@onready var final_score_label: Label = $ScoreContainer/Control/FinalScoreLabel
@onready var buttons_container: VBoxContainer = $ButtonsContainer
@onready var restart_button: Button = $ButtonsContainer/RestartButton
@onready var characters_button: Button = $ButtonsContainer/CharactersButton
@onready var main_menu: Button = $ButtonsContainer/MainMenu


func _ready():
	character_texture.material.set("shader_parameter/texture_albedo", Game.selected_character.head_sprite)
	restart_button.pressed.connect(main.restart)
	characters_button.pressed.connect(func():
		SceneManager.load_character_select()
	)
	main_menu.pressed.connect(func():
		SceneManager.load_title()
	)

func animate():
	buttons_container.set_visible(false)
	final_score_label.text = ""
	for c in str(main.score).split():
		await get_tree().create_timer(0.3).timeout
		final_score_label.text += c
	await get_tree().create_timer(0.5).timeout
	buttons_container.set_visible(true)
