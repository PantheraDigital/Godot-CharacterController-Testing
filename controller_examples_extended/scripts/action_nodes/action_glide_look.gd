extends ActionNode


var _character: CharacterBody3D
var _cam_control: CamControl
var _collision_shape_3d: RotationFollower
var _movement_flight: MovementFlying

var roll_ac: float = 0
var pitch_ac: float = 0
var current_velocity: Vector3


func _init() -> void:
	self.ACTION_ID = "LOOK"
	self.IS_LAYERED = true


func refresh() -> void:
	_character = container.get_parent()
	_cam_control = _character.get_node("CamPivot")
	_collision_shape_3d = _character.find_child("CollisionShape3D", false)
	
	if _movement_flight and _movement_flight.velocity_set.is_connected(_update_current_velocity):
		_movement_flight.velocity_set.disconnect(_update_current_velocity)
	_movement_flight = _character.find_child("MovementStateManager", false).find_child("FlyingMovement", false)
	_movement_flight.velocity_set.connect(_update_current_velocity)
	
	roll_ac = _collision_shape_3d.rotation.z
	pitch_ac = _collision_shape_3d.rotation.x

func enter() -> void:
	super.enter()

func play(_params: Dictionary = {}) -> void:
	pitch_ac -= _params["aim_direction"].y * _cam_control.sensitivity_y
	roll_ac -= _params["aim_direction"].x * _cam_control.sensitivity_x
	roll_ac = clampf(roll_ac, deg_to_rad(-70.0), deg_to_rad(70.0))
	super.play()

func _process(_delta: float) -> void:
	if !is_enabled:
		return
	
	_collision_shape_3d.face_point(current_velocity, true)
	_collision_shape_3d.rotation.z = roll_ac
	_collision_shape_3d.rotation.x = pitch_ac
	
	_cam_control.rotation.y = _collision_shape_3d.rotation.y
	_cam_control.rotation.x = _collision_shape_3d.rotation.x

func _update_current_velocity(velocity: Vector3) -> void:
	current_velocity = velocity








## add action node template for layered and non-layered action nodes
## action container setter based on node tree
