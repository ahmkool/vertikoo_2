class_name MovementComponent
extends Node

@export var gravity_component: GravityComponent

func get_move_direction(input_dir: Vector2) -> Vector3:
	var frame = gravity_component.get_gravity_frame()
	var forward = frame["forward"]
	var right = frame["right"]
	var move_direction = forward * -input_dir.y + right * input_dir.x
	return move_direction.normalized()

var gravity_align_speed := 10.0

func align_to_gravity(delta: float) -> void:
	var player = get_parent() as PlayerCharacter
	var g := gravity_component.get_current_gravity()
	if g.length_squared() < 0.000001:
		return
	var target_up := -g.normalized()
	# Keep current facing as much as possible, but constrained to plane orthogonal to up.
	var current_forward = -player.global_transform.basis.z
	var forward_on_plane = (current_forward - target_up * current_forward.dot(target_up)).normalized()
	# Fallback if forward is almost parallel to up.
	if forward_on_plane.length_squared() < 0.0001:
		var frame := gravity_component.get_gravity_frame()
		forward_on_plane = frame["forward"]
	var target_right = forward_on_plane.cross(target_up).normalized()
	var arrow_length = 2.0
	DebugDraw3D.draw_arrow(player.global_position, player.global_position + target_right * arrow_length, Color.RED, 0.2)
	var target_forward = target_up.cross(target_right).normalized()
	DebugDraw3D.draw_arrow(player.global_position, player.global_position + target_forward * arrow_length, Color.GREEN, 0.2)
	var target_basis = Basis(target_right, target_up, -target_forward).orthonormalized()
	player.global_transform.basis = target_basis.orthonormalized()
	# Still required for CharacterBody floor logic.
	player.up_direction = target_up
	DebugDraw3D.draw_arrow(player.global_position, player.global_position + player.up_direction * arrow_length, Color.BLUE, 0.2)
