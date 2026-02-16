extends Node3D

@onready var spawn_point: Marker3D = $SpawnPoint

func _ready() -> void:
	print("Tera world bootstrap ready at spawn:", spawn_point.global_position)
