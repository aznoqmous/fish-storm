class_name Character extends Node3D

@onready var main: Main = $/root/Main
@onready var sprite_container: Node3D = $SpriteContainer
@onready var sprite_3d: Sprite3D = $SpriteContainer/Sprite3D
@onready var shadow: Sprite3D = $Shadow
@onready var character_moves_left_label: Label3D = $SpriteContainer/Sprite3D/CharacterMovesLeftLabel

var last_jump: float
var jump_life: float
@export var jump_duration: float = 0.3
@export var jump_height: float = 1.0
var target_position: Vector3
var start_jump_position: Vector3
var target_tile: Tile

var is_jumping: float:
	get: return jump_life <  1.0
	
func _input(event: InputEvent) -> void:
	if is_jumping: return;
	if event is InputEventKey:
		var movement = Vector2.ZERO
		if event.is_action_pressed("MoveForward"): movement += Vector2.UP
		if event.is_action_pressed("MoveBack"): movement += Vector2.DOWN
		if event.is_action_pressed("MoveLeft"): movement += Vector2.LEFT
		if event.is_action_pressed("MoveRight"): movement += Vector2.RIGHT
		
		var current_position = main.grid.world_to_grid_position(target_position)
		var new_target = main.grid.get_tile(current_position + movement)

		if not new_target: return;
		if target_tile != new_target:
			move_to(new_target)

func move_to(tile: Tile):
	if main.moves_left <= 0: return
	
	target_tile = tile
	target_position = tile.global_position
	last_jump = Time.get_ticks_msec() / 1000.0
	start_jump_position = global_position
	sprite_3d.scale = Vector3(1.0 / 1.2, 1.2, 1.0)
	
func set_tile(tile: Tile):
	target_tile = tile
	target_position = tile.global_position
	global_position = target_tile.global_position
	
func _process(delta: float) -> void:
	#global_position = lerp(global_position, target_position, delta * 5.0)
	if target_tile and is_jumping and (Time.get_ticks_msec() / 1000.0 - last_jump) / jump_duration > 1.0:
		global_position = target_tile.global_position
		moved.emit()
		
		
	jump_life = (Time.get_ticks_msec() / 1000.0 - last_jump) / jump_duration
	
	if is_jumping:
		#global_position.y = sin(jump_life * TAU / 2.0) * jump_height + lerp(start_jump_position.y, target_position.y, jump_life)
		global_position = lerp(start_jump_position, target_position, jump_life)
		sprite_container.position.y = sin(jump_life * TAU / 2.0) * jump_height
		shadow.scale = Vector3.ONE * cos(jump_life * TAU / 2.0) * 0.8
	else:
		global_position = target_position
		
	sprite_3d.scale = lerp(sprite_3d.scale, Vector3.ONE, delta * 5.0)
	character_moves_left_label.scale = lerp(character_moves_left_label.scale, Vector3.ONE, delta * 5.0)
	
signal moved
