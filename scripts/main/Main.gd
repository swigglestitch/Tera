extends Node3D

func _ready() -> void:
	print("Tera prototype loaded: traversal-focused voxel sandbox")
@onready var spawn_point: Marker3D = $SpawnPoint

func _ready() -> void:
	print("Tera world bootstrap ready at spawn:", spawn_point.global_position)
