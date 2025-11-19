extends Node3D
class_name RotationFollower


func _process(_delta: float) -> void:
	DebugDraw3D.draw_line(global_position, global_position + (basis.x), Color.DARK_RED)
	DebugDraw3D.draw_line(global_position, global_position + (basis.y), Color.SEA_GREEN)
	DebugDraw3D.draw_line(global_position, global_position + (basis.z), Color.ROYAL_BLUE)


func face_point(point: Vector3, _use_pitch: bool = false, _lerp_val: float = 1.0) -> void:
	var target_point: Vector3 = point if _use_pitch else Vector3(point.x, 0.0, point.z)
	if target_point.is_equal_approx(Vector3.ZERO):
		return
	var target_quat: Quaternion = Quaternion(Vector3.FORWARD, target_point).normalized()
	
	_lerp_val = clampf(_lerp_val, 0.0, 1.0)
	quaternion = target_quat if is_equal_approx(_lerp_val, 1.0) else \
				quaternion.slerp(target_quat, _lerp_val)
