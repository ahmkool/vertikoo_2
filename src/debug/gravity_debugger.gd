extends CanvasLayer

@export var gravity_component: GravityComponent

const _ROTATE_DURATION := 1.0

@onready var _grid: GridContainer = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var _gravity_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/GravityLabel


func _ready() -> void:
	if gravity_component == null:
		push_warning("GravityDebugger: gravity_component is not assigned.")
		return

	_bind_button("Button", Vector3.RIGHT, 90.0)
	_bind_button("Button2", Vector3.RIGHT, 180.0)
	_bind_button("Button3", Vector3.RIGHT, 270.0)
	_bind_button("Button4", Vector3.RIGHT, 360.0)

	_bind_button("Button5", Vector3.UP, 90.0)
	_bind_button("Button6", Vector3.UP, 180.0)
	_bind_button("Button7", Vector3.UP, 270.0)
	_bind_button("Button8", Vector3.UP, 360.0)

	_bind_button("Button9", Vector3.FORWARD, 90.0)
	_bind_button("Button10", Vector3.FORWARD, 180.0)
	_bind_button("Button11", Vector3.FORWARD, 270.0)
	_bind_button("Button12", Vector3.FORWARD, 360.0)
	_update_gravity_label()


func _bind_button(button_name: String, axis: Vector3, angle_deg: float) -> void:
	var button := _grid.get_node_or_null(button_name) as Button
	if button == null:
		push_warning("GravityDebugger: missing button '%s'." % button_name)
		return
	button.pressed.connect(_on_rotate_pressed.bind(axis, angle_deg))


func _on_rotate_pressed(axis: Vector3, angle_deg: float) -> void:
	if gravity_component == null:
		return
	print("rotate_gravity_smooth: %s, %f, %f" % [axis, angle_deg, _ROTATE_DURATION])
	gravity_component.rotate_gravity_smooth(axis, deg_to_rad(angle_deg), _ROTATE_DURATION)


func _process(_delta: float) -> void:
	_update_gravity_label()


func _update_gravity_label() -> void:
	if _gravity_label == null:
		return
	if gravity_component == null:
		_gravity_label.text = "Gravity: <not assigned>"
		return
	var g := gravity_component.get_current_gravity()
	_gravity_label.text = "Gravity: (%.2f, %.2f, %.2f) | |g|=%.2f" % [g.x, g.y, g.z, g.length()]
