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


## its expected that node uses mesh forward

func get_relative_pitch(node: Node3D) -> float:
	# pitch -1 = down, 1 = up, 0 = horizontile circle
	var pitch_scale: float = (-node.basis.z).dot(basis.y) # using basis.y keeps 1s as vertical and prevents rotation on y axis from changing pitch value
	var pitch: float = lerpf(0.0, 90.0, pitch_scale) # convert: -90 to 90
	var upside_down: bool = node.basis.y.dot(basis.y) < 0 # neg if upside down
	if upside_down:
		pitch = (90 + (90 - pitch)) if pitch_scale > 0.0 \
		else (-90 - (90 + pitch))
	#print( pitch ) # 0 - 180, pos = up, neg = down
	return pitch

# NOTE: get_relative_yaw and get_relative_roll are not used
func get_relative_yaw(node: Node3D) -> float:
	# yaw -1 = left, 1 = right, 0 = vertical circle
	var y: float = -(-node.basis.z).dot(basis.x)
	var yaw: float = lerpf(0.0, 90.0, y) # -90 to 90
	var face_backwards = node.basis.x.dot(basis.x) > 0 # pos if looking back
	if face_backwards:
		yaw = (90 + (90 - yaw)) if y > 0.0 \
		else (-90 - (90 + yaw))
	#print( yaw ) # 0 - 180, pos = right, neg = left
	return yaw

func get_relative_roll(node: Node3D) -> float:
	# range of 0-1.57 rad (0-90 deg)
	# positive if right, negative if left
	var roll: float = abs(fmod(node.rotation.z, TAU))
	if roll > TAU/4.0:
		if roll < TAU/2.0:
			roll = TAU/4.0 - (roll - TAU/4.0) # 90 to 0 deg
		elif roll < TAU - TAU/4.0:
			roll -= TAU/2.0 # 0 to 90 deg
			roll *= -1.0
		else:
			roll = TAU/2.0 - (roll - TAU/2.0) # 90 to 0 deg
			roll *= -1.0
	#print(roll) 
	return roll
