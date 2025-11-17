@tool
class_name ChargesControl extends Control

@onready var charges_container: Control = $ChargesContainer
@export var gap:= 16:
	set(value):
		gap = value
		update()
func _ready() -> void:
	charges_container.child_entered_tree.connect(func(_node: Node):
		update()
	)
	charges_container.child_exiting_tree.connect(func(_node: Node):
		update()
	)
	charges_container.resized.connect(update)
func update():
	var children = charges_container.get_children()
	var _size = (charges_container.size.x - gap * (children.size() - 1.0)) / children.size()
	for i in children.size():
		var child = children[i]
		child.size.x = _size
		child.size.y = charges_container.size.y
		child.position.x = (_size + gap) * i
