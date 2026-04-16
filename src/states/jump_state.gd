extends PlayerState


func enter() -> void:
	var gravity_direction = player.gravity_component.get_current_gravity().normalized()
	var velocity_gravity = gravity_direction * player.velocity.dot(gravity_direction)
	player.velocity = velocity_gravity - gravity_direction * player.jump_velocity
	var animation_state_machine = animation_tree["parameters/playback"]
	animation_state_machine.travel("JumpUp")


func physics_update(delta: float) -> StringName:
	var gravity_direction = player.gravity_component.get_current_gravity().normalized()

	var velocity_gravity = gravity_direction * player.velocity.dot(gravity_direction)
	var velocity_plane = player.velocity - velocity_gravity

	var velocity_along_gravity = velocity_gravity.dot(gravity_direction)

	if velocity_along_gravity > 0.0:
		return &"Fall"

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir.length_squared() > 0.01:
		var direction: Vector3 = player.movement_component.get_move_direction(input_dir)
		player.smooth_rotate_toward_move_direction(direction, delta)
		velocity_plane = direction * MOVE_SPEED
	else:
		velocity_plane = velocity_plane.move_toward(Vector3.ZERO, MOVE_SPEED * delta * 8.0)

	player.velocity = velocity_gravity + velocity_plane
	player.apply_air_gravity(delta)
	player.move_and_slide()
	if player.is_on_floor():
		return &"Idle"
	var blend_target := clampf(input_dir.length(), 0.0, 1.0) if input_dir.length_squared() > 0.01 else 0.0
	player.update_ground_locomotion_blend(blend_target, delta)
	return &""
