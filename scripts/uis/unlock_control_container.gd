class_name UnlockControlContainer extends Control
@onready var v_box_container: VBoxContainer = $VBoxContainer
const UNLOCK_CONTROL = preload("uid://coi6pa3wr02p4")

func _ready() -> void:
	for child in v_box_container.get_children(): child.queue_free()

func display_unlock(character: CharacterResource):
	var uc := UNLOCK_CONTROL.instantiate() as UnlockControl
	v_box_container.add_child(uc)
	uc.load_character(character)
	await get_tree().create_timer(3.0).timeout
	uc.queue_free()
