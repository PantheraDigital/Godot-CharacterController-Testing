extends Node3D
class_name VelocityIndicator


var _character: CharacterBody3D 
#var _collision_shape_3d: RotationFollower
var _movement_flight: MovementFlying


func _ready() -> void:
	_character = get_parent()
	#_collision_shape_3d = _character.find_child("CollisionShape3D", false)
	_movement_flight = _character.find_child("MovementStateManager", false).find_child("FlyingMovement", false)
	_movement_flight.velocity_set.connect(_face_point)

func _process(_delta: float) -> void:
	global_position = _character.global_position
	
	DebugDraw3D.draw_line(global_position, global_position + (basis.x), Color.DARK_RED)
	DebugDraw3D.draw_line(global_position, global_position + (basis.y), Color.SEA_GREEN)
	DebugDraw3D.draw_line(global_position, global_position + (basis.z), Color.ROYAL_BLUE)

func _face_point(point: Vector3) -> void:
	if point.is_equal_approx(Vector3.ZERO) or is_equal_approx(point.z, 1.0):
		return
	
	quaternion = Quaternion(Vector3.FORWARD, point).normalized()
	rotation.z = 0
	
	# old method of rotation
	#var up: Vector3 = Vector3.UP#_collision_shape_3d.basis.y
	#if point.is_equal_approx(global_transform.origin) or point.cross(up).is_zero_approx():
		#return
	#global_transform = global_transform.looking_at(point, up, true).orthonormalized()
