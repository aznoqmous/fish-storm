class_name Tile extends Area3D

@onready var main: Main = $/root/Main
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var label_3d: Label3D = $Label3D
@onready var algae_sprite: Sprite3D = $AlgaeSprite
@onready var csg_box_3d: CSGBox3D = $CSGBox3D
@onready var cube: MeshInstance3D = $TileModel/Cube
@onready var last_position_sprite: Sprite3D = $LastPositionSprite

@export var color: Color
@export var available_color: Color
@export var hover_color: Color

@export var algae_sprites : Array[CompressedTexture2D]

var object: Node3D

var rseed := 0.0
var fish_weight := 0.0
var is_hovered := false
var is_available := false
var is_last_position := false
var current_color: Color
var target_color: Color

var pos_y := 0.0
var bump_strength := 0.0
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
	algae_sprite.set_visible(randf() < 0.2)
	#algae_sprite.material_override.set("shader_parameter/texture_albedo", algae_sprites.pick_random())

func _input(event: InputEvent) -> void:
	if not is_available or not is_hovered: return;
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == 1:
			main.character.move_to(self)

func _process(delta):
	update_color()
	last_position_sprite.set_visible(is_last_position)
	
	current_color = lerp(current_color, target_color, delta * 5.0)
	sprite_3d.material_override.set("shader_parameter/color", current_color)
	last_position_sprite.material_override.set("shader_parameter/color", current_color)
	algae_sprite.material_override.set("shader_parameter/color", current_color.lightened(0.4))
	cube.material_override.set("albedo_color", current_color.darkened(0.6))
	
	scale = lerp(scale, Vector3.ONE, delta * 5.0)
	
	bump_strength = lerp(bump_strength, 0.0, delta)
	global_position.y = lerp(global_position.y, pos_y + sin(main.get_time() * TAU + global_position.x) * 0.2 * bump_strength, delta * 5.0)
	
	if object: object.global_position.y = global_position.y
	if main.character.target_tile == self: main.character.global_position.y = global_position.y
	
func bump(size:=1.2):
	scale = Vector3(size, 1.0/size, size);
	global_position.y -= size / 5.0
	bump_strength = size
	
func get_color() -> Color:
	if not is_available: return main.colors.current_color.darkened(0.8)
	if is_hovered: return hover_color
	return available_color if main.combo < 1 else main.colors.current_color
	
func update_color():
	target_color = get_color()
	sprite_3d.shaded = not (is_available and is_hovered)

func get_player_directions_tiles():
	var player_pos = main.grid.world_to_grid_position(main.character.global_position)
	var directions = []
	var horizontal = main.character.global_position.x - global_position.x
	var horizontal_direction = Vector2.LEFT if horizontal > 0 else Vector2.RIGHT
	var vertical =  main.character.global_position.y - global_position.y
	var vertical_direction = Vector2.UP if horizontal > 0 else Vector2.DOWN
	
	if abs(vertical) > abs(horizontal): directions = [horizontal_direction, vertical_direction]
	else: directions = [vertical_direction, horizontal_direction]
	if horizontal == 0.0: directions.erase(horizontal)
	if vertical == 0.0: directions.erase(vertical)
	
	directions = directions.map(func(d): return main.grid.get_tile(player_pos + d)).filter(func(a): return a and not a.object)
	return directions

func is_empty():
	return not object and self != main.character.target_tile
