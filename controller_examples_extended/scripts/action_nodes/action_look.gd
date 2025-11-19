extends ActionNode


var _character: CharacterBody3D
var _cam_control: CamControl
var _collision_shape_3d: RotationFollower

## The speed rotation should happen at. 0.0, no rotation. 0.1, slow. 1.0, instant.
@export_range(0.0, 1.0) var lerp_value: float = 0.15


func _init() -> void:
	self.ACTION_ID = "LOOK"
	self.IS_LAYERED = true


func refresh() -> void:
	_character = container.get_parent()
	_cam_control = _character.get_node("CamPivot")
	_collision_shape_3d = _character.find_child("CollisionShape3D", false)

func play(_params: Dictionary = {}) -> void:
	_cam_control.rotate_xy(_params["aim_direction"])
	super.play()

func _process(_delta: float) -> void:
	if _character.velocity:
		_collision_shape_3d.face_point(_character.velocity, false, lerp_value)
