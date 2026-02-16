extends CharacterBody3D
class_name PlayerController

@export var mouse_sensitivity: float = 0.0022
@export var walk_speed: float = 4.5
@export var sprint_speed: float = 8.6
@export var crouch_speed: float = 3.0
@export var acceleration: float = 20.0
@export var air_acceleration: float = 6.0
@export var jump_velocity: float = 6.8
@export var gravity_scale: float = 1.0
@export var crouch_height: float = 1.15
@export var standing_height: float = 1.8
@export var slide_duration: float = 0.65
@export var mantle_height: float = 1.2
@export var hurdle_forward_boost: float = 3.0
@export var interact_range: float = 7.5
@export var build_min_distance: float = 1.2
@export var build_max_height_delta: float = 1.2
@export var world_path: NodePath

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var _yaw: float
var _pitch: float
var _is_crouching: bool = false
var _is_sliding: bool = false
var _slide_timer: float = 0.0
var _slide_direction: Vector3 = Vector3.ZERO
var _target_head_y: float = 1.55

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_yaw = rotation.y
	_pitch = head.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch = clamp(_pitch - event.relative.y * mouse_sensitivity, -1.2, 1.15)
		rotation.y = _yaw
		head.rotation.x = _pitch

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("capture_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event.is_action_pressed("break_block"):
		_edit_block(false)
	if event.is_action_pressed("place_block"):
		_edit_block(true)

func _physics_process(delta: float) -> void:
	var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float
	if not is_on_floor():
		velocity.y -= gravity * gravity_scale * delta

	_update_stance(delta)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	elif Input.is_action_just_pressed("jump") and _attempt_mantle_or_hurdle():
		pass

	if Input.is_action_just_pressed("crouch") and Input.is_action_pressed("sprint") and is_on_floor() and velocity.length() > walk_speed:
		_begin_slide()

	if _is_sliding:
		_slide_timer -= delta
		if _slide_timer <= 0.0:
			_is_sliding = false
		velocity.x = _slide_direction.x * sprint_speed
		velocity.z = _slide_direction.z * sprint_speed
	else:
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var local_move := Vector3(input_dir.x, 0.0, input_dir.y)
		var world_move := (global_transform.basis * local_move)
		world_move.y = 0.0
		world_move = world_move.normalized()

		var target_speed := _current_speed()
		var target_velocity := world_move * target_speed
		var accel := acceleration if is_on_floor() else air_acceleration

		velocity.x = move_toward(velocity.x, target_velocity.x, accel * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, accel * delta)

	move_and_slide()

func _current_speed() -> float:
	if _is_crouching:
		return crouch_speed
	if Input.is_action_pressed("sprint"):
		return sprint_speed
	return walk_speed

func _update_stance(delta: float) -> void:
	_is_crouching = Input.is_action_pressed("crouch") or _is_sliding

	var shape := collision.shape as CapsuleShape3D
	var target_height := crouch_height if _is_crouching else standing_height
	shape.height = move_toward(shape.height, target_height, delta * 6.0)

	_target_head_y = 1.0 if _is_crouching else 1.55
	head.position.y = move_toward(head.position.y, _target_head_y, delta * 7.5)

func _begin_slide() -> void:
	_is_sliding = true
	_slide_timer = slide_duration
	_is_crouching = true
	_slide_direction = Vector3(velocity.x, 0, velocity.z).normalized()
	if _slide_direction == Vector3.ZERO:
		_slide_direction = -global_transform.basis.z.normalized()

func _attempt_mantle_or_hurdle() -> bool:
	var state := get_world_3d().direct_space_state
	var up := Vector3.UP
	var forward := -global_transform.basis.z.normalized()
	var origin := global_position + up * 1.05

	var lower_query := PhysicsRayQueryParameters3D.create(origin, origin + forward * 0.9)
	lower_query.exclude = [self]
	var lower_hit := state.intersect_ray(lower_query)
	if lower_hit.is_empty():
		return false

	var upper_origin := global_position + up * (1.05 + mantle_height)
	var upper_query := PhysicsRayQueryParameters3D.create(upper_origin, upper_origin + forward * 0.9)
	upper_query.exclude = [self]
	var upper_hit := state.intersect_ray(upper_query)

	if upper_hit.is_empty():
		var landing_query := PhysicsRayQueryParameters3D.create(global_position + forward * 0.9 + up * 2.6, global_position + forward * 0.9 - up * 1.0)
		landing_query.exclude = [self]
		var landing_hit := state.intersect_ray(landing_query)
		if not landing_hit.is_empty():
			global_position = global_position + forward * 0.7 + up * 0.85
			velocity.y = jump_velocity * 0.75
			return true
		return false

	velocity += forward * hurdle_forward_boost + up * 2.2
	return true

func _edit_block(should_place: bool) -> void:
	var world := get_node_or_null(world_path) as VoxelWorld
	if world == null:
		return

	var from := camera.global_position
	var to := from + -camera.global_transform.basis.z * interact_range
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return

	var collider := hit.get("collider") as Node
	if collider == null or not collider.has_meta("voxel_coord"):
		return

	var coord: Vector3i = collider.get_meta("voxel_coord")
	if should_place:
		if not is_on_floor():
			return
		var place_coord := world.world_to_block(hit.position + hit.normal * 0.5)
		if place_coord == world.world_to_block(global_position):
			return

		var place_world := world.block_to_world(place_coord)
		var feet := global_position
		var chest := global_position + Vector3.UP * 1.2
		if place_world.distance_to(feet) < build_min_distance or place_world.distance_to(chest) < build_min_distance:
			return
		if place_world.y > global_position.y + build_max_height_delta:
			return

		world.place_block(place_coord)
	else:
		world.break_block(coord)
