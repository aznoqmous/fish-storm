class_name Fish extends Node3D
@onready var sprite_container: Node3D = $ShadowSpriteContainer/SpriteContainer
@onready var shadow_sprite_container: Node3D = $ShadowSpriteContainer
@onready var splash_particles: GPUParticles3D = $SplashParticles

var animation := 0.0
var animation_height := 5.0
var animation_depth := -10.0

func _ready() -> void:
	animation_depth = randf_range(-10, -6)
	shadow_sprite_container.position.y = 0
	shadow_sprite_container.position.z = animation_depth
	shadow_sprite_container.scale = Vector3.ZERO
	splash_particles.global_position = shadow_sprite_container.global_position
	splash_particles.emitting = true
func _process(delta: float) -> void:
	if animation < 1.0:
		animation += delta
		shadow_sprite_container.position.y = sin(animation * PI) * animation_height
		shadow_sprite_container.position.z = lerp(animation_depth, 0.0, animation)
		shadow_sprite_container.scale = lerp(Vector3.ZERO, Vector3.ONE, animation)
		
