class_name Tile extends Area3D

@onready var main: Main = $/root/Main
@onready var area_3d: Area3D = $Area3D
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var csg_box_3d: CSGBox3D = $CSGBox3D
@onready var label_3d: Label3D = $Label3D
@onready var algae_sprite: Sprite3D = $AlgaeSprite

@export var color: Color
@export var available_color: Color
@export var hover_color: Color

var object: Node3D

var rseed := 0.0
var fish_weight := 0.0
var is_hovered := false
var is_available := false

var current_color: Color
var target_color: Color

func _ready() -> void:
	rseed = randf()
	mouse_entered.connect(func():
		is_hovered = true
		update_color()
	)
	mouse_exited.connect(func():
		is_hovered = false
		update_color()
	)
	algae_sprite.set_visible(randf() < 0.1)

func _input(event: InputEvent) -> void:
	if not is_available or not is_hovered: return;
	if event is InputEventMouseButton:
		if event.is_pressed():
			main.character.move_to(self)

func _process(delta):
	scale = lerp(scale, Vector3.ONE, delta * 5.0)
	
	current_color = lerp(current_color, target_color, delta * 5.0)
	sprite_3d.material_override.set("shader_parameter/color", current_color)
	#csg_box_3d.material_override.set("albedo_color", current_color)

func bump():
	scale = Vector3(1.2, 1.0/1.2, 1.2);

func get_color() -> Color:
	if not is_available: return color
	if is_hovered: return hover_color
	return available_color if main.combo < 1 else main.last_color
	
func update_color():
	target_color = get_color()
	sprite_3d.shaded = not (is_available and is_hovered)
