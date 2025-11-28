class_name CharacterSelectControl extends Control

@onready var character_texture_rect: TextureRect = $CharacterTextureRect
@onready var border_texture_rect: TextureRect = $BorderTextureRect
@onready var label: Label = $Label

@export var enabled_color: Color
@export var disabled_color: Color
@export var lock_texture: CompressedTexture2D
@onready var star_texture: TextureRect = $Label/StarTexture

@onready var button_click: AudioStreamPlayer = $ButtonClick
@onready var button_hover: AudioStreamPlayer = $ButtonHover

var resource : CharacterResource
var hovered := false
var is_enabled := false

var rseed := 0.0

func _ready():
	mouse_entered.connect(func():
		hovered = true
		if is_enabled: button_hover.play()
	)
	mouse_exited.connect(func():
		hovered = false
	)

func _process(delta):
	scale = lerp(scale, Vector2.ONE * 1.2 if hovered and is_enabled else Vector2.ONE, delta * 20.0)
	star_texture.material.set("shader_parameter/color", Color.from_hsv(rseed + Time.get_ticks_msec() / 1000.0 / 10.0, 0.5, 1.0))
	star_texture.position.y = -134.0 + sin((Time.get_ticks_msec() / 1000.0 + rseed) * TAU) * 3.0
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and hovered and is_enabled and event.is_pressed():
		button_click.play()
		Game.selected_character = resource
		SceneManager.load_game()

func load_resource(res: CharacterResource):
	resource = res
	character_texture_rect.material.set("shader_parameter/texture_albedo", res.head_sprite)
	label.text = res.character_name

func set_state(enabled):
	is_enabled = enabled
	update_state()
	#label.text = resource.character_name if enabled else "???"
	
func update_state():
	character_texture_rect.material.set("shader_parameter/texture_albedo", resource.head_sprite if is_enabled else lock_texture)
	set_color(enabled_color if is_enabled else disabled_color)
	
func set_color(color):
	modulate = color
	character_texture_rect.material.set("shader_parameter/color", color)
	border_texture_rect.material.set("shader_parameter/color", color)
	
