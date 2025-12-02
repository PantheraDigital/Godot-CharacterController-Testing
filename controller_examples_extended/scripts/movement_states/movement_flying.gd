extends MovementState
class_name MovementFlying


signal velocity_set(velocity: Vector3)

enum Setting {PHYSICS, FIXED}

var _character: CharacterBody3D 
var _collision_shape_3d: RotationFollower
var _velocity_indicator: VelocityIndicator
var _setting: Setting = Setting.PHYSICS
var gravity: bool = false
var drag: float = 1.0
var mass: float = 1.0

@export var lift_curve: Curve
@export var drag_curve: Curve


func _ready() -> void:
	if get_parent() is CharacterBody3D:
		_character = get_parent()
	else:
		_character = get_parent().get_parent()
	
	_collision_shape_3d = _character.find_child("CollisionShape3D", false)
	_velocity_indicator = _character.find_child("VelocityIndicator", false)
	
	super._ready()

func _physics_process(_delta: float) -> void:
	match _setting:
		Setting.FIXED:
			process_fixed_flight(_delta)
		Setting.PHYSICS:
			process_phys_flight(_delta)
	
	clear_velocity()

func process_fixed_flight(_delta: float) -> void:
	if input_velocity:
		_character.velocity = input_velocity
	elif drag:
		_character.velocity.x = move_toward(_character.velocity.x, 0.0, drag)
		_character.velocity.z = move_toward(_character.velocity.z, 0.0, drag)
	
	if gravity:
		_character.velocity += (_character.get_gravity() * mass) * _delta
	
	_character.move_and_slide()

func process_phys_flight(_delta: float) -> void:
	# NOTE: this system is using the collider as the chord line of the plane
	# the user directly controlls the angle of the collider thus changing the chord direction and angle of attack
	# this also means the chord is a fixed length
	#
	# systems may be added to include flaps for changing the chord size and angle to better simulate a plane
	
	var wing_area: float = 2.0
	var pitch: float = _get_relative_pitch(_velocity_indicator, _collision_shape_3d) # _collision_shape_3d will act as the chord line of the plane
	
	var lift: Vector3 = Vector3.ZERO
	var drag: Vector3 = Vector3.ZERO
	var thrust: Vector3 = Vector3.ZERO
	var weight: Vector3 = _character.get_gravity()
	var vel_adjusted: Vector3 = _character.velocity
	
	
	if input_velocity:
		thrust = input_velocity
	vel_adjusted += thrust
	
	# lift/drag formula
	# lift = lift_coefficient * (0.5 * velocity^2) * wing_area * air_density
	
	# use only forward velocity where forward is the direction of collision shape basis.z
	# this makes it so that if the collider is facing global forward but falling allong the global y axis, its speed_adjusted will be 0 as all momentum is pointing down
	#var speed_adjusted: float = (_character.velocity.project(_collision_shape_3d.basis.z.normalized())).length()
	
	var lift_pch: float = clampf(pitch, -lift_curve.max_domain, lift_curve.max_domain)
	var lift_co: float = ( lift_curve.sample(abs(lift_pch)) * -1.0 ) if lift_pch < 0 else ( lift_curve.sample(abs(lift_pch)) )
	
	var lift_mag: float = lift_co * (0.5 * pow(vel_adjusted.length(), 2)) * wing_area
	var lift_dir: Vector3 = _velocity_indicator.basis.y.normalized() #_velocity_indicator.basis.y.normalized().rotated(_velocity_indicator.basis.z, _collision_shape_3d.rotation.z)
	lift = lift_dir * lift_mag
	printt(lift_pch)
	
	
	var drag_co: float = drag_curve.sample(abs( clampf(pitch, -drag_curve.max_domain, drag_curve.max_domain) ))
	var drag_mag: float = drag_co * (0.5 * pow(vel_adjusted.length(), 2))
	var drag_dir: Vector3 = (_velocity_indicator.basis.z).normalized()
	drag = drag_dir * drag_mag
	
	
	# terminal velocity = sqrt( (2 * m * g) / (air_density * object_area * drag_coefficient) )
	var terminal_vel: float = (2 * _character.get_gravity().length()) / drag_co
	
	_character.velocity += (weight + lift + drag) * _delta
	if _character.velocity.y < -terminal_vel: # move back to terminal vel based speed of on drag
		_character.velocity.y = move_toward(_character.velocity.y ,-terminal_vel, drag_mag)
	
	# thrust can overcome terminal velocity so it is added after
	_character.velocity += thrust
	_character.move_and_slide()
	
	# keep updates based on velocity after velocity is set
	velocity_set.emit(_character.velocity) # potential issues with how vel indicator is set
	#print(_character.velocity)

## Problem
## added force overshoots the direction of the colider causing rubber banding till velocity stablizes to collider



func change_setting(setting: Setting) -> void:
	_setting = setting


## its expected that node uses mesh forward

## returns 0 - 180deg[br]
## pos = up, neg = down
func _get_relative_pitch(from: Node3D, to: Node3D) -> float:
	# pitch_scale -1 = down, 1 = up, 0 = horizontile circle
	var pitch_scale: float = from.basis.y.dot(-to.basis.z) # using basis.y keeps 1s as vertical and prevents rotation on y axis from changing pitch value
	var pitch: float = lerpf(0.0, 90.0, pitch_scale) # convert: -90 to 90
	var upside_down: bool = from.basis.y.dot(to.basis.y) < 0 # neg if upside down
	if upside_down:
		pitch = (90 + (90 - pitch)) if pitch_scale > 0.0 \
		else (-90 - (90 + pitch))
	#print( pitch ) # 0 - 180, pos = up, neg = down
	return pitch

# NOTE: get_relative_yaw and get_relative_roll are not used
func get_relative_yaw(from: Node3D, to: Node3D) -> float:
	# yaw -1 = left, 1 = right, 0 = vertical circle
	var y: float = -from.basis.x.dot(-to.basis.z)
	var yaw: float = lerpf(0.0, 90.0, y) # -90 to 90
	var face_backwards = from.basis.x.dot(to.basis.x) > 0 # pos if looking back
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
