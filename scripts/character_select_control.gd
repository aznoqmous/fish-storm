class_name CharacterSelectControl extends Control
@onready var character_texture_rect: TextureRect = $CharacterTextureRect
@onready var border_texture_rect: TextureRect = $BorderTextureRect
@onready var label: Label = $Label

@export var enabled_color: Color
@export var disabled_color: Color
@export var lock_texture: CompressedTexture2D

var resource : CharacterResource
var hovered := false
var is_enabled := false
func _ready():
	mouse_entered.connect(func():
		hovered = true
	)
	mouse_exited.connect(func():
		hovered = false
	)

func _process(delta):
	scale = lerp(scale, Vector2.ONE * 1.2 if hovered and is_enabled else Vector2.ONE, delta * 20.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and hovered and is_enabled and event.is_pressed():
		Game.selected_character = resource
		SceneManager.load_game()

func load_resource(res: CharacterResource):
	resource = res
	character_texture_rect.material.set("shader_parameter/texture_albedo", res.head_sprite)
	label.text = res.character_name

func set_state(enabled):
	is_enabled = enabled
	modulate =  enabled_color if enabled else disabled_color
	character_texture_rect.material.set("shader_parameter/color", enabled_color if enabled else disabled_color)
	border_texture_rect.material.set("shader_parameter/color", enabled_color if enabled else disabled_color)
	character_texture_rect.material.set("shader_parameter/texture_albedo", resource.head_sprite if enabled else lock_texture)
	#label.text = resource.character_name if enabled else "???"
