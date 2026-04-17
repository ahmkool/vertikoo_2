class_name PlayerCharacter
extends CharacterBody3D

@onready var look_pivot: Node3D = $LookPivot
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var _body_visual: Node3D = $Root

## Higher = snappier turn toward move direction (camera-relative), similar to UE mannequin feel.
@export var facing_rotation_strength := 10.0
## Add PI/2 etc. if the mesh faces a different default axis than movement.
@export var facing_yaw_offset := 0.0

## Ground state BlendSpace1D: 0 = idle, 1 = run. Higher = faster blend toward target.
@export var ground_locomotion_blend_speed := 10.0

## Initial upward speed when leaving the ground (higher = taller jump).
@export var jump_velocity := 11.0
## Gravity multiplier while moving upward and jump is still held (apex control).
@export var gravity_scale_rising := 1.15
## Gravity multiplier while falling — higher = less float, snappier landings.
@export var gravity_scale_falling := 2.65
## Extra gravity while still moving up but jump is released (short hop / Mario-style cut).
@export var gravity_scale_jump_cut := 3.2

@onready var gravity_component: GravityComponent = $GravityComponent
@onready var movement_component: MovementComponent = $MovementComponent


func _physics_process(delta: float) -> void:
	movement_component.align_to_gravity(delta)

const _GROUND_BLEND_PARAM := &"parameters/Ground/blend_position"

var _ground_locomotion_blend := 0.0

## Smoothly yaw the mesh toward horizontal movement (world XZ), without rotating the camera rig.
func smooth_rotate_toward_move_direction(direction: Vector3, delta: float) -> void:
	# Gravity defines "up" in your current world orientation.
	var g := gravity_component.get_current_gravity()
	if g.length_squared() < 0.000001:
		return
	var up := -g.normalized()

	# Keep only movement on the plane perpendicular to gravity.
	var move_on_plane := direction - up * direction.dot(up)
	if move_on_plane.length_squared() < 0.0001:
		return
	move_on_plane = move_on_plane.normalized()

	# Build a target basis where -Z looks along movement direction.
	var target_forward := move_on_plane
	var target_right := up.cross(target_forward).normalized()
	if target_right.length_squared() < 0.0001:
		return
	target_forward = up.cross(target_right).normalized()

	var target_basis := Basis(target_right, up, -target_forward).orthonormalized()

	# Smoothly rotate visual toward target basis.
	var w := 1.0 - exp(-facing_rotation_strength * delta)
	_body_visual.global_transform.basis = _body_visual.global_transform.basis.slerp(target_basis, w).orthonormalized()


func set_ground_locomotion_blend_immediate(amount: float) -> void:
	if animation_tree == null:
		return
	_ground_locomotion_blend = clampf(amount, 0.0, 1.0)
	animation_tree.set(_GROUND_BLEND_PARAM, _ground_locomotion_blend)


## Smooth 0–1 blend for the Ground state's BlendSpace1D (idle ↔ run).
func update_ground_locomotion_blend(target: float, delta: float) -> void:
	if animation_tree == null:
		return
	target = clampf(target, 0.0, 1.0)
	_ground_locomotion_blend = move_toward(
		_ground_locomotion_blend,
		target,
		ground_locomotion_blend_speed * delta
	)
	animation_tree.set(_GROUND_BLEND_PARAM, _ground_locomotion_blend)

## Airborne gravity with asymmetric rise/fall and optional jump-cut when releasing jump early.
func apply_air_gravity(delta: float) -> void:
	var g := gravity_component.get_current_gravity()
	var mult: float
	var velocity_along_gravity: float = velocity.dot(g)
	# Positive along gravity = moving downward (falling). Negative = moving upward (rising).
	if velocity_along_gravity >= 0.0:
		mult = gravity_scale_falling
	else:
		# While moving upward, releasing jump applies stronger gravity for short hops.
		if Input.is_action_pressed("ui_accept"):
			mult = gravity_scale_rising
		else:
			mult = gravity_scale_jump_cut
	velocity += g * mult * delta
