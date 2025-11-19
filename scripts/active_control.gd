class_name ActiveControl extends Control
@onready var border: TextureRect = $Border
@onready var active_effect_sprite: TextureRect = $ActiveEffectSprite
@onready var charges_control: ChargesControl = $ChargesControl
@onready var main: Main = $/root/Main

@export var active_color: Color
@export var disabled_color: Color
func set_active(value):
	border.modulate = main.colors.current_color if value else disabled_color
	active_effect_sprite.modulate = main.colors.current_color if value else disabled_color
