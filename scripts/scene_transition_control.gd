class_name SceneTransitionControl extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func open():
	set_visible(true)
	animation_player.play("open")
	await animation_player.animation_finished
	
func close():
	animation_player.play("close")
	await animation_player.animation_finished
	set_visible(false)
