class_name Tile extends Area3D

@onready var main: Main = $/root/Main
@onready var area_3d: Area3D = $Area3D
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var csg_box_3d: CSGBox3D = $CSGBox3D

@export var color: Color
@export var available_color: Color
@export var hover_color: Color

var object: Node3D

var rseed := 0.0
var is_hovered := false
var is_available := false

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

func _input(event: InputEvent) -> void:
	if not is_hovered: return;
	if event is InputEventMouseButton:
		if event.is_pressed():
			main.character.move_to(self)
			clicked.emit()
			main.gain_combo(-2)

func _process(delta):
	scale = lerp(scale, Vector3.ONE, delta * 5.0)

func bump():
	scale = Vector3(1.2, 1.0/1.2, 1.2);

func explode():
	queue_free()

func get_color() -> Color:
	if not is_available: return color
	if is_hovered: return hover_color
	return available_color
	
func update_color():
	var ncolor = get_color()
	csg_box_3d.material_override.set("albedo_color", ncolor)
	sprite_3d.modulate = ncolor
	sprite_3d.shaded = not (is_available and is_hovered) 

signal clicked;
