class_name Heart extends Node3D
@onready var sprite_3d: Sprite3D = $Sprite3D

var life := 0.0

func _ready() -> void:
	get_tree().create_tween().tween_property(sprite_3d, "scale", Vector3.ZERO, 1.0)

func _process(delta):
	life += delta
	if life > 1.0: queue_free()
	global_position.y += delta * 5.0
