extends ActionNode


var _character: CharacterBody3D
var _movement_manager: MovementStateManager
var _state_data_manager: StateDataManager
var _cam: Camera3DExtended
var _cam_pivot: CamControl
var _animation_player: AnimationPlayer
var _collision_shape_3d: RotationFollower
var _velocity_indicator: VelocityIndicator


func _init() -> void:
	self.ACTION_ID = "TO_GLIDE"


func refresh() -> void:
	_character = container.get_parent()
	_movement_manager = _character.find_child("MovementStateManager", false)
	_state_data_manager = _character.find_child("StateDataManager", false)
	_cam = _character.find_child("Camera3D")
	_cam_pivot = _character.find_child("CamPivot")
	_animation_player = _character.find_child("AnimationPlayer", false)
	_collision_shape_3d = _character.find_child("CollisionShape3D", false)
	_velocity_indicator = _character.find_child("VelocityIndicator", false)

func can_play() -> bool:
	return super.can_play() and !_character.is_on_floor()

func play(_params: Dictionary = {}) -> void:
	print("play to glide")
	var velocity_boost: Vector3 = Vector3(0,15,-15)
	_collision_shape_3d.face_point(velocity_boost, true)
	_cam_pivot.face_point(velocity_boost, true)
	_velocity_indicator._face_point(velocity_boost)
	
	_state_data_manager.set_currnet_data(StateDataManager.DATA_TYPE.FLYING)
	_cam.change_fov(Camera3DExtended.FOV_SETTINGS.FLY)
	_animation_player.play("prone")
	
	_movement_manager.set_active_state("FlyingMovement")
	_movement_manager.active_state.change_setting(MovementFlying.Setting.PHYSICS)
	_movement_manager.active_state.add_velocity(velocity_boost)
	
	container.reconfigure("gliding", ["ToGlide", "Boost", "GlideLook"])
	
	is_playing = true
	


func stop() -> void:
	print("stop to glide")
	
	container.reconfigure("grounded")
	_state_data_manager.set_currnet_data(StateDataManager.DATA_TYPE.GROUNDED)
	_cam.change_fov(Camera3DExtended.FOV_SETTINGS.NORMAL)
	_animation_player.play_backwards("prone")
	
	is_playing = false
