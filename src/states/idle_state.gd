extends PlayerState


func enter() -> void:
	player.set_ground_locomotion_blend_immediate(0.0)
	var animation_state_machine = animation_tree["parameters/playback"]
	animation_state_machine.travel("Ground")


func physics_update(delta: float) -> StringName:
	if not player.is_on_floor():
		return &"Fall"

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir.length_squared() > 0.01:
		return &"Move"

	if Input.is_action_just_pressed("ui_accept"):
		return &"Jump"
	
	var gravity_direction = player.gravity_component.get_current_gravity().normalized()

	var velocity_gravity = gravity_direction * player.velocity.dot(gravity_direction)
	var velocity_plane = player.velocity - velocity_gravity
	velocity_plane = velocity_plane.move_toward(Vector3.ZERO, MOVE_SPEED * delta * 12.0)

	player.velocity = velocity_gravity + velocity_plane
	player.move_and_slide()
	player.update_ground_locomotion_blend(0.0, delta)
	return &""
