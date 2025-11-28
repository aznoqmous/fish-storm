class_name LeaderboardControl extends Control

@onready var character_texture: TextureRect = $CharacterControl/CharacterTexture
@onready var border_texture: TextureRect = $CharacterControl/BorderTexture
@onready var rank_label: Label = $Control/RankLabel
@onready var name_label: Label = $Control/NameLabel
@onready var score_label: Label = $Control/ScoreLabel
@onready var background: TileScaleContainer = $Background
@onready var level_label: Label = $Control/LevelLabel

var run_id := 0

var is_current := false

func load_character(character: CharacterResource):
	character_texture.material.set("shader_parameter/texture_albedo", character.head_sprite)

func _process(_delta):
	modulate = Color.WHITE if not is_current else Color.from_hsv(Time.get_ticks_msec()/1000.0 / 2.0, 0.5, 1.0)
	character_texture.material.set("shader_parameter/color", modulate)
	border_texture.material.set("shader_parameter/color", modulate)
