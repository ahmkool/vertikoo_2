class_name GravityComponent
extends Node

@export var gravity_strength: float = 9.8
var base_gravity_dir = Vector3.DOWN
var gravity_rotation: Quaternion = Quaternion.IDENTITY
@onready var gravityCoreHandler: GravityCoreHandler = $GravityCoreHandler

var _spin_axis := Vector3.ZERO
var _spin_total_angle := 0.0
var _spin_applied_angle := 0.0
var _spin_t := 1.0
var _spin_duration := 0.0

func get_current_gravity() -> Vector3:
	var direction = (Basis(gravity_rotation) * base_gravity_dir).normalized()
	return direction * gravity_strength

func rotate_gravity_smooth(axis: Vector3, angle_rad: float, duration: float) -> void:
	var a := axis.normalized()
	if a.length_squared() < 0.000001:
		return

	_spin_axis = a
	_spin_total_angle = angle_rad
	_spin_applied_angle = 0.0
	_spin_duration = max(duration, 0.0001)
	_spin_t = 0.0

func _physics_process(delta: float) -> void:
	_try_trigger_gravity_shift()

	if _spin_t >= 1.0:
		return
	
	_spin_t = min(_spin_t + delta / _spin_duration, 1.0)

	# Apply only the missing angular increment this frame
	var target_applied := _spin_total_angle * _spin_t
	var delta_angle := target_applied - _spin_applied_angle
	_spin_applied_angle = target_applied

	if absf(delta_angle) > 0.0:
		var dq := Quaternion(_spin_axis, delta_angle)
		gravity_rotation = (dq * gravity_rotation).normalized()


func _try_trigger_gravity_shift() -> void:
	if not Input.is_action_just_pressed("gravity_shift"):
		return
	if _spin_t < 1.0:
		return
	if gravityCoreHandler == null:
		return

	var gravity_core := gravityCoreHandler.current_gravity_core
	if gravity_core == null:
		return
	if gravity_core.shifts.is_empty():
		return

	var shift := gravity_core.shifts[0]
	if shift == null:
		return

	rotate_gravity_smooth(shift.axis, deg_to_rad(shift.angle_deg), shift.duration)

func get_gravity_frame() -> Dictionary:
	var player = get_parent() as PlayerCharacter
	var up = -get_current_gravity().normalized()

	var camera_forward = -player.look_pivot.global_transform.basis.z

	var forward = (camera_forward - up * camera_forward.dot(up)).normalized()

	if forward.length_squared() < 0.0001:
		forward = (player.transform.basis.z * -1.0 - up * (-player.transform.basis.z).dot(up)).normalized()
	
	var right = forward.cross(up).normalized()

	return {
		"up": up,
		"forward": forward,
		"right": right,
	}
