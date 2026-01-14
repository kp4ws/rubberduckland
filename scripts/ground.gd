extends MeshInstance3D

@export var scroll_speed := Vector2(0.2, 0.0)

func _process(delta: float) -> void:
	var mat := get_active_material(0)
	if mat and mat is StandardMaterial3D:
		mat.uv1_offset += scroll_speed * delta
