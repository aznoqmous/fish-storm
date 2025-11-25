class_name Combo extends Node3D
@onready var label_3d: Label3D = $Label3D

func set_combo(value):
	label_3d.text = str(value, "xcombo!")

func set_description(text):
	label_3d.text = text
	
func erase():
	queue_free()
