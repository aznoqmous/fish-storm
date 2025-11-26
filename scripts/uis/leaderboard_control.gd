class_name LeaderboardControl extends Control
@onready var character_texture: TextureRect = $CharacterControl/CharacterTexture
@onready var border_texture: TextureRect = $CharacterControl/BorderTexture
@onready var rank_label: Label = $Control/RankLabel
@onready var name_label: Label = $Control/NameLabel
@onready var score_label: Label = $Control/ScoreLabel
@onready var background: TileScaleContainer = $Background

func load_character(character: CharacterResource):
	character_texture.material.set("shader_parameter/texture_albedo", character.head_sprite)
