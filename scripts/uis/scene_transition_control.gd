class_name SceneTransitionControl extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_opened: bool = true
func open():
	if is_opened: return true
	set_visible(true)
	animation_player.play("open")
	await animation_player.animation_finished
	is_opened = true
	
func close():
	if not is_opened: return true
	animation_player.play("close")
	await animation_player.animation_finished
	set_visible(false)
	is_opened = false
