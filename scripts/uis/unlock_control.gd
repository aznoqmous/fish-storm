class_name UnlockControl extends Control

@onready var character_texture: TextureRect = $CharacterSpriteContainer/CharacterTexture
@onready var character_name_label: Label = $CharacterNameLabel

func load_character(character: CharacterResource):
	character_texture.material.set("shader_parameter/texture_albedo", character.head_sprite)
	character_name_label.text = character.character_name
