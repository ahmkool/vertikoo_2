extends PlayerState

const FALL_TRANSITION_GRACE := 0.3
var _off_floor_time := 0.0


func enter() -> void:
	_off_floor_time = 0.0


func physics_update(delta: float) -> StringName:
	if not player.is_on_floor():
		_off_floor_time += delta
		player.apply_air_gravity(delta)
		player.move_and_slide()
		if _off_floor_time >= FALL_TRANSITION_GRACE:
			return &"Fall"
		return &""
	_off_floor_time = 0.0

	if Input.is_action_just_pressed("ui_accept"):
		return &"Jump"

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir.length_squared() < 0.01:
		return &"Idle"
	
	var gravity_direction = player.gravity_component.get_current_gravity().normalized()

	var velocity_gravity = gravity_direction * player.velocity.dot(gravity_direction)

	var direction: Vector3 = player.movement_component.get_move_direction(input_dir)
	player.smooth_rotate_toward_move_direction(direction, delta)
	var velocity_plane = direction * MOVE_SPEED
	player.velocity = velocity_gravity + velocity_plane
	player.move_and_slide()

	var run_amount := clampf(input_dir.length(), 0.0, 1.0)
	player.update_ground_locomotion_blend(run_amount, delta)
	return &""
