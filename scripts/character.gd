class_name Character extends Node3D

@onready var main: Main = $/root/Main
@onready var sprite_container: Node3D = $SpriteContainer
@onready var shadow: Sprite3D = $Shadow
@onready var body_sprite: Sprite3D = $SpriteContainer/BodySprite
@onready var head_sprite: Sprite3D = $SpriteContainer/HeadSprite
@onready var character_moves_left_label: Label3D = $SpriteContainer/CharacterMovesLeftLabel
@onready var jump_launch_audio: AudioStreamPlayer = $JumpLaunchAudio
@onready var jump_land_audio: AudioStreamPlayer = $JumpLandAudio
@onready var damage_particles_3d: GPUParticles3D = $SpriteContainer/DamageParticles3D

var last_jump: float
var jump_life: float
@export var jump_duration: float = 0.3
@export var jump_height: float = 1.0
var target_position: Vector3
var start_jump_position: Vector3
var target_tile: Tile
var flip_sprites := false
var last_position: Vector3

var is_jumping: float:
	get: return jump_life <  1.0

var upgrades_list : Dictionary[ObjectResource, int]

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
		
		if not new_target or not new_target.is_available: return;
		if target_tile != new_target:
			move_to(new_target)

func move_to(tile: Tile):
	if is_jumping: return;
	if main.moves_left <= 0: return
	last_position = global_position
	jump_launch_audio.play()
	target_tile = tile
	target_position = tile.global_position
	last_jump = Time.get_ticks_msec() / 1000.0
	start_jump_position = global_position
	sprite_container.scale = Vector3(1.0 / 1.2, 1.2, 1.0)
	var signn = sign(tile.global_position.x - global_position.x)
	if signn != 0.0:
		flip_sprites = signn < 0
	
func set_tile(tile: Tile):
	target_tile = tile
	target_position = tile.global_position
	global_position = target_tile.global_position
	jump_life = 1.0
	
func _process(delta: float) -> void:
	if target_tile and is_jumping and (main.get_time() - last_jump) / jump_duration > 1.0:
		global_position = target_tile.global_position
		moved.emit()
		jump_land_audio.play()
		
	head_sprite.rotation.y = lerp(head_sprite.rotation.y, PI if flip_sprites else 0.0, delta * 10.0)
	body_sprite.rotation.y = lerp(body_sprite.rotation.y, PI if flip_sprites else 0.0, delta * 10.0)
	jump_life = (main.get_time() - last_jump) / jump_duration

	
	if is_jumping:
		global_position = lerp(start_jump_position, target_position, jump_life)
		sprite_container.position.y = sin(jump_life * TAU / 2.0) * jump_height
		shadow.scale = Vector3.ONE * cos(jump_life * TAU / 2.0) * 0.8
	else:
		global_position = target_position
		
	sprite_container.scale = lerp(sprite_container.scale, Vector3.ONE, delta * 5.0)
	character_moves_left_label.scale = lerp(character_moves_left_label.scale, Vector3.ONE, delta * 5.0)
	body_sprite.material_override.set("shader_parameter/color", main.colors.current_color.darkened(0.5).lightened(min(main.combo / 10.0 / 5.0, 0.5)))

func load_resource(res: CharacterResource):
	head_sprite.material_override.set("shader_parameter/texture_albedo", res.head_sprite)

func add_upgrade(upgrade: ObjectResource):
	if not upgrades_list.has(upgrade): upgrades_list[upgrade] = 0
	upgrades_list[upgrade] += 1

signal moved
