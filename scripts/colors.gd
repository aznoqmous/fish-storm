@tool
class_name Colors extends Node3D

@onready var water: MeshInstance3D = $"../Water"

@export var default_color: Color
@export var base_color: Color:
	set(value):
		base_color = value
var current_color: Color

func _ready():
	base_color = default_color
	current_color = default_color
	
func _process(delta):
	current_color = lerp(current_color, base_color, delta)
	update_color()
	
func update_color():
	water.material_override.set("shader_parameter/light_foam_color", current_color.darkened(0.8))
	water.material_override.set("shader_parameter/water_color", current_color.darkened(0.85))
	water.material_override.set("shader_parameter/dark_foam_color", current_color.darkened(0.9))
