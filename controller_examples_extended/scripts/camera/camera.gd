extends Camera3D
class_name Camera3DExtended


enum FOV_SETTINGS {NORMAL, RUN, FLY, RUN_FLY}
const CAMERA_BLEND : float = 1.0

@export var run_fov : float = 77.0
@export var fly_fov : float = 77.0
@export var run_fly_fov : float = 84.0

var current_fov_setting: FOV_SETTINGS = FOV_SETTINGS.NORMAL
var normal_fov : float = 0.0
var _cam_new_fov: float = 0.0


func _ready() -> void:
	normal_fov = fov

func _process(_delta: float) -> void:
	if _cam_new_fov != 0.0 and _cam_new_fov != fov:
		fov = move_toward(fov, _cam_new_fov, CAMERA_BLEND)

func change_fov(setting: FOV_SETTINGS) -> void:
	current_fov_setting = setting
	match setting:
		FOV_SETTINGS.NORMAL:
			_cam_new_fov = normal_fov
		FOV_SETTINGS.RUN:
			_cam_new_fov = run_fov
		FOV_SETTINGS.FLY:
			_cam_new_fov = fly_fov
		FOV_SETTINGS.RUN_FLY:
			_cam_new_fov = run_fly_fov
