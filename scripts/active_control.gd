class_name ActiveControl extends Control
@onready var border: TextureRect = $Border
@onready var active_effect_sprite: TextureRect = $ActiveEffectSprite
@onready var cross_sprite: Control = $CrossSprite
@onready var charges_control: ChargesControl = $ChargesControl
@onready var main: Main = $/root/Main
@onready var trigger_effect_audio: AudioStreamPlayer = $TriggerEffectAudio

@export var active_color: Color
@export var disabled_color: Color
@onready var space_label: Label = $SpaceLabel

var is_charged : bool :
	get(): return charges_control.charges >= charges_control.max_charges

func update():
	border.material.set("shader_parameter/color", main.colors.current_color if is_charged else disabled_color)
	active_effect_sprite.material.set("shader_parameter/color", main.colors.current_color if is_charged else disabled_color)
	border.material.set("shader_parameter/displacement_power", 2.0 if is_charged else 0.5)
	active_effect_sprite.material.set("shader_parameter/displacement_power", 2.0 if is_charged else 0.5)
	space_label.modulate = main.colors.current_color
	charges_control.set_visible(not is_charged)
	space_label.set_visible(is_charged)
	
func _process(_delta):
	if main.end_portal_instance: cross_sprite.set_visible(main.end_portal_instance.is_active and not is_charged)
