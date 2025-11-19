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
	if input_velocity:
		_character.velocity += input_velocity
	
	var wing_area: float = 2.0
	var pitch: float = _velocity_indicator.get_relative_pitch(_collision_shape_3d)
	
	var lift_pch: float = clampf(pitch, -lift_curve.max_domain, lift_curve.max_domain)
	var lift_co: float = lift_curve.sample(abs(lift_pch))
	if lift_pch < 0:
		lift_co *= -1.0
	#print(lift_co)
	
	var drag_pch: float = clampf(pitch, -drag_curve.max_domain, drag_curve.max_domain)
	var drag_co: float = drag_curve.sample(abs(drag_pch))
	#print(drag_co)
	
	# lift/drag formula
	# lift = lift_coefficient * (0.5 * velocity^2)
	
	# use only forward velocity where forward is the direction of collision shape basis.z
	# this makes it so that if the collider is facing global forward but falling allong the global y axis, its speed_adjusted will be 0 as all momentum is pointing down
	var speed_adjusted: float = 0.5 * pow((_character.velocity.project(_collision_shape_3d.basis.z.normalized())).length(), 2)
	
	var lift_mag: float = lift_co * speed_adjusted * wing_area
	# NOTE: setting lift_dir to Vector3.UP still results in flicker between neg and pos y in the velocity vector
	var lift_dir: Vector3 = _velocity_indicator.basis.y.normalized().rotated(_velocity_indicator.basis.z, _collision_shape_3d.rotation.z)
	var lift_force: Vector3 = lift_dir * lift_mag
	
	var drag_mag: float = drag_co * speed_adjusted
	var drag_dir: Vector3 = _velocity_indicator.basis.z.normalized()
	var drag_force: Vector3 = drag_dir * drag_mag
	
	
	# NOTE: comment out this block to freeze character in air
	# terminal velocity = sqrt( (2 * m * g) / (air_density * object_area * drag_coefficient) )
	var terminal_vel: float = (2 * _character.get_gravity().length()) / drag_co
	_character.velocity += _character.get_gravity() * _delta
	if _character.velocity.y < -terminal_vel:
		_character.velocity.y = -terminal_vel
	
	_character.velocity += (lift_force + drag_force) * _delta
	_character.move_and_slide()
	# NOTE: end of block
	
	# keep updates based on velocity after velocity is set
	velocity_set.emit(_character.velocity)
	print(_character.velocity)



func change_setting(setting: Setting) -> void:
	_setting = setting
