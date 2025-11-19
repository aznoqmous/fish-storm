@tool
class_name ChargesControl extends Control
const CHARGE_CONTROL = preload("res://scenes/charge_control.tscn")
@onready var charges_container: Control = $ChargesContainer
@export var gap:= 16:
	set(value):
		gap = value
		update()
		
@export var max_charges = 0
var charges = 0
var color: Color

func _ready() -> void:
	charges_container.child_entered_tree.connect(func(_node: Node):
		update()
	)
	charges_container.child_exiting_tree.connect(func(_node: Node):
		update()
	)
	charges_container.resized.connect(update)
	build()
	
func build():
	if not charges_container: return;
	for child in charges_container.get_children(): child.queue_free()
	for i in max_charges:
		var charge_control:= CHARGE_CONTROL.instantiate() as ChargeControl
		charges_container.add_child(charge_control)
		charge_control.set_color(color)
		charge_control.set_enabled(false)

func update():
	if not charges_container: return;
	var children = charges_container.get_children()
	var _size = (charges_container.size.x - gap * (children.size() - 1.0)) / children.size()
	for i in children.size():
		var child = children[i]
		child.size.x = _size
		child.size.y = charges_container.size.y
		child.position.x = (_size + gap) * i

func gain_charge(value:=1):
	if charges >= max_charges: return;
	var current = charges_container.get_child(charges)
	current.scale = Vector2.ONE * (1.0 + value / 10.0)
	current.set_enabled(true)
	charges += value
