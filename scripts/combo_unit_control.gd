class_name ComboUnitControl extends Control
@onready var main:Main = $/root/Main
@onready var texture_rect: TextureRect = $TextureRect
var rseed := 0.0

func _ready():
	rseed = randf_range(-1.0, 1.0)
	
func _process(_delta):
	var time = Time.get_ticks_msec()/1000.0
	texture_rect.position = Vector2(sin((time * sign(rseed) + rseed) * TAU), cos((time * sign(rseed) + rseed) * TAU)) * sin((time * sign(rseed) + rseed) * TAU) * main.combo;

func set_texture(texture: CompressedTexture2D):
	texture_rect.material.set("shader_parameter/texture_albedo", texture)

func set_color(color: Color):
	texture_rect.material.set("shader_parameter/color", color)
