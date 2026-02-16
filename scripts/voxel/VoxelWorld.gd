extends Node3D
class_name VoxelWorld

const BLOCK_SIZE: float = 1.0
const HALF_BLOCK: float = BLOCK_SIZE * 0.5

@export var material: StandardMaterial3D
@export var world_radius: int = 24
@export var max_height: int = 6

var _blocks: Dictionary = {}

func _ready() -> void:
	if material == null:
		material = StandardMaterial3D.new()
		material.albedo_color = Color(0.29, 0.34, 0.4, 1.0)
		material.roughness = 0.9
	_generate_demo_terrain()

func has_block(coord: Vector3i) -> bool:
	return _blocks.has(coord)

func world_to_block(position: Vector3) -> Vector3i:
	return Vector3i(
		floor(position.x / BLOCK_SIZE),
		floor(position.y / BLOCK_SIZE),
		floor(position.z / BLOCK_SIZE)
	)

func block_to_world(coord: Vector3i) -> Vector3:
	return Vector3(coord.x + HALF_BLOCK, coord.y + HALF_BLOCK, coord.z + HALF_BLOCK) * BLOCK_SIZE

func place_block(coord: Vector3i) -> bool:
	if _blocks.has(coord):
		return false
	if coord.y < -8 or coord.y > max_height + 16:
		return false

	var body := StaticBody3D.new()
	body.name = "Block_%s_%s_%s" % [coord.x, coord.y, coord.z]
	body.set_meta("voxel_coord", coord)
	body.add_to_group("voxel_block")
	body.position = block_to_world(coord)

	var mesh_instance := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = Vector3.ONE * BLOCK_SIZE
	mesh_instance.mesh = cube
	mesh_instance.material_override = material

	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3.ONE * BLOCK_SIZE
	collider.shape = shape

	body.add_child(mesh_instance)
	body.add_child(collider)
	add_child(body)
	_blocks[coord] = body
	return true

func break_block(coord: Vector3i) -> bool:
	if not _blocks.has(coord):
		return false
	var body: Node3D = _blocks[coord]
	_blocks.erase(coord)
	body.queue_free()
	return true

func _generate_demo_terrain() -> void:
	for x in range(-world_radius, world_radius + 1):
		for z in range(-world_radius, world_radius + 1):
			var height := int(2.0 + sin(float(x) * 0.16) * 1.6 + cos(float(z) * 0.13) * 1.6)
			height = clampi(height, 0, max_height)
			for y in range(0, height + 1):
				place_block(Vector3i(x, y, z))

	for y in range(1, 8):
		place_block(Vector3i(6, y, 6))
		if y < 6:
			place_block(Vector3i(6, y, 7))
